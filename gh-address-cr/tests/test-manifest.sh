#!/usr/bin/env bash
# ==============================================================================
# Manifest contract test for gh-address-cr extension
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

python3 - <<PY
from pathlib import Path
import re
import sys

ext_dir = Path("$EXT_DIR")
manifest_path = ext_dir / "extension.yml"

if not manifest_path.exists():
    sys.exit(f"Missing {manifest_path}")

text = manifest_path.read_text(encoding="utf-8")

# 1. Schema version
if not re.search(r'^schema_version:\s*"1\.0"', text, re.MULTILINE):
    sys.exit("Manifest must declare schema_version: '1.0'")

# 2. Extension ID
id_match = re.search(r'^\s*id:\s*["\']?([^"\']+)["\']?', text, re.MULTILINE)
if not id_match or id_match.group(1).strip() != "gh-address-cr":
    sys.exit(f"Manifest extension.id must be 'gh-address-cr', got: {id_match.group(1) if id_match else 'None'}")

# 3. Description length <= 200 chars
desc_match = re.search(r'^\s*description:\s*["\']?([^"\']+)["\']?', text, re.MULTILINE)
if not desc_match:
    sys.exit("Missing extension.description")
desc = desc_match.group(1).strip()
if len(desc) > 200:
    sys.exit(f"extension.description too long ({len(desc)} > 200 chars): {desc}")

# 4. Command names must follow speckit.{extension-id}.{command-name}
cmd_names = re.findall(r'-\s*name:\s*["\']?(speckit\.[^"\'\s]+)["\']?', text)
if len(cmd_names) != 4:
    sys.exit(f"Expected 4 commands, found {len(cmd_names)}: {cmd_names}")

expected_cmds = [
    "speckit.gh-address-cr.address",
    "speckit.gh-address-cr.review",
    "speckit.gh-address-cr.gate",
    "speckit.gh-address-cr.doctor",
]
for cmd in expected_cmds:
    if cmd not in cmd_names:
        sys.exit(f"Missing expected command: {cmd}")

# 5. Command files must exist
cmd_files = re.findall(r'file:\s*["\']?([^"\'\s]+)["\']?', text)
for f in cmd_files:
    file_path = ext_dir / f
    if not file_path.exists():
        sys.exit(f"Declared command file does not exist: {file_path}")

# 6. Config templates must exist
tmpl_files = re.findall(r'template:\s*["\']?([^"\'\s]+)["\']?', text)
for t in tmpl_files:
    tmpl_path = ext_dir / t
    if not tmpl_path.exists():
        sys.exit(f"Declared config template does not exist: {tmpl_path}")

print("gh-address-cr manifest contract passed")
PY
