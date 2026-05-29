#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUDIT_SCRIPT="$ROOT_DIR/memorylint/scripts/audit_workspace.py"
APPLY_SCRIPT="$ROOT_DIR/memorylint/scripts/apply_report.py"
FIXTURES_DIR="$ROOT_DIR/memorylint/tests/fixtures"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-apply-workflow.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cp -R "$FIXTURES_DIR/stale-command" "$TMP_DIR/stale-command"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/stale-command" --json-out "$TMP_DIR/stale-command-report.json" >/dev/null
"$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/stale-command-report.json" --mode apply-safe-fixes >"$TMP_DIR/stale-apply.txt"
if grep -q "scripts/deploy.sh" "$TMP_DIR/stale-command/AGENTS.md"; then
  echo "FAIL: apply-safe-fixes should remove stale script reference" >&2
  exit 1
fi
if grep -q "npm run e2e" "$TMP_DIR/stale-command/AGENTS.md"; then
  echo "FAIL: apply-safe-fixes should remove stale npm script reference" >&2
  exit 1
fi

cp -R "$FIXTURES_DIR/stale-command" "$TMP_DIR/stale-stale"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/stale-stale" --json-out "$TMP_DIR/stale-stale-report.json" >/dev/null
printf '\n- manual mutation after audit\n' >> "$TMP_DIR/stale-stale/AGENTS.md"
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/stale-stale-report.json" --mode apply-safe-fixes >"$TMP_DIR/staleness.txt" 2>&1; then
  echo "FAIL: apply should reject stale reports" >&2
  exit 1
fi
grep -q "Staleness check failed" "$TMP_DIR/staleness.txt" || {
  echo "FAIL: staleness failure output missing" >&2
  exit 1
}

cp -R "$FIXTURES_DIR/post-apply-breakage" "$TMP_DIR/post-apply-breakage"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/post-apply-breakage" --json-out "$TMP_DIR/post-apply-report.json" >/dev/null
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/post-apply-report.json" --mode apply-all-approved --approve ML-003 >"$TMP_DIR/rollback.txt" 2>&1; then
  echo "FAIL: apply-all-approved should fail validation and rollback" >&2
  exit 1
fi
grep -q "All Changes Reverted" "$TMP_DIR/rollback.txt" || {
  echo "FAIL: rollback report missing" >&2
  exit 1
}
grep -q "speckit.memorylint.run" "$TMP_DIR/post-apply-breakage/extension.yml" || {
  echo "FAIL: rollback should restore original extension.yml" >&2
  exit 1
}

cp -R "$FIXTURES_DIR/stale-command" "$TMP_DIR/path-escape"
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/path-escape" --json-out "$TMP_DIR/path-escape-report.json" >/dev/null
printf 'outside\n' > "$TMP_DIR/escaped.txt"
"$PYTHON_BIN" - "$TMP_DIR/path-escape-report.json" <<'PY'
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
report = json.loads(report_path.read_text(encoding="utf-8"))
report["findings"] = [{
    "id": "ML-escape",
    "drift_type": "reality",
    "severity": "warning",
    "confidence": "high",
    "source": "AGENTS.md:3-3",
    "evidence": "malicious report",
    "recommended_destination": "AGENTS.md",
    "suggested_action": "delete",
    "detail": "attempt escape",
    "edits": [{
        "path": "../escaped.txt",
        "action": "delete",
        "start_line": 1,
        "end_line": 1,
        "reason": "escape test"
    }]
}]
report["source_metadata"] = [{"path": "../escaped.txt", "sha256": "ignored"}]
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/path-escape-report.json" --mode apply-all-approved --approve ML-escape >"$TMP_DIR/path-escape.txt" 2>&1; then
  echo "FAIL: apply should reject report paths outside the workspace" >&2
  exit 1
fi
grep -q "Path escapes workspace" "$TMP_DIR/path-escape.txt" || {
  echo "FAIL: workspace escape failure output missing" >&2
  exit 1
}
grep -q '^outside$' "$TMP_DIR/escaped.txt" || {
  echo "FAIL: escaped target should remain unchanged" >&2
  exit 1
}

mkdir -p "$TMP_DIR/apply-approved"
cat >"$TMP_DIR/apply-approved/AGENTS.md" <<'EOF'
# Workspace Rules

## Commands

