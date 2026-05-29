#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-workspace-audit.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

"$PYTHON_BIN" "$AUDIT_SCRIPT" "$FIXTURES_DIR/clean-repo" --json-out "$TMP_DIR/clean.json" >/dev/null
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$FIXTURES_DIR/bloated-agents" --json-out "$TMP_DIR/bloated.json" >/dev/null
mkdir -p "$TMP_DIR/escape-ref"
cat >"$TMP_DIR/escape-ref/AGENTS.md" <<'EOF'
# Workspace Rules

- Run `../outside.sh` before deploy.
EOF
printf '#!/usr/bin/env bash\n' >"$TMP_DIR/outside.sh"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/escape-ref" --json-out "$TMP_DIR/escape.json" >/dev/null
mkdir -p "$TMP_DIR/nested-ref/packages/frontend/scripts"
cat >"$TMP_DIR/nested-ref/packages/frontend/AGENTS.md" <<'EOF'
# Frontend Rules

## Commands

- Run `bash scripts/build.sh` before release.
EOF
printf '#!/usr/bin/env bash\n' >"$TMP_DIR/nested-ref/packages/frontend/scripts/build.sh"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/nested-ref" --json-out "$TMP_DIR/nested.json" >/dev/null
mkdir -p "$TMP_DIR/invalid-package"
cat >"$TMP_DIR/invalid-package/AGENTS.md" <<'EOF'
# Package Rules

## Commands

- Run `npm run build` before release.
EOF
cat >"$TMP_DIR/invalid-package/package.json" <<'EOF'
{"scripts":
EOF
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/invalid-package" --json-out "$TMP_DIR/invalid-package.json" >/dev/null
mkdir -p "$TMP_DIR/single-quote-hooks"
cat >"$TMP_DIR/single-quote-hooks/extension.yml" <<'EOF'
schema_version: "1.0"
extension:
  id: memorylint
  version: "0.1.0"
  description: "Fixture for single quoted hooks."
hooks:
  before_plan:
    command: 'speckit.memorylint.run'
  after_constitution:
    command: 'speckit.memorylint.run'
provides:
  commands:
    - name: speckit.memorylint.audit
      description: "Audit"
EOF
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/single-quote-hooks" --json-out "$TMP_DIR/single-quote.json" >/dev/null
mkdir -p "$TMP_DIR/comment-hook"
cat >"$TMP_DIR/comment-hook/extension.yml" <<'EOF'
schema_version: "1.0"
extension:
  id: memorylint
  version: "0.1.0"
  description: "Fixture for commented hook commands."
hooks:
  before_plan:
    command: speckit.memorylint.load-agents # planning gate
provides:
  commands:
    - name: speckit.memorylint.load-agents
      description: "Load agents"
EOF
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/comment-hook" --json-out "$TMP_DIR/comment-hook.json" >/dev/null
mkdir -p "$TMP_DIR/other-extension-hook"
cat >"$TMP_DIR/other-extension-hook/extension.yml" <<'EOF'
schema_version: "1.0"
extension:
  id: demo-extension
  version: "0.1.0"
  description: "Fixture for external hook remediation."
hooks:
  before_plan:
    command: speckit.demo.audit
provides:
  commands:
    - name: speckit.demo.other
      description: "Other command"
EOF
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/other-extension-hook" --json-out "$TMP_DIR/other-extension.json" >/dev/null
mkdir -p "$TMP_DIR/commented-command"
cat >"$TMP_DIR/commented-command/extension.yml" <<'EOF'
schema_version: "1.0"
extension:
  id: demo-extension
  version: "0.1.0"
  description: "Fixture for commented command declarations."
hooks:
  before_plan:
    command: speckit.demo.audit
provides:
  commands:
    - name: speckit.demo.audit # primary command
      description: "Audit"
EOF
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/commented-command" --json-out "$TMP_DIR/commented-command.json" >/dev/null
mkdir -p "$TMP_DIR/mixed-content"
cat >"$TMP_DIR/mixed-content/AGENTS.md" <<'EOF'
# Workspace Rules

## Commands

- Run `make test`, then remove old helper `scripts/old.sh`.
EOF
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/mixed-content" --json-out "$TMP_DIR/mixed-content.json" >/dev/null

"$PYTHON_BIN" - "$TMP_DIR/clean.json" "$TMP_DIR/bloated.json" "$TMP_DIR/escape.json" "$TMP_DIR/nested.json" "$TMP_DIR/invalid-package.json" "$TMP_DIR/single-quote.json" "$TMP_DIR/comment-hook.json" "$TMP_DIR/other-extension.json" "$TMP_DIR/commented-command.json" "$TMP_DIR/mixed-content.json" <<'PY'
import json
import sys
from pathlib import Path

clean = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
bloated = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
escaped = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))
nested = json.loads(Path(sys.argv[4]).read_text(encoding="utf-8"))
invalid_package = json.loads(Path(sys.argv[5]).read_text(encoding="utf-8"))
single_quote = json.loads(Path(sys.argv[6]).read_text(encoding="utf-8"))
comment_hook = json.loads(Path(sys.argv[7]).read_text(encoding="utf-8"))
other_extension = json.loads(Path(sys.argv[8]).read_text(encoding="utf-8"))
commented_command = json.loads(Path(sys.argv[9]).read_text(encoding="utf-8"))
mixed_content = json.loads(Path(sys.argv[10]).read_text(encoding="utf-8"))

