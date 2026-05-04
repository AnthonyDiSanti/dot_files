# Shared POSIX login shell environment for sh, bash, and zsh.
dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
. "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

# Bash gets a per-process guard token; POSIX shells safely fall back to $$.
# shellcheck disable=SC3028
dotfiles_guard_token=${BASHPID:-$$}

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

dotfiles_homebrew=
if [ -x /opt/homebrew/bin/brew ]; then
  dotfiles_homebrew=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  dotfiles_homebrew=/usr/local/bin/brew
fi

if [ -n "$dotfiles_homebrew" ] \
  && [ "${DOTFILES_HOMEBREW_SHELLENV_LOADED:-}" != "$dotfiles_guard_token" ]; then
  eval "$("$dotfiles_homebrew" shellenv)"
  DOTFILES_HOMEBREW_SHELLENV_LOADED=$dotfiles_guard_token
fi

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
unset dotfiles_homebrew
unset dotfiles_guard_token
