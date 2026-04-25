dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

__dotfiles_bash_source_first_readable() {
  local path

  for path in "$@"; do
    [[ -r "$path" ]] || continue
    source "$path"
    return 0
  done

  return 1
}

if [[ ! -d "$dotfiles_bash_state_home" ]]; then
  mkdir -p "$dotfiles_bash_state_home"
fi
export HISTFILE="$dotfiles_bash_state_home/history"
export HISTSIZE="${HISTSIZE:-50000}"
export HISTFILESIZE="${HISTFILESIZE:-$HISTSIZE}"
# Keep Bash history usable across concurrent shells without live event-number merging.
shopt -s histappend cmdhist lithist

if command -v git >/dev/null 2>&1; then
  export GIT_PS1_SHOWDIRTYSTATE='auto'
  export GIT_PS1_SHOWUNTRACKEDFILES='auto'
  export GIT_PS1_SHOWUPSTREAM='auto'

  __dotfiles_bash_source_first_readable \
    "$dotfiles_bash_config_home/git-prompt.sh" \
    "/opt/homebrew/etc/bash_completion.d/git-prompt.sh" \
    "/opt/homebrew/share/git-core/contrib/completion/git-prompt.sh" \
    "/usr/local/etc/bash_completion.d/git-prompt.sh" \
    "/usr/local/share/git-core/contrib/completion/git-prompt.sh" \
    "/usr/share/git/completion/git-prompt.sh" \
    "/usr/share/git-core/contrib/completion/git-prompt.sh"

  __dotfiles_bash_source_first_readable \
    "$dotfiles_bash_config_home/git-completion.bash" \
    "/opt/homebrew/etc/bash_completion.d/git-completion.bash" \
    "/opt/homebrew/share/git-core/contrib/completion/git-completion.bash" \
    "/usr/local/etc/bash_completion.d/git-completion.bash" \
    "/usr/local/share/git-core/contrib/completion/git-completion.bash" \
    "/usr/share/bash-completion/completions/git"
fi

if [ -r "$dotfiles_bash_config_home/prompt.bash" ]; then
  source "$dotfiles_bash_config_home/prompt.bash"
fi

# Filled block cursor on WSL only (avoids grep noise on macOS where /proc/version is absent).
if [[ -r /proc/version ]] && grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
  echo -ne '\e[2 q'
fi

if [[ ${DOTFILES_USE_BUILTIN_PS1:-1} != 0 ]] && declare -F __dotfiles_set_ps1 >/dev/null 2>&1; then
  __dotfiles_set_ps1
fi