- Remove stale script reference.
- Remove stale npm script reference.
EOF
"$PYTHON_BIN" - "$TMP_DIR/apply-approved/approved-report.json" "$TMP_DIR/apply-approved" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
workspace = Path(sys.argv[2]).resolve()
agents_path = workspace / "AGENTS.md"
report = {
    "schema_version": "1.0",
    "workspace_root": str(workspace),
    "source_metadata": [{
        "path": "AGENTS.md",
        "sha256": hashlib.sha256(agents_path.read_bytes()).hexdigest(),
    }],
    "instruction_map": [],
    "findings": [
        {
            "id": "ML-safe",
            "drift_type": "reality",
            "severity": "warning",
            "confidence": "high",
            "source": "AGENTS.md:5",
            "evidence": "safe finding",
            "recommended_destination": "AGENTS.md",
            "suggested_action": "delete",
            "detail": "delete first line",
            "edits": [{"path": "AGENTS.md", "action": "delete", "start_line": 5, "end_line": 5, "reason": "safe"}],
        },
        {
            "id": "ML-approved",
            "drift_type": "reality",
            "severity": "critical",
            "confidence": "high",
            "source": "AGENTS.md:6",
            "evidence": "approved finding",
            "recommended_destination": "AGENTS.md",
            "suggested_action": "delete",
            "detail": "delete second line",
            "edits": [{"path": "AGENTS.md", "action": "delete", "start_line": 6, "end_line": 6, "reason": "approved"}],
        },
    ],
    "metrics": {},
    "summary": {},
}
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
"$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/apply-approved/approved-report.json" --mode apply-all-approved --approve ML-approved >/dev/null
grep -q "Remove stale script reference" "$TMP_DIR/apply-approved/AGENTS.md" || {
  echo "FAIL: apply-all-approved should not apply unapproved safe findings" >&2
  exit 1
}
if grep -q "Remove stale npm script reference" "$TMP_DIR/apply-approved/AGENTS.md"; then
  echo "FAIL: apply-all-approved should apply explicitly approved findings" >&2
  exit 1
fi

mkdir -p "$TMP_DIR/workspace-override"
cat >"$TMP_DIR/workspace-override/AGENTS.md" <<'EOF'
# Workspace Rules

## Commands

- Override target
EOF
"$PYTHON_BIN" - "$TMP_DIR/workspace-override/override-report.json" "$TMP_DIR/workspace-override" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
workspace = Path(sys.argv[2]).resolve()
agents_path = workspace / "AGENTS.md"
report = {
    "schema_version": "1.0",
    "workspace_root": "/tmp/elsewhere",
    "source_metadata": [{
        "path": "AGENTS.md",
        "sha256": hashlib.sha256(agents_path.read_bytes()).hexdigest(),
    }],
    "instruction_map": [],
    "findings": [{
        "id": "ML-override",
        "drift_type": "reality",
        "severity": "warning",
        "confidence": "high",
        "source": "AGENTS.md:5",
        "evidence": "workspace override",
        "recommended_destination": "AGENTS.md",
        "suggested_action": "delete",
        "detail": "delete target",
        "edits": [{"path": "AGENTS.md", "action": "delete", "start_line": 5, "end_line": 5, "reason": "override"}],
    }],
    "metrics": {},
    "summary": {},
}
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
"$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/workspace-override/override-report.json" --workspace "$TMP_DIR/workspace-override" --mode apply-all-approved --approve ML-override >/dev/null
if grep -q "Override target" "$TMP_DIR/workspace-override/AGENTS.md"; then
  echo "FAIL: --workspace override should apply against the overridden workspace root" >&2
  exit 1
fi

mkdir -p "$TMP_DIR/constitution-edit/.specify/memory"
cat >"$TMP_DIR/constitution-edit/.specify/memory/constitution.md" <<'EOF'
# Constitution

## Rules

- Immutable rule
EOF
"$PYTHON_BIN" - "$TMP_DIR/constitution-edit/constitution-report.json" "$TMP_DIR/constitution-edit" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
workspace = Path(sys.argv[2]).resolve()
constitution_path = workspace / ".specify/memory/constitution.md"
report = {
    "schema_version": "1.0",
    "workspace_root": str(workspace),
    "source_metadata": [{
        "path": ".specify/memory/constitution.md",
        "sha256": hashlib.sha256(constitution_path.read_bytes()).hexdigest(),
    }],
    "instruction_map": [],
    "findings": [{
        "id": "ML-constitution",
        "drift_type": "reality",
        "severity": "warning",
        "confidence": "high",
        "source": ".specify/memory/constitution.md:5",
        "evidence": "constitution edit",
        "recommended_destination": ".specify/memory/constitution.md",
        "suggested_action": "delete",
        "detail": "should remain manual",
        "edits": [{
            "path": ".specify/memory/constitution.md",
            "action": "delete",
            "start_line": 5,
            "end_line": 5,
            "reason": "constitution",
        }],
    }],
    "metrics": {},
    "summary": {},
}
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/constitution-edit/constitution-report.json" --mode apply-all-approved --approve ML-constitution >"$TMP_DIR/constitution-edit/output.txt" 2>&1; then
  echo "FAIL: apply should reject constitution edit targets" >&2
  exit 1
