#!/usr/bin/env bash

set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import re
import sys

trigger_path = Path(".github/workflows/release-trigger.yml")
trigger_text = trigger_path.read_text(encoding="utf-8")

checks = [
    (r"^on:\n  workflow_dispatch:$", "Release Trigger must remain manually dispatched."),
    (r"^\s*- name: Create extension zip$", "Release Trigger must build the extension zip itself."),
    (r"^\s*- name: Generate release notes$", "Release Trigger must generate release notes itself."),
    (r"gh release create", "Release Trigger must create the GitHub Release itself."),
]

for pattern, message in checks:
    if not re.search(pattern, trigger_text, re.MULTILINE):
        print(message, file=sys.stderr)
        sys.exit(1)

release_path = Path(".github/workflows/release.yml")
if release_path.exists():
    release_text = release_path.read_text(encoding="utf-8")
    if re.search(r"^on:\n  push:\n    tags:\n", release_text, re.MULTILINE):
        print("Separate tag-push release workflow still exists; release creation is still split across workflows.", file=sys.stderr)
        sys.exit(1)

print("release workflow checks passed")
PY
