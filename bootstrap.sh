#!/bin/sh

set -eu

dry_run=0
verbose=0
list_managed=0
tmp_paths=

cleanup() {
  for path in $tmp_paths; do
    rm -f "$path"
  done
}

make_temp_file() {
  path=$(mktemp)
  tmp_paths="${tmp_paths}${tmp_paths:+ }${path}"
  printf '%s\n' "$path"
}

log_action() {
  if [ "$dry_run" -eq 1 ] || [ "$verbose" -eq 1 ]; then
    printf '%s\n' "$1"
  fi
}

remove_path() {
  rel_path=$1
  target_path=$HOME/$rel_path

  if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
    return 0
  fi

  log_action "remove $target_path"
  [ "$dry_run" -eq 1 ] || rm -rf "$target_path"
}

remove_dir_if_empty() {
  rel_path=$1
  target_path=$HOME/$rel_path

  if [ -L "$target_path" ] || [ -f "$target_path" ]; then
    remove_path "$rel_path"
    return 0
  fi

  if [ ! -d "$target_path" ]; then
    return 0
  fi

  if [ -z "$(ls -A "$target_path" 2>/dev/null)" ]; then
    log_action "rmdir $target_path"
    [ "$dry_run" -eq 1 ] || rmdir "$target_path"
  fi
}

ensure_directory() {
  rel_path=$1
  target_path=$HOME/$rel_path

  if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
    return 0
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    log_action "mkdir $target_path (replace existing)"
    [ "$dry_run" -eq 1 ] || rm -rf "$target_path"
  else
    log_action "mkdir $target_path"
  fi

  [ "$dry_run" -eq 1 ] || mkdir -p "$target_path"
}

ensure_leaf_symlink() {
  rel_path=$1
  source_path=$2
  target_path=$HOME/$rel_path
  source_abs_path=$dotfiles_dir/$source_path

  if [ -L "$target_path" ]; then
    current_target=$(readlink "$target_path" 2>/dev/null || true)
    if [ "$current_target" = "$source_abs_path" ]; then
      return 0
    fi
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    log_action "link $target_path -> $source_abs_path (replace existing)"
    [ "$dry_run" -eq 1 ] || rm -rf "$target_path"
  else
    log_action "link $target_path -> $source_abs_path"
  fi

  [ "$dry_run" -eq 1 ] || ln -s "$source_abs_path" "$target_path"
}

remove_stale_paths() {
  stale_manifest=$1

  while IFS=' ' read -r kind rel_path; do
    [ "$kind" = "leaf" ] || continue
    remove_path "$rel_path"
  done <"$stale_manifest"

  awk '$1 == "dir" { print length($2), $2 }' "$stale_manifest" |
    LC_ALL=C sort -rn |
    while IFS=' ' read -r _depth rel_path; do
      [ -n "${rel_path:-}" ] || continue
      remove_dir_if_empty "$rel_path"
    done
}

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--dry-run] [--verbose] [--list-managed]

  --dry-run       Print pending changes without applying them.
  --verbose       Print changes while applying them.
  --list-managed  Print the managed target paths under $HOME.
EOF
}

while [ "$#" -gt 0 ]; do
  case $1 in
    --dry-run)
      dry_run=1
      ;;
    --verbose)
      verbose=1
      ;;
    --list-managed)
      list_managed=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'bootstrap: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to bootstrap this repo" >&2
  exit 1
fi

dotfiles_dir="$(
  CDPATH= cd "$(dirname "$0")" || exit 1
  pwd
)"

bootstrap_helper="$dotfiles_dir/scripts/home_tree_manifest.sh"
if [ ! -r "$bootstrap_helper" ]; then
  printf 'bootstrap: missing required helper: %s\n' "$bootstrap_helper" >&2
  exit 1
fi

. "$bootstrap_helper"
trap cleanup EXIT HUP INT TERM

if [ "$list_managed" -eq 1 ]; then
  dotfiles_emit_managed_paths "$dotfiles_dir"
  exit 0
fi

# If this is a real git checkout, hydrate submodules before linking dotfiles.
# Skip quietly for manually copied subsets where .git/.gitmodules are absent.
if [ -r "$dotfiles_dir/.gitmodules" ] \
  && git -C "$dotfiles_dir" rev-parse --show-toplevel >/dev/null 2>&1; then
  git -C "$dotfiles_dir" submodule update --init --recursive
fi

current_manifest=$(make_temp_file)
current_state=$(make_temp_file)
stale_manifest=$(make_temp_file)
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
state_file="$state_dir/managed-paths"

dotfiles_emit_manifest "$dotfiles_dir" >"$current_manifest"
dotfiles_emit_state_manifest "$dotfiles_dir" >"$current_state"

if [ -r "$state_file" ]; then
  comm -23 "$state_file" "$current_state" >"$stale_manifest" || true
else
  : >"$stale_manifest"
fi

remove_stale_paths "$stale_manifest"

while IFS=' ' read -r kind rel_path source_path; do
  [ "$kind" = "dir" ] || continue
  ensure_directory "$rel_path"
done <"$current_manifest"

while IFS=' ' read -r kind rel_path source_path; do
  [ "$kind" = "leaf" ] || continue
  ensure_leaf_symlink "$rel_path" "$source_path"
done <"$current_manifest"

if [ "$dry_run" -eq 0 ]; then
  mkdir -p "$state_dir"
  cp "$current_state" "$state_file"
fi
