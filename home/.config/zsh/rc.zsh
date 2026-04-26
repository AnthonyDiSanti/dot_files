dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

if (( ! $+functions[dotfiles_git_share_roots] )); then
  source "$dotfiles_shell_config_home/functions.sh" || return 1
fi

if [[ ! -d "$dotfiles_zsh_state_home" ]]; then
  mkdir -p "$dotfiles_zsh_state_home"
fi
HISTFILE="$dotfiles_zsh_state_home/history"
# zsh predefines HISTSIZE, so assign the repo default before .zsh_local overrides.
HISTSIZE=50000
SAVEHIST=50000
export HISTFILE HISTSIZE SAVEHIST
# Store timestamps and elapsed command duration in the zsh history file.
setopt EXTENDED_HISTORY

history() {
  local command date duration elapsed event line output time

  output="$(fc -l -D -t '%F %T' "$@")" || return $?
  while IFS= read -r line; do
    read -r event date time elapsed command <<<"$line"
    if [[ $date == [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] \
      && $time == [0-9][0-9]:[0-9][0-9]:[0-9][0-9] \
      && $elapsed == *:* ]]; then
      # zsh only stores whole seconds; keep sub-10s display compact without faking ms.
      if [[ $elapsed == 0:0[0-9] ]]; then
        duration="${elapsed##*:0}"
        [[ $duration == 0 ]] && duration="<1s" || duration="${duration}s"
      else
        duration="$elapsed"
      fi
      printf '%5s  %s %s  %-4s  %s\n' "$event" "$date" "$time" "$duration" "$command"
    else
      print -r -- "$line"
    fi
  done <<<"$output"
}

__dotfiles_zsh_configure_line_editor() {
  emulate -L zsh
  local key

  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search

  for key in '^[[A' '^[OA'; do
    bindkey -M emacs "$key" up-line-or-beginning-search
    bindkey -M viins "$key" up-line-or-beginning-search
    bindkey -M vicmd "$key" up-line-or-beginning-search
  done

  for key in '^[[B' '^[OB'; do
    bindkey -M emacs "$key" down-line-or-beginning-search
    bindkey -M viins "$key" down-line-or-beginning-search
    bindkey -M vicmd "$key" down-line-or-beginning-search
  done

  # Native completion matching: case-insensitive, with - and _ treated alike.
  zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}'
}

__dotfiles_zsh_configure_line_editor

if [[ -r "$dotfiles_zsh_config_home/tool-support.zsh" ]]; then
  source "$dotfiles_zsh_config_home/tool-support.zsh"
fi

if [[ -r "$dotfiles_zsh_config_home/prompt.zsh" ]]; then
  source "$dotfiles_zsh_config_home/prompt.zsh"
fi

unset -f __dotfiles_zsh_configure_line_editor
