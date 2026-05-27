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
import re
import sys

root = Path(sys.argv[1])
catalog = json.loads((root / "catalog.json").read_text(encoding="utf-8"))
root_readme = (root / "README.md").read_text(encoding="utf-8")
bridge_readme = (root / "superpowers-bridge" / "README.md").read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def unquote(value: str) -> str:
    value = value.strip()
    if (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        return value[1:-1]
    return value


def manifest_lines(extension_dir: str) -> list[str]:
    return (root / extension_dir / "extension.yml").read_text(encoding="utf-8").splitlines()


def manifest_scalar(lines: list[str], section: str, field: str) -> str:
    in_section = False
    section_indent = 0

    for line in lines:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))

        if stripped == f"{section}:":
            in_section = True
            section_indent = indent
            continue

        if in_section:
            if stripped and not stripped.startswith("#") and indent <= section_indent:
                break
            if indent == section_indent + 2:
                match = re.match(rf"^\s*{re.escape(field)}:\s*(.*?)\s*$", line)
                if match:
                    return unquote(match.group(1))

    raise SystemExit(f"Could not find {section}.{field} in extension.yml")


def count_manifest_commands(lines: list[str]) -> int:
    count = 0
    in_provides = False
    in_commands = False
    provides_indent = 0
    commands_indent = 0

    for line in lines:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))

        if stripped == "provides:":
            in_provides = True
            in_commands = False
            provides_indent = indent
            continue

        if in_provides and stripped and not stripped.startswith("#") and indent <= provides_indent:
            in_provides = False
            in_commands = False

        if in_provides and re.match(r"^\s*commands:\s*$", line):
            in_commands = True
            commands_indent = indent
            continue

        if in_commands:
            if stripped and not stripped.startswith("#") and indent <= commands_indent:
                in_commands = False
            elif re.match(r"^\s*-\s+name:\s+", line):
                count += 1

    return count


def count_manifest_hooks(lines: list[str]) -> int:
    count = 0
    in_hooks = False
    hooks_indent = 0

    for line in lines:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))

        if stripped == "hooks:":
            in_hooks = True
            hooks_indent = indent
            continue

        if in_hooks:
            if stripped and not stripped.startswith("#") and indent <= hooks_indent:
                break
            if indent == hooks_indent + 2 and re.match(r"^[a-zA-Z0-9_-]+:\s*$", stripped):
                count += 1

    return count


require(catalog.get("schema_version") == "1.0", "catalog.json must use schema_version 1.0")

extensions = catalog.get("extensions")
require(isinstance(extensions, dict), "catalog.json must declare an extensions mapping")

extension_sources = {
    "superb": {
        "directory": "superpowers-bridge",
        "asset": "superpowers-bridge.zip",
    },
    "memorylint": {
        "directory": "memorylint",
        "asset": "memorylint.zip",
    },
}

expected = {
    extension_id: {
        "version": manifest_scalar(lines := manifest_lines(source["directory"]), "extension", "version"),
        "author": manifest_scalar(lines, "extension", "author"),
        "download_url": (
            "https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/"
            f"{source['directory']}-v{manifest_scalar(lines, 'extension', 'version')}/{source['asset']}"
        ),
        "commands": count_manifest_commands(lines),
        "hooks": count_manifest_hooks(lines),
    }
    for extension_id, source in extension_sources.items()
}

for extension_id, expectation in expected.items():
    entry = extensions.get(extension_id)
    require(isinstance(entry, dict), f"catalog.json must include {extension_id}")
    require(entry.get("id") == extension_id, f"{extension_id} catalog id must match its key")
    require(entry.get("author") == expectation["author"], f"{extension_id} catalog author must match extension.yml")
    require(entry.get("version") == expectation["version"], f"{extension_id} catalog version is stale")
    require(entry.get("download_url") == expectation["download_url"], f"{extension_id} download_url is stale or not published")
    require(entry.get("download_url", "").startswith("https://"), f"{extension_id} download_url must use HTTPS")
    provides = entry.get("provides")
    require(isinstance(provides, dict), f"{extension_id} must declare provides metadata")
    require(provides.get("commands") == expectation["commands"], f"{extension_id} command count must match the published release bundle")
    require(provides.get("hooks") == expectation["hooks"], f"{extension_id} hook count must match the published release bundle")

catalog_url = "https://raw.githubusercontent.com/RbBtSn0w/spec-kit-extensions/main/catalog.json"
superb_version = expected["superb"]["version"]
required_snippets = [
    f"specify extension catalog add {catalog_url}",
    "--install-allowed",
    "specify extension add superb",
    "specify extension update superb",
    f"superpowers-bridge-v{superb_version}/superpowers-bridge.zip",
]

for snippet in required_snippets:
    require(snippet in root_readme, f"README.md must document catalog-managed updates with: {snippet}")
    require(snippet in bridge_readme, f"superpowers-bridge/README.md must document catalog-managed updates with: {snippet}")

print("catalog checks passed")
PY
