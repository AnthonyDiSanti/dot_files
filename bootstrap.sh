#!/bin/sh

set -eu

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi is required. Install it for your OS: https://www.chezmoi.io/install/" >&2
  exit 1
fi

dotfiles_dir="$(
  CDPATH= cd "$(dirname "$0")" || exit 1
  pwd
)"
chezmoi_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
chezmoi_state_file="$chezmoi_state_dir/chezmoistate.boltdb"

# If this is a real git checkout, hydrate submodules before applying dotfiles.
# Skip quietly for manually copied subsets where .git/.gitmodules are absent.
if command -v git >/dev/null 2>&1 \
  && [ -r "$dotfiles_dir/.gitmodules" ] \
  && git -C "$dotfiles_dir" rev-parse --show-toplevel >/dev/null 2>&1; then
  git -C "$dotfiles_dir" submodule update --init --recursive
fi

# Ignore any host-local chezmoi config so bootstrap stays self-contained.
mkdir -p "$chezmoi_state_dir"
exec chezmoi \
  --config /dev/null \
  --config-format toml \
  --persistent-state "$chezmoi_state_file" \
  --source "$dotfiles_dir" \
  --mode symlink \
  apply \
  "$@"
