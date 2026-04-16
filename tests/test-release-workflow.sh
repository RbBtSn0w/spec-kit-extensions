#!/usr/bin/env bash

set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import os
import re
import subprocess
import sys
import tempfile
import textwrap

trigger_path = Path(".github/workflows/release-trigger.yml")
trigger_text = trigger_path.read_text(encoding="utf-8")

checks = [
    (r"^on:\n  workflow_dispatch:$", "Release Trigger must remain manually dispatched."),
    (r"^\s*- name: Create extension zip$", "Release Trigger must build the extension zip itself."),
    (r"^\s*- name: Generate release notes$", "Release Trigger must generate release notes itself."),
    (r"gh release create", "Release Trigger must create the GitHub Release itself."),
    (r"createCommitOnBranch", "Release Trigger must create the release metadata commit via GitHub GraphQL."),
    (r"gh api graphql", "Release Trigger must call GitHub GraphQL when preparing the release commit."),
    (r"--verify-tag", "Release Trigger must verify that the release tag already exists before publishing."),
]

for pattern, message in checks:
    if not re.search(pattern, trigger_text, re.MULTILINE):
        print(message, file=sys.stderr)
        sys.exit(1)

for pattern, message in [
    (r"git commit -m ", "Release Trigger must not create an unsigned local git commit for release metadata."),
]:
    if re.search(pattern, trigger_text, re.MULTILINE):
        print(message, file=sys.stderr)
        sys.exit(1)

release_path = Path(".github/workflows/release.yml")
if release_path.exists():
    release_text = release_path.read_text(encoding="utf-8")
    if re.search(r"^on:\n  push:\n    tags:\n", release_text, re.MULTILINE):
        print("Separate tag-push release workflow still exists; release creation is still split across workflows.", file=sys.stderr)
        sys.exit(1)

prepare_match = re.search(
    r"^\s*- name: Prepare release files$\n.*?python3 - <<'PY'\n(?P<code>.*?)\n\s*PY$",
    trigger_text,
    re.MULTILINE | re.DOTALL,
)
if not prepare_match:
    print("Unable to locate the embedded Python release-preparation script.", file=sys.stderr)
    sys.exit(1)

prepare_code = textwrap.dedent(prepare_match.group("code"))

with tempfile.TemporaryDirectory() as tmpdir:
    root = Path(tmpdir)
    extension_dir = root / "superpowers-bridge"
    extension_dir.mkdir()

    (root / "README.md").write_text(
        textwrap.dedent(
            """\
            # Spec Kit Extensions

            | Extension | Version | Description |
            |---|---|---|
            | [Superpowers Bridge](./superpowers-bridge) | 1.0.0 | Bridge package |
            | [MemoryLint](./memorylint) | 1.3.0 | Memory governance |
            """
        ),
        encoding="utf-8",
    )
    (extension_dir / "extension.yml").write_text(
        textwrap.dedent(
            """\
            schema_version: "1.0"
            extension:
              id: superb
              version: 1.0.0
            """
        ),
        encoding="utf-8",
    )
    (extension_dir / "README.md").write_text(
        textwrap.dedent(
            """\
            Install from release:

            https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.0.0/superpowers-bridge.zip
            """
        ),
        encoding="utf-8",
    )
    (extension_dir / "CHANGELOG.md").write_text(
        textwrap.dedent(
            """\
            ## [Unreleased]

            ### Changed

            - Sync release metadata.
            """
        ),
        encoding="utf-8",
    )

    env = os.environ.copy()
    env.update(
        {
            "EXTENSION_ID": "superpowers-bridge",
            "VERSION": "1.3.0",
            "TODAY": "2026-04-17",
            "GITHUB_SERVER_URL": "https://github.com",
            "GITHUB_REPOSITORY": "RbBtSn0w/spec-kit-extensions",
        }
    )

    result = subprocess.run(
        [sys.executable, "-c", prepare_code],
        cwd=root,
        env=env,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print("Embedded release-preparation script failed unexpectedly.", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        sys.exit(1)

    root_readme = (root / "README.md").read_text(encoding="utf-8")
    if "| [Superpowers Bridge](./superpowers-bridge) | 1.3.0 | Bridge package |" not in root_readme:
        print("Release Trigger must update the root README version table for the released extension.", file=sys.stderr)
        sys.exit(1)

print("release workflow checks passed")
PY
