# Technical Plan: Repository Installer (Phase 1)

## Problem

Users currently have to remember each extension directory and run `specify extension add --dev ./path/to/extension` repeatedly. That creates setup friction and path mistakes before they can test the actual evidence-first workflow.

## Product Boundary

The installer is a local repository convenience, not a remote one-line bootstrapper. It assumes the repository has already been cloned so extension directories and `extension.yml` files exist next to the script.

## Proposed Solution

Provide a root-level `install.sh` that:

- detects whether `specify` is available;
- resolves the repository root from the script location;
- discovers top-level directories containing `extension.yml`;
- registers each discovered extension with `specify extension add --dev`.

## Usage

```bash
git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
cd spec-kit-extensions
./install.sh
```

## Non-Goals

- Do not curl-pipe the script directly from the repository unless the script is changed to clone or download release assets first.
- Do not register directories without `extension.yml`.
- Do not make the installer responsible for installing Spec Kit itself.

## Verification

- Run `bash -n install.sh`.
- Run the installer manually in an environment with `specify` installed.
- Confirm it reports every discovered extension and stops on registration failure.
