#!/usr/bin/env bash

# superpowers-bridge/scripts/bash/resolve-skill.sh
# Canonical skill discovery helper for direct skill roots and plugin-provided skills.

set -euo pipefail

SKILL_NAME=""
WORKSPACE_ROOT=""

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s' "$value"
}

emit_found() {
  local scope="$1"
  local install_type="$2"
  local path="$3"

  printf '{"available":true,"skill":"%s","source":"%s","install_type":"%s","path":"%s"}\n' \
    "$(json_escape "$SKILL_NAME")" \
    "$(json_escape "$scope")" \
    "$(json_escape "$install_type")" \
    "$(json_escape "$path")"
}

emit_missing() {
  printf '{"available":false,"skill":"%s","source":null,"install_type":null,"path":null}\n' \
    "$(json_escape "$SKILL_NAME")"
}

check_direct_root() {
  local scope="$1"
  local root="$2"
  local candidate="$root/.agents/skills/$SKILL_NAME/SKILL.md"

  if [ -r "$candidate" ]; then
    emit_found "$scope" "skill-root" "$candidate"
    return 0
  fi

  return 1
}

check_plugin_root() {
  local scope="$1"
  local root="$2"
  local candidate
  local patterns=(
    "$root/.agents/plugins/*/skills/$SKILL_NAME/SKILL.md"
    "$root/.agents/plugins/*/*/skills/$SKILL_NAME/SKILL.md"
  )

  for pattern in "${patterns[@]}"; do
    while IFS= read -r candidate; do
      if [ -r "$candidate" ]; then
        emit_found "$scope" "plugin" "$candidate"
        return 0
      fi
    done < <(compgen -G "$pattern" | LC_ALL=C sort || true)
  done

  return 1
}

find_workspace_root() {
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.specify" || -d "$dir/.git" || -d "$dir/.agents" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done

  printf '%s\n' "$PWD"
}

resolve_skill() {
  WORKSPACE_ROOT=$(find_workspace_root)

  check_direct_root "workspace" "$WORKSPACE_ROOT" && return 0
  check_plugin_root "workspace" "$WORKSPACE_ROOT" && return 0
  check_direct_root "global" "$HOME" && return 0
  check_plugin_root "global" "$HOME" && return 0

  emit_missing
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)
      if [[ -n "${2:-}" ]]; then
        SKILL_NAME="$2"
        shift 2
      else
        echo "ERROR: --skill requires a skill name." >&2
        exit 2
      fi
      ;;
    *)
      echo "ERROR: Unknown option '$1'." >&2
      exit 2
      ;;
  esac
done

if [[ -z "$SKILL_NAME" ]]; then
  echo "ERROR: Missing required option --skill." >&2
  exit 2
fi

resolve_skill
