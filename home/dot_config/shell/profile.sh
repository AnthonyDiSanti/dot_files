# Shared POSIX login shell environment for sh, bash, and zsh.
if [ "${DOTFILES_SHELL_PROFILE_LOADED:-0}" = 1 ]; then
  return 0
fi
DOTFILES_SHELL_PROFILE_LOADED=1

dotfiles_path_prepend() {
  case ":${PATH:-}:" in
    *:"$1":*) return 0 ;;
  esac

  if [ -n "${PATH:-}" ]; then
    PATH="$1:$PATH"
  else
    PATH=$1
  fi
}

if [ -d "$HOME/.local/bin" ]; then
  dotfiles_path_prepend "$HOME/.local/bin"
fi

if [ -d "$HOME/bin" ]; then
  dotfiles_path_prepend "$HOME/bin"
fi

export PATH
export CLICOLOR=1
export EDITOR=vim
export VISUAL=$EDITOR

if command -v vimpager >/dev/null 2>&1; then
  export PAGER=vimpager
else
  export PAGER=less
fi

unset -f dotfiles_path_prepend 2>/dev/null || true
