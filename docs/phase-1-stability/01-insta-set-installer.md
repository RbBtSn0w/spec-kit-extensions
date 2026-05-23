# Technical Plan: Insta-Set Installer (Phase 1)

## Problem
Currently, users have to clone the repository and run `specify extension add --dev ./path/to/extension` for each extension. This is manual and prone to path errors.

## Proposed Solution
Provide a centralized installer script `install.sh` at the root of the repository that detects the environment and registers all extensions (or selected ones) automatically.

### Features
- Detect if `specify` is installed.
- Auto-detect the project root.
- Register all extensions discovered via `extension.yml`.
- Provide a clear instruction sequence:
  ```bash
  git clone https://github.com/RbBtSn0w/spec-kit-extensions.git
  cd spec-kit-extensions
  ./install.sh
  ```

## Technical Feasibility Verification

### 1. Registering extensions via script
We can use `specify extension add --dev` in a loop.

### 2. Environment Detection
Standard bash checks for `command -v specify`.

## Feasibility Test
```bash
#!/bin/bash
if ! command -v specify &> /dev/null; then
    echo "specify-cli not found. Please install it first."
    exit 1
fi

EXTENSIONS=("superpowers-bridge" "memorylint")
for ext in "${EXTENSIONS[@]}"; do
    if [ -d "$ext" ]; then
        echo "Registering $ext..."
        # specify extension add --dev "./$ext" --force
    fi
done
```
