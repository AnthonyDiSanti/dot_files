# Shared POSIX interactive shell config for sh, bash, and zsh.
if [ "${DOTFILES_SHELL_RC_LOADED:-0}" = 1 ]; then
  return 0
fi
DOTFILES_SHELL_RC_LOADED=1
export DOTFILES_SHELL_RC_LOADED

set -o vi 2>/dev/null || true

if [ -r "$HOME/.config/shell/aliases.sh" ]; then
  . "$HOME/.config/shell/aliases.sh"
fi

if [ -r "$HOME/.config/shell/functions.sh" ]; then
  . "$HOME/.config/shell/functions.sh"
fi

if [ -r "$HOME/.config/shell/local.sh" ]; then
  . "$HOME/.config/shell/local.sh"
fi
