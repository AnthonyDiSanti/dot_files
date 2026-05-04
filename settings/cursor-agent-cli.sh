#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
managed_settings="$script_dir/cursor-agent-cli.json"

dry_run=0

usage() {
  cat <<'EOF'
Usage: settings/cursor-agent-cli.sh [--dry-run]

Merges repo-managed Cursor Agent CLI preferences into the live
cli-config.json while preserving Cursor-owned auth, cache, and local state.
EOF
}

cursor_config_dir() {
  if [[ -n "${CURSOR_CONFIG_DIR:-}" ]]; then
    printf '%s\n' "$CURSOR_CONFIG_DIR"
  elif [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
    printf '%s\n' "$XDG_CONFIG_HOME/cursor"
  else
    printf '%s\n' "$HOME/.cursor"
  fi
}

require_file() {
  local file=$1

  [[ -f "$file" ]] || {
    echo "cursor-agent-cli: missing required file: $file" >&2
    exit 1
  }
}

merge_config() {
  local config_file=$1
  local output_file=$2

  if [[ -f "$config_file" ]]; then
    jq -s '.[0] * .[1]' \
      "$config_file" \
      "$managed_settings" >"$output_file"
  else
    jq -S . "$managed_settings" >"$output_file"
  fi
}

configs_match() {
  local left_file=$1
  local right_file=$2

  # Cursor may reorder CLI-managed keys, so compare canonical JSON content.
  cmp -s <(jq -S . "$left_file") <(jq -S . "$right_file")
}

while (($#)); do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    --help | -h)
      usage
      exit 0
      ;;
    *)
      echo "cursor-agent-cli: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "cursor-agent-cli: jq is required to merge Cursor CLI JSON config" >&2
  exit 127
fi

require_file "$managed_settings"

config_dir="$(cursor_config_dir)"
config_file="$config_dir/cli-config.json"
tmp_dir="${TMPDIR:-/tmp}"
tmp_file="$(mktemp "$tmp_dir/cursor-agent-cli.XXXXXX")"
trap 'rm -f "$tmp_file"' EXIT

merge_config "$config_file" "$tmp_file"
jq empty "$tmp_file"

model="$(jq -r '.model.displayModelId // .model.modelId // "unknown"' "$tmp_file")"

if [[ -f "$config_file" ]] && configs_match "$config_file" "$tmp_file"; then
  printf 'cursor-agent-cli: already up to date: %s (%s)\n' "$config_file" "$model"
  exit 0
fi

if ((dry_run)); then
  printf 'cursor-agent-cli: would update: %s (%s)\n' "$config_file" "$model"
  exit 0
fi

mkdir -p "$config_dir"
if [[ -f "$config_file" && ! -e "$config_file.bak-dotfiles" ]]; then
  cp -p "$config_file" "$config_file.bak-dotfiles"
fi

mv "$tmp_file" "$config_file"
trap - EXIT
printf 'cursor-agent-cli: updated: %s (%s)\n' "$config_file" "$model"
