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

__dotfiles_zsh_set_cursor_for_keymap() {
  emulate -L zsh

  [[ -t 1 ]] || return 0
  case ${KEYMAP:-} in
    vicmd | visual | viopp)
      printf '\e[2 q'
      ;;
    *)
      printf '\e[6 q'
      ;;
  esac
}

__dotfiles_zsh_reset_cursor() {
  emulate -L zsh

  [[ -t 1 ]] || return 0
  printf '\e[0 q'
}

__dotfiles_zsh_select_entire_buffer() {
  emulate -L zsh

  (( $#BUFFER > 0 )) || return 1
  # ZLE text objects select visually with an inclusive cursor, then advance
  # once for operators so the final character is included in the edit.
  MARK=0
  (( CURSOR = $#BUFFER - 1 ))
  (( REGION_ACTIVE = !!REGION_ACTIVE ))
  if [[ $KEYMAP == vicmd ]] && (( ! REGION_ACTIVE )); then
    (( CURSOR++ ))
  fi
}

__dotfiles_zsh_configure_line_editor() {
  emulate -L zsh
  local key keymap
  local -a bracketed_text_objects quoted_text_objects

  autoload -Uz \
    add-zle-hook-widget \
    select-bracketed \
    select-quoted \
    surround \
    edit-command-line \
    history-beginning-search-menu \
    up-line-or-beginning-search \
    down-line-or-beginning-search
  # Register selected helpers so they are available through execute-named-cmd.
  zle -N edit-command-line
  zle -N history-beginning-search-menu
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  zle -N select-bracketed
  zle -N select-quoted
  zle -N delete-surround surround
  zle -N add-surround surround
  zle -N change-surround surround
  zle -N __dotfiles_zsh_set_cursor_for_keymap
  zle -N __dotfiles_zsh_reset_cursor
  zle -N select-entire-buffer __dotfiles_zsh_select_entire_buffer
  zmodload zsh/complist

  add-zle-hook-widget -d line-init __dotfiles_zsh_set_cursor_for_keymap 2>/dev/null || true
  add-zle-hook-widget -d keymap-select __dotfiles_zsh_set_cursor_for_keymap 2>/dev/null || true
  add-zle-hook-widget -d line-finish __dotfiles_zsh_reset_cursor 2>/dev/null || true
  add-zle-hook-widget line-init __dotfiles_zsh_set_cursor_for_keymap
  add-zle-hook-widget keymap-select __dotfiles_zsh_set_cursor_for_keymap
  add-zle-hook-widget line-finish __dotfiles_zsh_reset_cursor

  # Open the current command in $EDITOR from vi insert or command mode.
  bindkey -M viins '^E' edit-command-line
  bindkey -M vicmd '^E' edit-command-line

  # Keep Ctrl-R useful when fzf integration is unavailable; fzf can override it later.
  bindkey -M emacs '^R' history-incremental-search-backward
  bindkey -M viins '^R' history-incremental-search-backward

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

  bindkey -M menuselect h vi-backward-char
  bindkey -M menuselect j vi-down-line-or-history
  bindkey -M menuselect k vi-up-line-or-history
  bindkey -M menuselect l vi-forward-char

  quoted_text_objects=('a"' 'i"' "a'" "i'" 'a`' 'i`')
  bracketed_text_objects=(
    'a(' 'i(' 'a)' 'i)'
    'a[' 'i[' 'a]' 'i]'
    'a{' 'i{' 'a}' 'i}'
    'a<' 'i<' 'a>' 'i>'
    ab ib aB iB
  )
  for keymap in visual viopp; do
    bindkey -M "$keymap" ae select-entire-buffer
    for key in "${quoted_text_objects[@]}"; do
      bindkey -M "$keymap" "$key" select-quoted
    done
    for key in "${bracketed_text_objects[@]}"; do
      bindkey -M "$keymap" "$key" select-bracketed
    done
  done

  bindkey -M vicmd cs change-surround
  bindkey -M vicmd ds delete-surround
  bindkey -M vicmd ys add-surround
  bindkey -M visual S add-surround

  # Native completion matching: case-insensitive, with - and _ treated alike.
  zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}'
  # Keep zsh completion readable while limiting menu selection to ambiguous matches.
  zstyle ':completion:*' verbose yes
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' list-colors ''
  zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
  zstyle ':completion:*:messages' format '%F{cyan}%d%f'
  zstyle ':completion:*:warnings' format '%F{red}no matches: %d%f'
  zstyle ':completion:*' list-dirs-first true
  zstyle ':completion:*' menu select=2
}

__dotfiles_zsh_configure_line_editor

if [[ -r "$dotfiles_zsh_config_home/tool-support.zsh" ]]; then
  source "$dotfiles_zsh_config_home/tool-support.zsh"
fi

if [[ -r "$dotfiles_zsh_config_home/prompt.zsh" ]]; then
  source "$dotfiles_zsh_config_home/prompt.zsh"
fi

unset -f __dotfiles_zsh_configure_line_editor
