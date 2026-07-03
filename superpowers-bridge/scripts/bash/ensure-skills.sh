#!/usr/bin/env bash

# superpowers-bridge/scripts/bash/ensure-skills.sh
# Canonical helper for prerequisite checks, guidance output, and explicit adg installation.

set -eo pipefail

SKILL_LIST=(
  "test-driven-development"
  "brainstorming"
  "systematic-debugging"
  "receiving-code-review"
  "finishing-a-development-branch"
)

# Build --skill parameters for adg command
SKILL_PARAMS=()
for skill in "${SKILL_LIST[@]}"; do
  SKILL_PARAMS+=("--skill" "$skill")
done

check_npx() {
  local npx_path
  if npx_path=$(command -v npx 2>/dev/null); then
    echo "{\"npx_available\": true, \"npx_path\": \"$npx_path\"}"
    return 0
  else
    echo "{\"npx_available\": false, \"npx_path\": null}"
    return 2
  fi
}

print_guidance() {
  local skill_args=()
  for skill in "${SKILL_LIST[@]}"; do
    skill_args+=("--skill" "$skill")
  done

  cat <<EOF
💡 Install via adg (https://github.com/RbBtSn0w/adg):
   Compatible:   npx @rbbtsn0w/adg plugins add obra/superpowers -g
   Select global:npx @rbbtsn0w/adg skills add obra/superpowers ${skill_args[*]} --global -y
   Select local: npx @rbbtsn0w/adg skills add obra/superpowers ${skill_args[*]} -y

The compatible plugin path installs the complete upstream package. Superb uses
only the five skills listed by the selective commands.

Run /speckit.superb.check for full diagnostics and interactive installation.
EOF
}


run_install() {
  local approach="$1"
  local cmd=()

  # Ensure npx is available before attempting install
  if ! command -v npx &>/dev/null; then
    echo "ERROR: npx is not available in PATH." >&2
    exit 2
  fi

  case "$approach" in
    1)
      # Compatible path: installs the complete upstream plugin package.
      cmd=("npx" "@rbbtsn0w/adg" "plugins" "add" "obra/superpowers" "-g")
      ;;
    2)
      # Selective global skill install, when supported by the installed adg.
      cmd=("npx" "@rbbtsn0w/adg" "skills" "add" "obra/superpowers" "${SKILL_PARAMS[@]}" "--global" "-y")
      ;;
    3)
      # Selective project-local skill install, when supported by adg.
      cmd=("npx" "@rbbtsn0w/adg" "skills" "add" "obra/superpowers" "${SKILL_PARAMS[@]}" "-y")
      ;;
    *)
      echo "ERROR: Invalid approach option '$approach'." >&2
      exit 3
      ;;
  esac

  echo "Executing: ${cmd[*]}"
  # Execute the command
  if "${cmd[@]}"; then
    echo "SUCCESS: Skills installation completed successfully."
    exit 0
  else
    echo "ERROR: adg installation failed with exit code $?." >&2
    exit 1
  fi
}

# Parse command line options
APPROACH=""
CHECK_PREREQS=false
PRINT_GUIDANCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-prereqs)
      CHECK_PREREQS=true
      shift
      ;;
    --print-guidance)
      PRINT_GUIDANCE=true
      shift
      ;;
    --install)
      if [[ -n "$2" && "$2" =~ ^[1-3]$ ]]; then
        APPROACH="$2"
        shift 2
      else
        echo "ERROR: --install requires a value between 1 and 3." >&2
        exit 3
      fi
      ;;
    *)
      echo "ERROR: Unknown option '$1'." >&2
      exit 3
      ;;
  esac
done

if [ "$CHECK_PREREQS" = true ]; then
  check_npx
elif [ "$PRINT_GUIDANCE" = true ]; then
  print_guidance
elif [ -n "$APPROACH" ]; then
  run_install "$APPROACH"
else
  echo "ERROR: Missing required option --install, --check-prereqs or --print-guidance." >&2
  exit 3
fi
