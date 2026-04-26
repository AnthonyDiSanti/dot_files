dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

if ! declare -F dotfiles_git_share_roots >/dev/null 2>&1; then
  source "$dotfiles_shell_config_home/functions.sh" || return 1
fi
source "$dotfiles_bash_config_home/git-completion.sh" || return 1

__dotfiles_bash_source_first_git_candidate() {
  local path

  # Prefer helper files from the active Git install so completion matches the binary on PATH.
  while IFS= read -r path; do
    [[ -r $path ]] || continue
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

  __dotfiles_bash_source_first_git_candidate < <(dotfiles_git_prompt_candidates)
  __dotfiles_bash_source_first_git_candidate < <(dotfiles_bash_git_completion_candidates)
fi

unset -f __dotfiles_bash_source_first_git_candidate

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
