#!/usr/bin/env bash

set -euo pipefail

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi is required. Install it for your OS: https://www.chezmoi.io/install/" >&2
  exit 1
fi

dotfiles_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
config_file="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"
config_template="$dotfiles_dir/home/.chezmoi.toml.tmpl"

# Regenerate config only when needed; repeated applies should be clean.
if [[ ! -e "$config_file" || "$config_template" -nt "$config_file" ]]; then
  chezmoi --source "$dotfiles_dir" apply --init "$@"
else
  chezmoi --source "$dotfiles_dir" apply "$@"
fi
