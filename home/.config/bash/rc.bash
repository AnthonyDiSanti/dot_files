dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

if ! declare -F dotfiles_git_prompt_candidates >/dev/null 2>&1; then
  source "$dotfiles_shell_config_home/functions.sh" || return 1
fi

__dotfiles_bash_source_first_git_prompt_candidate() {
  local path

  while IFS= read -r path; do
    [[ -r $path ]] || continue
    source "$path"
    return 0
  done

  return 1
}

# Sourced from paths.sh; ShellCheck does not follow this dynamic startup layout.
# shellcheck disable=SC2154
if [[ ! -d "$dotfiles_bash_state_home" ]]; then
  mkdir -p "$dotfiles_bash_state_home"
fi
export HISTFILE="$dotfiles_bash_state_home/history"
export HISTSIZE="${HISTSIZE:-50000}"
export HISTFILESIZE="${HISTFILESIZE:-$HISTSIZE}"
export HISTTIMEFORMAT='%F %T '
# Keep Bash history usable across concurrent shells without live event-number merging.
shopt -s histappend cmdhist lithist
# Keep Readline wrapping aligned with resized terminal windows.
shopt -s checkwinsize

__dotfiles_bash_configure_line_editor() {
  local command_cursor insert_cursor

  # Open the current command in $EDITOR from vi insert or command mode.
  bind -m vi-insert '"\C-e": edit-and-execute-command'
  bind -m vi-command '"\C-e": vi-edit-and-execute-command'

  # Search history by the typed prefix when pressing Up/Down.
  bind '"\e[A": history-search-backward'
  bind '"\eOA": history-search-backward'
  bind '"\e[B": history-search-forward'
  bind '"\eOB": history-search-forward'

  # Match completions case-insensitively; enable Readline's related case mapper if present.
  bind 'set completion-ignore-case on'
  bind 'set completion-map-case on' 2>/dev/null || true

  # Keep bracketed paste without showing pasted text as a temporary active region.
  bind 'set enable-active-region off'

  # Match zsh's vi cursor policy: beam in insert mode, block in command mode.
  # \001/\002 mark these escape sequences as nonprinting for prompt width.
  insert_cursor=$'\001\e[6 q\002'
  command_cursor=$'\001\e[2 q\002'
  if bind "set vi-ins-mode-string $insert_cursor" 2>/dev/null \
    && bind "set vi-cmd-mode-string $command_cursor" 2>/dev/null; then
    bind 'set show-mode-in-prompt on' 2>/dev/null || true
  fi
}

__dotfiles_bash_configure_line_editor

# Sourced from paths.sh; ShellCheck does not follow this dynamic startup layout.
# shellcheck disable=SC2154
if [[ -r "$dotfiles_bash_config_home/tool-support.bash" ]]; then
  source "$dotfiles_bash_config_home/tool-support.bash"
fi

if dotfiles_have_command git; then
  export GIT_PS1_SHOWDIRTYSTATE='auto'
  export GIT_PS1_SHOWUNTRACKEDFILES='auto'
  export GIT_PS1_SHOWUPSTREAM='auto'

  if ! declare -F __git_ps1 >/dev/null 2>&1; then
    __dotfiles_bash_source_first_git_prompt_candidate < <(dotfiles_git_prompt_candidates)
  fi
fi

unset -f __dotfiles_bash_source_first_git_prompt_candidate
unset -f __dotfiles_bash_configure_line_editor

if [ -r "$dotfiles_bash_config_home/prompt.bash" ]; then
  source "$dotfiles_bash_config_home/prompt.bash"
fi

if [[ ${DOTFILES_USE_BUILTIN_PS1:-1} != 0 ]] && declare -F __dotfiles_set_ps1 >/dev/null 2>&1; then
  __dotfiles_set_ps1
fi
