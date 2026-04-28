#!/usr/bin/env bash

# Shared shell-file discovery for repo-local dev tools. Deployment uses the
# POSIX home-tree manifest helper instead.

dotfiles_shell_file_abs_path() {
  local file="$1"

  case "$file" in
    /*) printf '%s\n' "$file" ;;
    *) printf '%s\n' "$PWD/$file" ;;
  esac
}

dotfiles_have_command() {
  # Hide command resolution output while preserving command lookup status.
  command -v "$1" >/dev/null 2>&1
}

dotfiles_shell_file_rel_path() {
  local repo_root="$1"
  local abs_path="$2"

  case "$abs_path" in
    "$repo_root"/*) printf '%s\n' "${abs_path#"$repo_root"/}" ;;
    *) printf '%s\n' "$abs_path" ;;
  esac
}

dotfiles_shell_file_dialect() {
  local file="$1"
  local rel_path="$2"
  local first_line

  first_line="$(sed -n '1p' "$file")"

  # Trust explicit shell shebangs first; path conventions cover sourced fragments.
  case "$first_line" in
    '#!'*bash*) printf 'bash\n' && return 0 ;;
    '#!'*zsh*) printf 'zsh\n' && return 0 ;;
    '#!'*sh*) printf 'sh\n' && return 0 ;;
  esac

  case "$rel_path" in
    home/.zprofile | home/.zshrc | *.zsh)
      printf 'zsh\n'
      ;;
    *.bash)
      printf 'bash\n'
      ;;
    home/.profile | home/.shrc | *.sh)
      printf 'sh\n'
      ;;
    *)
      return 1
      ;;
  esac
}

dotfiles_emit_tracked_shell_files() {
  local repo_root="$1"
  local rel_path
  local abs_path

  git -C "$repo_root" ls-files -z -- bootstrap.sh home scripts settings test \
    | while IFS= read -r -d '' rel_path; do
      abs_path="$repo_root/$rel_path"
      [[ -f "$abs_path" ]] || continue
      dotfiles_shell_file_dialect "$abs_path" "$rel_path" >/dev/null || continue
      printf '%s\0' "$abs_path"
    done
}
