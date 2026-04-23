exit_if_error() {
  dotfiles_exit_code=$?
  if [ "$dotfiles_exit_code" -ne 0 ]; then
    exit "$dotfiles_exit_code"
  fi
  return 0
}

dotfiles_codex_git() (
  dotfiles_repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
  dotfiles_git_common=$(git rev-parse --git-common-dir 2>/dev/null) || exit 1
  exec codex --add-dir "$HOME/.codex" -C "$dotfiles_repo_root" --add-dir "$dotfiles_git_common" "$@"
)
