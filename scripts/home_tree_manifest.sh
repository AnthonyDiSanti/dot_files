#!/bin/sh

# Helpers for deriving a managed-home manifest from the checked-out `home/` tree.

dotfiles_emit_home_sources() {
  repo_root=$1
  home_root=$repo_root/home
  use_git_ignore=0

  [ -d "$home_root" ] || return 0

  if command -v git >/dev/null 2>&1 \
    && git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    use_git_ignore=1
  fi

  # Do not follow symlinks: a symlinked directory in `home/` is itself the
  # managed leaf, preserving the literal target-tree shape.
  find "$home_root" \
    ! -type d -print \
    | while IFS= read -r source_path; do
      case $source_path in
        "$repo_root"/*)
          rel_source_path=${source_path#"$repo_root"/}
          if [ "$use_git_ignore" -eq 1 ] \
            && git -C "$repo_root" check-ignore -q -- "$rel_source_path"; then
            continue
          fi
          printf '%s\n' "$rel_source_path"
          ;;
      esac
    done
}

dotfiles_emit_manifest() {
  repo_root=$1

  dotfiles_emit_home_sources "$repo_root" \
    | while IFS= read -r source_path; do
      [ -n "$source_path" ] || continue

      rel_path=${source_path#home/}
      printf 'leaf\t%s\t%s\n' "$rel_path" "$source_path"

      parent_path=$rel_path
      while :; do
        parent_path=$(dirname "$parent_path")
        [ "$parent_path" = "." ] && break
        printf 'dir\t%s\n' "$parent_path"
      done
    done \
    | LC_ALL=C sort -u
}

dotfiles_emit_state_manifest() {
  repo_root=$1

  dotfiles_emit_manifest "$repo_root" \
    | while IFS="$(printf '\t')" read -r kind rel_path source_path; do
      case $kind in
        dir | leaf) printf '%s\t%s\n' "$kind" "$rel_path" ;;
      esac
    done \
    | LC_ALL=C sort -u
}

dotfiles_emit_managed_paths() {
  repo_root=$1

  dotfiles_emit_state_manifest "$repo_root" \
    | while IFS="$(printf '\t')" read -r kind rel_path; do
      printf '%s\n' "$rel_path"
    done
}
