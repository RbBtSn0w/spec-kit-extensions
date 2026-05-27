#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-memorylint-regressions.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)

"$PYTHON_BIN" - "$ROOT_DIR" <<'PY'
from pathlib import Path
import sys
import re

root = Path(sys.argv[1])
extension = (root / "memorylint/extension.yml").read_text(encoding="utf-8")
audit = (root / "memorylint/commands/audit.md").read_text(encoding="utf-8")
apply_cmd = (root / "memorylint/commands/apply.md").read_text(encoding="utf-8")
load_agents = (root / "memorylint/commands/load-agents.md").read_text(encoding="utf-8")
design_path = root / "memorylint/DESIGN.md"
design = design_path.read_text(encoding="utf-8") if design_path.exists() else ""
check_boundaries_path = root / "memorylint/commands/check-boundaries.md"
fixture_scanner_path = root / "memorylint/scripts/scan_fixtures.py"
fixture_scanner_test_path = root / "memorylint/tests/test-fixture-scanner.sh"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


# ── extension.yml ────────────────────────────────────────────────────────────

require(
    'schema_version: "1.0"' in extension,
    "extension.yml must declare schema_version 1.0",
)

# Commands declared
require(
    "speckit.memorylint.audit" in extension,
    "extension.yml must declare speckit.memorylint.audit command",
)
require(
    "speckit.memorylint.apply" in extension,
    "extension.yml must declare speckit.memorylint.apply command",
)
require(
    "speckit.memorylint.load-agents" in extension,
    "extension.yml must declare speckit.memorylint.load-agents command",
)

# Each command file: reference must point to an existing file
for cmd_file in re.findall(r'file:\s*["\'\s]?(commands/[^"\'\s]+)["\'\s]?', extension):
    require(
        (root / "memorylint" / cmd_file).exists(),
        f"extension.yml references {cmd_file} but the file does not exist",
    )

# Description length
desc_match = re.search(r'^\s*description:\s*["\']?([^"\']+)["\']?$', extension, re.MULTILINE)
require(desc_match is not None, "extension.yml must have an extension description")
require(
    len(desc_match.group(1)) <= 200,
    f"extension.yml description must be <= 200 chars (got {len(desc_match.group(1))})",
)

# Hooks
require(
    "before_constitution:" in extension,
    "extension.yml must declare hooks.before_constitution",
)
hook_bc = re.search(
    r"^\s{2}before_constitution:\n(?P<body>(?:^\s{4}.+\n)+)", extension, re.MULTILINE
)
require(hook_bc is not None, "extension.yml must declare hooks.before_constitution")
require(
    'command: "speckit.memorylint.audit"' in hook_bc.group("body")
    or "command: speckit.memorylint.audit" in hook_bc.group("body"),
    "hooks.before_constitution.command must be speckit.memorylint.audit",
)

hook_ac = re.search(
    r"^\s{2}after_constitution:\n(?P<body>(?:^\s{4}.+\n)+)", extension, re.MULTILINE
)
require(hook_ac is not None, "extension.yml must declare hooks.after_constitution")
require(
    'command: "speckit.memorylint.audit"' in hook_ac.group("body")
    or "command: speckit.memorylint.audit" in hook_ac.group("body"),
    "hooks.after_constitution.command must be speckit.memorylint.audit",
)

hook_bp = re.search(
    r"^\s{2}before_plan:\n(?P<body>(?:^\s{4}.+\n)+)", extension, re.MULTILINE
)
require(hook_bp is not None, "extension.yml must declare hooks.before_plan")
require(
    'command: "speckit.memorylint.load-agents"' in hook_bp.group("body")
    or "command: speckit.memorylint.load-agents" in hook_bp.group("body"),
    "hooks.before_plan.command must be speckit.memorylint.load-agents",
)
require(
    "optional: false" in hook_bp.group("body"),
    "hooks.before_plan.optional must be false",
)

# ── audit.md ─────────────────────────────────────────────────────────────────

require("$ARGUMENTS" in audit, "audit.md must include the $ARGUMENTS context block")

