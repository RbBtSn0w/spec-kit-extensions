#!/usr/bin/env bash

set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import json
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
    (r"\.extensionignore", "Release Trigger must honor .extensionignore during zip assembly."),
    (r"pathspec", "Release Trigger must use pathspec-compatible ignore matching during packaging."),
    (r"pathspec==0\.12\.1", "Release Trigger must pin pathspec version for reproducible packaging."),
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
    (r"replace\(\"\\\\\", \"/\"\)", "Release Trigger must not rewrite backslashes in .extensionignore patterns."),
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

commit_payload_match = re.search(
    r"^\s*- name: Create release metadata commit and tag$\n.*?python3 - <<'PY'\n(?P<code>.*?)\n\s*PY$",
    trigger_text,
    re.MULTILINE | re.DOTALL,
)
if not commit_payload_match:
    print("Unable to locate the embedded Python release-commit payload script.", file=sys.stderr)
    sys.exit(1)

commit_payload_code = textwrap.dedent(commit_payload_match.group("code"))

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

            Install from release:

            https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/superpowers-bridge-v1.0.0/superpowers-bridge.zip
            https://github.com/RbBtSn0w/spec-kit-extensions/releases/download/memorylint-v1.3.0/memorylint.zip
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
    if "releases/download/superpowers-bridge-v1.3.0/superpowers-bridge.zip" not in root_readme:
        print("Release Trigger must update root README release download links for the released extension.", file=sys.stderr)
        sys.exit(1)
    if "releases/download/memorylint-v1.3.0/memorylint.zip" not in root_readme:
        print("Release Trigger must not update unrelated extension release download links.", file=sys.stderr)
        sys.exit(1)

    payload_file = root / "release-payload.json"
    env.update(
        {
            "DEFAULT_BRANCH": "main",
            "EXPECTED_HEAD_OID": "0123456789abcdef0123456789abcdef01234567",
            "GITHUB_REPO": "RbBtSn0w/spec-kit-extensions",
            "PAYLOAD_FILE": str(payload_file),
        }
    )

    result = subprocess.run(
        [sys.executable, "-c", commit_payload_code],
        cwd=root,
        env=env,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print("Embedded release-commit payload script failed unexpectedly.", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        sys.exit(1)

    payload = json.loads(payload_file.read_text(encoding="utf-8"))
    if "input" in payload:
        print("GraphQL request body must not put mutation variables at top-level input.", file=sys.stderr)
        sys.exit(1)
    if "variables" not in payload or "input" not in payload["variables"]:
        print("GraphQL request body must put mutation input under variables.input.", file=sys.stderr)
        sys.exit(1)

    mutation_input = payload["variables"]["input"]
    if mutation_input["branch"]["branchName"] != "main":
        print("Release commit payload must preserve the target default branch.", file=sys.stderr)
        sys.exit(1)
    if mutation_input["expectedHeadOid"] != env["EXPECTED_HEAD_OID"]:
        print("Release commit payload must preserve expectedHeadOid.", file=sys.stderr)
        sys.exit(1)

print("release workflow checks passed")
PY