if clean["metrics"]["total_findings"] != 0:
    raise SystemExit("FAIL: clean-repo workspace audit should produce zero findings")

required_top_level = {"schema_version", "workspace_root", "source_metadata", "instruction_map", "findings", "metrics", "summary"}
missing = required_top_level.difference(bloated.keys())
if missing:
    raise SystemExit(f"FAIL: bloated-agents report missing keys: {sorted(missing)}")

if not bloated["metrics"]["files_that_would_be_modified"]:
    raise SystemExit("FAIL: bloated-agents report should list files_that_would_be_modified")

handoffs = [finding for finding in bloated["findings"] if finding.get("manual_handoff")]
if not handoffs:
    raise SystemExit("FAIL: bloated-agents should emit at least one constitution manual handoff")

escape_findings = [finding for finding in escaped["findings"] if "../outside.sh" in finding.get("evidence", "")]
if not escape_findings:
    raise SystemExit("FAIL: workspace audit should flag out-of-workspace path references")

nested_stale = [finding for finding in nested["findings"] if "scripts/build.sh" in finding.get("evidence", "")]
if nested_stale:
    raise SystemExit("FAIL: nested package-local script paths should resolve relative to their rule file")

invalid_json = [finding for finding in invalid_package["findings"] if "not valid JSON" in finding.get("evidence", "")]
if not invalid_json:
    raise SystemExit("FAIL: malformed package.json should produce an explicit finding instead of crashing audit")

hook_findings = [finding for finding in single_quote["findings"] if "hook `" in finding.get("evidence", "")]
if len(hook_findings) != 2:
    raise SystemExit(f"FAIL: single-quoted hook fixture should produce exactly 2 hook findings, got {len(hook_findings)}")
if any(finding["source"].endswith(":1") for finding in hook_findings):
    raise SystemExit("FAIL: single-quoted hook findings should point at the hook command line, not line 1")

comment_hook_findings = [finding for finding in comment_hook["findings"] if "hook `" in finding.get("evidence", "")]
if comment_hook_findings:
    raise SystemExit("FAIL: inline YAML comments should not become part of hook command names")

external_hook_findings = [finding for finding in other_extension["findings"] if "hook `" in finding.get("evidence", "")]
if len(external_hook_findings) != 1:
    raise SystemExit(f"FAIL: external hook fixture should produce exactly 1 hook finding, got {len(external_hook_findings)}")
if external_hook_findings[0].get("edits"):
    raise SystemExit("FAIL: non-memorylint hook findings without a known replacement should not emit no-op edits")

commented_command_findings = [finding for finding in commented_command["findings"] if "hook `" in finding.get("evidence", "")]
if commented_command_findings:
    raise SystemExit("FAIL: inline comments in provides.commands should not break hook declaration matching")

mixed_content_findings = [finding for finding in mixed_content["findings"] if "scripts/old.sh" in finding.get("evidence", "")]
if len(mixed_content_findings) != 1:
    raise SystemExit(f"FAIL: mixed-content fixture should produce exactly 1 stale-path finding, got {len(mixed_content_findings)}")
if mixed_content_findings[0].get("edits"):
    raise SystemExit("FAIL: mixed-content stale-path findings should not auto-delete the entire rule line")

print("workspace audit checks passed")
PY
