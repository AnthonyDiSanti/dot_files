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

  case "$rel_path" in
    home/.zprofile | home/.zshrc | home/.config/zsh/*.zsh | test/fixtures/verify/*.zsh | *.zsh)
      printf 'zsh\n'
      ;;
    bootstrap.sh | home/.profile | home/.shrc | home/.local/bin/make-chrome-app)
      printf 'sh\n'
      ;;
    home/.config/shell/*.sh)
      printf 'sh\n'
      ;;
    *.bash | home/.bash_profile | home/.bashrc)
      printf 'bash\n'
      ;;
    *.sh)
      first_line="$(sed -n '1p' "$file")"
      case "$first_line" in
        *bash*) printf 'bash\n' ;;
        *) printf 'sh\n' ;;
      esac
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
