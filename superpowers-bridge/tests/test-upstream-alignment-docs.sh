#!/usr/bin/env bash
# US3 / US4: Quickstart documentation and compatibility scenarios remain machine-verified.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PYTHON_BIN="$(command -v python3 || command -v python)"

"$PYTHON_BIN" - "$ROOT_DIR" <<'PY'
from pathlib import Path
import json
import sys

root = Path(sys.argv[1])
root_readme = (root / "README.md").read_text(encoding="utf-8")
memorylint_readme = (root / "memorylint/README.md").read_text(encoding="utf-8")
bridge_readme = (root / "superpowers-bridge/README.md").read_text(encoding="utf-8")
extensions = (root / ".specify/extensions.yml").read_text(encoding="utf-8")
catalog = json.loads((root / "catalog.json").read_text(encoding="utf-8"))

if "`review` vs `converge`" not in bridge_readme:
    raise SystemExit("FAIL: bridge README lacks the review-vs-converge boundary")
for token in ("Plan-stage prevention", "Delivery-stage remediation", "after_converge"):
    if token not in bridge_readme:
        raise SystemExit(f"FAIL: bridge README lacks convergence documentation: {token}")

for name, text in (("README.md", root_readme), ("memorylint/README.md", memorylint_readme)):
    if "opt-in" not in text or "0.12" not in text:
        raise SystemExit(f"FAIL: {name} lacks agent-context opt-in documentation")
if "full opt-in extension" not in extensions or "only take effect when" not in extensions:
    raise SystemExit("FAIL: .specify/extensions.yml lacks enabled-only agent-context guidance")

for extension_id in ("superb", "memorylint"):
    version_range = catalog["extensions"][extension_id]["requires"]["speckit_version"]
    if version_range != ">=0.12.0":
        raise SystemExit(
            f"FAIL: {extension_id} compatibility must cover current Spec Kit 0.12+, got {version_range}"
        )
PY

echo "PASS: test-upstream-alignment-docs.sh"
