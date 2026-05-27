#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find_python3() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1 && python -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1; then
    echo "python"
  else
    echo "ERROR: test-catalog.sh requires Python 3 on PATH" >&2
    exit 1
  fi
}

PYTHON_BIN=$(find_python3)

"$PYTHON_BIN" - "$ROOT_DIR" <<'PY'
from pathlib import Path
import json
import sys

root = Path(sys.argv[1])
catalog = json.loads((root / "catalog.json").read_text(encoding="utf-8"))
root_readme = (root / "README.md").read_text(encoding="utf-8")
bridge_readme = (root / "superpowers-bridge" / "README.md").read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


require(catalog.get("schema_version") == "1.0", "catalog.json must use schema_version 1.0")

extensions = catalog.get("extensions")
require(isinstance(extensions, dict), "catalog.json must declare an extensions mapping")

expected = {
    "superb": {
        "version": "1.5.0",
        "download_url": "https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.5.0/superpowers-bridge.zip",
        "commands": 9,
        "hooks": 4,
    },
    "memorylint": {
        "version": "1.5.0",
        "download_url": "https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/memorylint-v1.5.0/memorylint.zip",
        "commands": 3,
        "hooks": 3,
    },
}

for extension_id, expectation in expected.items():
    entry = extensions.get(extension_id)
    require(isinstance(entry, dict), f"catalog.json must include {extension_id}")
    require(entry.get("id") == extension_id, f"{extension_id} catalog id must match its key")
    require(entry.get("version") == expectation["version"], f"{extension_id} catalog version is stale")
    require(entry.get("download_url") == expectation["download_url"], f"{extension_id} download_url is stale or not published")
    require(entry.get("download_url", "").startswith("https://"), f"{extension_id} download_url must use HTTPS")
    provides = entry.get("provides")
    require(isinstance(provides, dict), f"{extension_id} must declare provides metadata")
    require(provides.get("commands") == expectation["commands"], f"{extension_id} command count must match the published release bundle")
    require(provides.get("hooks") == expectation["hooks"], f"{extension_id} hook count must match the published release bundle")

catalog_url = "https://raw.githubusercontent.com/RbBtSn0w/spec-kit-extensions/main/catalog.json"
required_snippets = [
    f"specify extension catalog add {catalog_url}",
    "--install-allowed",
    "specify extension add superb",
    "specify extension update superb",
    "superpowers-bridge-v1.5.0/superpowers-bridge.zip",
]

for snippet in required_snippets:
    require(snippet in root_readme, f"README.md must document catalog-managed updates with: {snippet}")
    require(snippet in bridge_readme, f"superpowers-bridge/README.md must document catalog-managed updates with: {snippet}")

print("catalog checks passed")
PY
