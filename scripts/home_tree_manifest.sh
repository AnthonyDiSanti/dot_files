#!/bin/sh

# Helpers for deriving a managed-home manifest from the tracked `home/` tree.

dotfiles_emit_tracked_home_sources() {
  repo_root=$1
  git -C "$repo_root" ls-files --cached --full-name -- home
}

dotfiles_emit_manifest() {
  repo_root=$1

  dotfiles_emit_tracked_home_sources "$repo_root" |
    while IFS= read -r source_path; do
      [ -n "$source_path" ] || continue

      rel_path=${source_path#home/}
      printf 'leaf %s %s\n' "$rel_path" "$source_path"

      parent_path=$rel_path
      while :; do
        parent_path=$(dirname "$parent_path")
        [ "$parent_path" = "." ] && break
        printf 'dir %s\n' "$parent_path"
      done
    done |
    LC_ALL=C sort -u
}

dotfiles_emit_state_manifest() {
  repo_root=$1

  dotfiles_emit_manifest "$repo_root" |
    while IFS=' ' read -r kind rel_path source_path; do
      case $kind in
        dir|leaf) printf '%s %s\n' "$kind" "$rel_path" ;;
      esac
    done |
    LC_ALL=C sort -u
}

dotfiles_emit_managed_paths() {
  repo_root=$1

  dotfiles_emit_state_manifest "$repo_root" |
    while IFS=' ' read -r kind rel_path; do
      printf '%s\n' "$rel_path"
    done
}