require("Instruction Inventory" in audit, "audit.md must include Instruction Inventory")
require("Rule Classification" in audit, "audit.md must include Rule Classification")
require("Evidence Binding" in audit, "audit.md must include Evidence Binding")
require("Drift Detection" in audit, "audit.md must include Drift Detection")

# All 8 categories
for cat in [
    "infrastructure",
    "architecture",
    "workflow",
    "domain",
    "tooling",
    "personal_preference",
    "obsolete",
    "conflict",
]:
    require(cat in audit, f"audit.md must include category '{cat}'")

# All 4 drift types
for drift in ["boundary", "reality", "conflict", "redundancy"]:
    require(drift in audit, f"audit.md must include drift type '{drift}'")

# Confidence: low for no-evidence findings
require("confidence: low" in audit, "audit.md must mention confidence: low for no-evidence findings")

# Read-only constraint
require(
    "Read-only" in audit or "read-only" in audit or "MUST NOT modify" in audit,
    "audit.md must mention Read-only or MUST NOT modify constraint",
)

# Report sections
require("Instruction Map" in audit, "audit.md must include Instruction Map section")
require("Findings" in audit, "audit.md must include Findings section")
require("Metrics" in audit, "audit.md must include Metrics section")
require("Source Metadata" in audit, "audit.md must include Source Metadata section")
require(
    "memorylint-report.json" in audit,
    "audit.md must include machine-readable memorylint-report.json output",
)
require(
    "schema_version" in audit and "source_metadata" in audit,
    "audit.md must describe the machine-readable report schema",
)

# ── apply.md ─────────────────────────────────────────────────────────────────

require("$ARGUMENTS" in apply_cmd, "apply.md must include the $ARGUMENTS context block")

# Three modes
require("report-only" in apply_cmd, "apply.md must include report-only mode")
require("apply-safe-fixes" in apply_cmd, "apply.md must include apply-safe-fixes mode")
require("apply-all-approved" in apply_cmd, "apply.md must include apply-all-approved mode")

# Validation steps
require("Pre-Apply Checks" in apply_cmd, "apply.md must include Pre-Apply Checks")
require("Post-Apply Validation" in apply_cmd, "apply.md must include Post-Apply Validation")

# Rollback
require("Rollback" in apply_cmd, "apply.md must mention Rollback")

# AGENTS.md integrity check
require("AGENTS.md" in apply_cmd and "Integrity" in apply_cmd, "apply.md must include AGENTS.md integrity check")

# Hook consistency check
require(
    "Hook Consistency" in apply_cmd or "hook" in apply_cmd.lower(),
    "apply.md must include hook consistency check",
)
require(
    "memorylint-report.json" in apply_cmd,
    "apply.md must consume the machine-readable memorylint-report.json artifact",
)

# ── load-agents.md ───────────────────────────────────────────────────────────

require(
    "$ARGUMENTS" in load_agents,
    "load-agents.md must include the $ARGUMENTS context block",
)

# Mandatory failure / fail-fast
require(
    "Mandatory Failure Rule" in load_agents
    or "STOP immediately" in load_agents
    or "fail" in load_agents.lower(),
    "load-agents.md must include Mandatory Failure Rule or fail-fast language",
)

# Read-Only
require(
    "Read-Only" in load_agents or "read-only" in load_agents.lower(),
    "load-agents.md must mention Read-Only constraint",
)

# ── check-boundaries.md must NOT exist (old command removed) ─────────────────

require(
    not check_boundaries_path.exists(),
    "check-boundaries.md must NOT exist (old command was removed)",
)

# ── deterministic fixture scanner ───────────────────────────────────────────

require(
    fixture_scanner_path.exists(),
    "memorylint/scripts/scan_fixtures.py must exist",
)
require(
    fixture_scanner_test_path.exists(),
    "memorylint/tests/test-fixture-scanner.sh must exist",
)

# ── design document ─────────────────────────────────────────────────────────

require(design_path.exists(), "memorylint/DESIGN.md must exist")
for phrase in [
    "Product Boundary",
    "Trust Model",
    "Audit Pipeline",
    "Apply Gate",
    "Machine-Readable Report",
    "Regression Corpus",
]:
    require(phrase in design, f"memorylint/DESIGN.md must include '{phrase}'")

print("memorylint regression checks passed")
PY
