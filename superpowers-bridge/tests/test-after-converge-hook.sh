#!/usr/bin/env bash
# US2 / FR-007, FR-008, FR-009: the bridge declares a mandatory after_converge hook that runs
# the evidence-first verify gate, so convergence-appended/implemented work is evidence-gated.
#
# Upstream dispatch assumption (analysis C2): the speckit-converge command's post-execution
# step reads `hooks.after_converge` from .specify/extensions.yml and, for a mandatory hook
# (optional: false), emits `EXECUTE_COMMAND: {command}` after reporting the convergence outcome.
# Source: speckit-converge SKILL.md "Check for extension hooks" / after_converge step.
# Blocking-on-missing-evidence (analysis C3) is inherited from the reused speckit.superb.verify
# command (the same gate used by after_implement), so no separate blocking test is needed here.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$ROOT_DIR/superpowers-bridge/extension.yml"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then echo "python3";
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then echo "python";
  else echo "ERROR: requires Python 3 on PATH" >&2; exit 1; fi
}
PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# 1. Manifest declares after_converge → speckit.superb.verify, mandatory.
"$PYTHON_BIN" - "$MANIFEST" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"^\s{2}after_converge:\s*\n((?:\s{4}.*\n)+)", text, re.MULTILINE)
if not m:
    print("FAIL: extension.yml has no after_converge hook", file=sys.stderr); sys.exit(1)
block = m.group(1)
if "command: speckit.superb.verify" not in block:
    print("FAIL: after_converge must run speckit.superb.verify", file=sys.stderr); sys.exit(1)
if not re.search(r"optional:\s*false", block):
    print("FAIL: after_converge must be mandatory (optional: false)", file=sys.stderr); sys.exit(1)

desc_match = re.search(r"description:\s*>\s*\n((?:\s{6}.*\n)+)", block)
if not desc_match:
    print("FAIL: after_converge has no description block", file=sys.stderr); sys.exit(1)
desc = desc_match.group(1)
if re.search(r"converge.*implements", desc.lower()) or re.search(r"converge.*executes", desc.lower()):
    print("FAIL: description incorrectly claims converge implements or executes tasks", file=sys.stderr); sys.exit(1)
if "assesses" not in desc.lower() or "appends" not in desc.lower():
    print("FAIL: description must specify converge only assesses and appends tasks", file=sys.stderr); sys.exit(1)

print("ok: manifest after_converge declaration")
PY

# 2. Dispatch resolution per the documented converge rule: mandatory hook -> EXECUTE_COMMAND.
dispatch() {  # $1 = extensions.yml path -> prints EXECUTE_COMMAND line(s) for mandatory after_converge
  "$PYTHON_BIN" - "$1" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"^\s*after_converge:\s*\n((?:\s+.*\n)+?)(?=^\S|\Z)", text, re.MULTILINE)
if not m:
    sys.exit(0)
block = m.group(1)
cmd = re.search(r"command:\s*(\S+)", block)
optional = re.search(r"optional:\s*(true|false)", block)
if cmd and optional and optional.group(1) == "false":
    print(f"EXECUTE_COMMAND: {cmd.group(1)}")
PY
}

# Present case: extensions.yml registers the bridge's mandatory after_converge hook.
cat > "$TMP_DIR/present.yml" <<'EOF'
hooks:
  after_converge:
    command: speckit.superb.verify
    optional: false
EOF
OUT_PRESENT="$(dispatch "$TMP_DIR/present.yml")"
if [ "$OUT_PRESENT" != "EXECUTE_COMMAND: speckit.superb.verify" ]; then
  echo "FAIL: present after_converge must dispatch the gating verify command, got: '$OUT_PRESENT'" >&2; exit 1
fi

# Absent case (bridge not installed): no after_converge entry -> no command (FR-009).
cat > "$TMP_DIR/absent.yml" <<'EOF'
hooks:
  after_implement:
    command: speckit.git.commit
    optional: true
EOF
OUT_ABSENT="$(dispatch "$TMP_DIR/absent.yml")"
if [ -n "$OUT_ABSENT" ]; then
  echo "FAIL: absent after_converge must dispatch nothing, got: '$OUT_ABSENT'" >&2; exit 1
fi

echo "PASS: test-after-converge-hook.sh"
