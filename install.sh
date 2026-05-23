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

# Define the extensions to register by discovering extension.yml files
REGISTERED_COUNT=0

for EXT_DIR in "$SCRIPT_DIR"/*/ ; do
    if [ -f "${EXT_DIR}extension.yml" ]; then
        ext=$(basename "$EXT_DIR")
        echo "Found extension: $ext"
        echo "Registering $ext via 'specify extension add --dev'..."
        if specify extension add --dev "$EXT_DIR"; then
            echo "Successfully registered $ext."
            REGISTERED_COUNT=$((REGISTERED_COUNT + 1))
        else
            echo "ERROR: Failed to register $ext." >&2
            exit 1
        fi
    fi
done

echo "======================================"
echo "Installation complete. Registered $REGISTERED_COUNT extension(s)."
echo "======================================"
