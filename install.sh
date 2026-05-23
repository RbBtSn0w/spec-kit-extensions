#!/usr/bin/env bash

# Spec Kit Extensions Installer
# Detects the environment and automatically registers all available extensions.

set -euo pipefail

# Print banner
echo "======================================"
echo "  Spec Kit Extensions Installer       "
echo "======================================"

# 1. Detect if specify is installed
if ! command -v specify &> /dev/null; then
    echo "ERROR: 'specify' command-line interface not found." >&2
    echo "Please install Spec Kit CLI first, e.g. via npm or global package manager." >&2
    exit 1
fi

# Get the directory where this script is located (the project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the extensions to register
EXTENSIONS=("superpowers-bridge" "memorylint")
REGISTERED_COUNT=0

for ext in "${EXTENSIONS[@]}"; do
    EXT_DIR="$SCRIPT_DIR/$ext"
    if [ -d "$EXT_DIR" ] && [ -f "$EXT_DIR/extension.yml" ]; then
        echo "Found extension: $ext"
        echo "Registering $ext via 'specify extension add --dev'..."
        if specify extension add --dev "$EXT_DIR"; then
            echo "Successfully registered $ext."
            REGISTERED_COUNT=$((REGISTERED_COUNT + 1))
        else
            echo "ERROR: Failed to register $ext." >&2
            exit 1
        fi
    else
        echo "Warning: Extension directory '$ext' not found or missing 'extension.yml' under '$SCRIPT_DIR'." >&2
    fi
done

echo "======================================"
echo "Installation complete. Registered $REGISTERED_COUNT extension(s)."
echo "======================================"