fi
grep -q "Constitution edits must stay manual handoffs" "$TMP_DIR/constitution-edit/output.txt" || {
  echo "FAIL: constitution protection failure output missing" >&2
  exit 1
}
grep -q "Immutable rule" "$TMP_DIR/constitution-edit/.specify/memory/constitution.md" || {
  echo "FAIL: constitution file should remain unchanged" >&2
  exit 1
}

mkdir -p "$TMP_DIR/git-diff-check"
cat >"$TMP_DIR/git-diff-check/AGENTS.md" <<'EOF'
# Workspace Rules

## Commands

- Clean command
- Stable command
EOF
git -C "$TMP_DIR/git-diff-check" init -q
git -C "$TMP_DIR/git-diff-check" config user.name "MemoryLint Test"
git -C "$TMP_DIR/git-diff-check" config user.email "memorylint@example.com"
git -C "$TMP_DIR/git-diff-check" add AGENTS.md
git -C "$TMP_DIR/git-diff-check" commit -qm "init"
"$PYTHON_BIN" - "$TMP_DIR/git-diff-check/git-report.json" "$TMP_DIR/git-diff-check" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
workspace = Path(sys.argv[2]).resolve()
agents_path = workspace / "AGENTS.md"
report = {
    "schema_version": "1.0",
    "workspace_root": str(workspace),
    "source_metadata": [{
        "path": "AGENTS.md",
        "sha256": hashlib.sha256(agents_path.read_bytes()).hexdigest(),
    }],
    "instruction_map": [],
    "findings": [
        {
            "id": "ML-diff",
            "drift_type": "reality",
            "severity": "warning",
            "confidence": "high",
            "source": "AGENTS.md:5",
            "evidence": "git diff check",
            "recommended_destination": "AGENTS.md",
            "suggested_action": "rewrite",
            "detail": "introduce trailing whitespace",
            "edits": [{
                "path": "AGENTS.md",
                "action": "replace",
                "start_line": 5,
                "end_line": 5,
                "replacement": ["- Dirty command  "],
                "reason": "diff check",
            }],
        },
    ],
    "metrics": {},
    "summary": {},
}
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/git-diff-check/git-report.json" --mode apply-all-approved --approve ML-diff >"$TMP_DIR/git-diff-check/output.txt" 2>&1; then
  echo "FAIL: apply should rollback when git diff --check fails" >&2
  exit 1
fi
grep -q "git diff --check failed" "$TMP_DIR/git-diff-check/output.txt" || {
  echo "FAIL: git diff validation failure missing" >&2
  exit 1
}
grep -q "Clean command" "$TMP_DIR/git-diff-check/AGENTS.md" || {
  echo "FAIL: git diff validation rollback should restore original file" >&2
  exit 1
}

mkdir -p "$TMP_DIR/overlap-check"
cat >"$TMP_DIR/overlap-check/AGENTS.md" <<'EOF'
# Workspace Rules

## Commands

- First rule
- Second rule
EOF
"$PYTHON_BIN" - "$TMP_DIR/overlap-check/overlap-report.json" "$TMP_DIR/overlap-check" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
workspace = Path(sys.argv[2]).resolve()
agents_path = workspace / "AGENTS.md"
report = {
    "schema_version": "1.0",
    "workspace_root": str(workspace),
    "source_metadata": [{
        "path": "AGENTS.md",
        "sha256": hashlib.sha256(agents_path.read_bytes()).hexdigest(),
    }],
    "instruction_map": [],
    "findings": [
        {
            "id": "ML-overlap-a",
            "drift_type": "reality",
            "severity": "warning",
            "confidence": "high",
            "source": "AGENTS.md:5",
            "evidence": "overlap a",
            "recommended_destination": "AGENTS.md",
            "suggested_action": "delete",
            "detail": "first overlap",
            "edits": [{"path": "AGENTS.md", "action": "delete", "start_line": 5, "end_line": 5, "reason": "overlap a"}],
        },
        {
            "id": "ML-overlap-b",
            "drift_type": "reality",
            "severity": "warning",
            "confidence": "high",
            "source": "AGENTS.md:5",
            "evidence": "overlap b",
            "recommended_destination": "AGENTS.md",
            "suggested_action": "delete",
            "detail": "second overlap",
            "edits": [{"path": "AGENTS.md", "action": "delete", "start_line": 5, "end_line": 5, "reason": "overlap b"}],
        },
    ],
    "metrics": {},
    "summary": {},
}
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
if "$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/overlap-check/overlap-report.json" --mode apply-all-approved --approve ML-overlap-a --approve ML-overlap-b >"$TMP_DIR/overlap-check/output.txt" 2>&1; then
  echo "FAIL: apply should reject overlapping edits" >&2
  exit 1
fi
grep -q "Overlapping edits detected" "$TMP_DIR/overlap-check/output.txt" || {
  echo "FAIL: overlapping edit failure output missing" >&2
  exit 1
}
grep -q "First rule" "$TMP_DIR/overlap-check/AGENTS.md" || {
  echo "FAIL: overlapping edit rejection should leave source unchanged" >&2
  exit 1
}

mkdir -p "$TMP_DIR/hook-comment-rewrite"
cat >"$TMP_DIR/hook-comment-rewrite/extension.yml" <<'EOF'
schema_version: "1.0"
extension:
  id: memorylint
  version: "0.1.0"
  description: "Fixture for hook rewrite comments."
hooks:
  before_plan:
    command: speckit.memorylint.run  # planning gate
provides:
  commands:
    - name: speckit.memorylint.load-agents
      description: "Load agents"
EOF
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/hook-comment-rewrite" --json-out "$TMP_DIR/hook-comment-rewrite/report.json" >/dev/null
"$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/hook-comment-rewrite/report.json" --mode apply-all-approved --approve ML-001 >/dev/null
grep -q 'command: "speckit.memorylint.load-agents"  # planning gate' "$TMP_DIR/hook-comment-rewrite/extension.yml" || {
  echo "FAIL: hook rewrite should preserve spacing before inline comments" >&2
  exit 1
}
"$PYTHON_BIN" "$AUDIT_SCRIPT" "$TMP_DIR/hook-comment-rewrite" --json-out "$TMP_DIR/hook-comment-rewrite/recheck.json" >/dev/null
"$PYTHON_BIN" - "$TMP_DIR/hook-comment-rewrite/recheck.json" <<'PY'
import json
import sys
from pathlib import Path

report = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
hook_findings = [finding for finding in report["findings"] if "hook `" in finding.get("evidence", "")]
if hook_findings:
    raise SystemExit("FAIL: rewritten hook command with inline comment should remain parseable")
PY

mkdir -p "$TMP_DIR/top-level-heading"
cat >"$TMP_DIR/top-level-heading/AGENTS.md" <<'EOF'
# Workspace Rules

- Keep this bullet.
- Remove this bullet.
EOF
"$PYTHON_BIN" - "$TMP_DIR/top-level-heading/top-level-report.json" "$TMP_DIR/top-level-heading" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
workspace = Path(sys.argv[2]).resolve()
agents_path = workspace / "AGENTS.md"
report = {
    "schema_version": "1.0",
    "workspace_root": str(workspace),
    "source_metadata": [{
        "path": "AGENTS.md",
        "sha256": hashlib.sha256(agents_path.read_bytes()).hexdigest(),
    }],
    "instruction_map": [],
    "findings": [{
        "id": "ML-top-level",
        "drift_type": "reality",
        "severity": "warning",
        "confidence": "high",
        "source": "AGENTS.md:4",
        "evidence": "top-level heading",
        "recommended_destination": "AGENTS.md",
        "suggested_action": "delete",
        "detail": "delete second bullet",
        "edits": [{"path": "AGENTS.md", "action": "delete", "start_line": 4, "end_line": 4, "reason": "top-level"}],
    }],
    "metrics": {},
    "summary": {},
}
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY
"$PYTHON_BIN" "$APPLY_SCRIPT" "$TMP_DIR/top-level-heading/top-level-report.json" --mode apply-all-approved --approve ML-top-level >/dev/null
grep -q "Keep this bullet." "$TMP_DIR/top-level-heading/AGENTS.md" || {
  echo "FAIL: bullets under a top-level heading should remain valid after apply" >&2
  exit 1
}

echo "apply workflow checks passed"
