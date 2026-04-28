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

__dotfiles_zsh_clipboard_supported() {
  emulate -L zsh

  case ${__dotfiles_zsh_clipboard_status:-unknown} in
    supported)
      return 0
      ;;
    unsupported)
      return 1
      ;;
  esac

  if dotfiles_command_succeeds dotfiles-clipboard status; then
    typeset -g __dotfiles_zsh_clipboard_status=supported
    return 0
  fi

  typeset -g __dotfiles_zsh_clipboard_status=unsupported
  return 1
}

__dotfiles_zsh_copy_cutbuffer_to_clipboard() {
  emulate -L zsh

  __dotfiles_zsh_clipboard_supported || return 1
  # Clipboard sync must never make native zsh yank behavior noisy or fragile.
  if printf '%s' "$CUTBUFFER" | dotfiles-clipboard copy >/dev/null 2>&1; then
    return 0
  fi

  typeset -g __dotfiles_zsh_clipboard_status=unsupported
  return 1
}

__dotfiles_zsh_load_clipboard_to_cutbuffer() {
  emulate -L zsh
  local clipboard

  __dotfiles_zsh_clipboard_supported || return 1
  # The NUL sentinel preserves trailing newlines from the clipboard payload.
  if ! IFS= read -r -d '' clipboard < <(dotfiles-clipboard paste 2>/dev/null && printf '\0'); then
    typeset -g __dotfiles_zsh_clipboard_status=unsupported
    return 1
  fi
  zle copy-region-as-kill "$clipboard"
}

__dotfiles_zsh_run_cutbuffer_widget() {
  emulate -L zsh
  local native_widget="$1"
  local widget_status

  shift
  zle ".$native_widget" "$@"
  widget_status=$?
  if (( widget_status == 0 )); then
    __dotfiles_zsh_copy_cutbuffer_to_clipboard || true
  fi
  return "$widget_status"
}

__dotfiles_zsh_vi_yank_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-yank "$@"
}

__dotfiles_zsh_vi_yank_whole_line_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-yank-whole-line "$@"
}

__dotfiles_zsh_vi_yank_eol_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-yank-eol "$@"
}

__dotfiles_zsh_vi_delete_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-delete "$@"
}

__dotfiles_zsh_vi_change_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-change "$@"
}

__dotfiles_zsh_vi_change_eol_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-change-eol "$@"
}

__dotfiles_zsh_vi_change_whole_line_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-change-whole-line "$@"
}

__dotfiles_zsh_vi_kill_eol_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-kill-eol "$@"
}

__dotfiles_zsh_vi_substitute_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-substitute "$@"
}

__dotfiles_zsh_vi_delete_char_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-delete-char "$@"
}

__dotfiles_zsh_vi_backward_delete_char_clipboard() {
  __dotfiles_zsh_run_cutbuffer_widget vi-backward-delete-char "$@"
}

__dotfiles_zsh_vi_put_before_clipboard() {
  emulate -L zsh

  __dotfiles_zsh_load_clipboard_to_cutbuffer || true
  zle .vi-put-before "$@"
}

__dotfiles_zsh_vi_put_after_clipboard() {
  emulate -L zsh

  __dotfiles_zsh_load_clipboard_to_cutbuffer || true
  zle .vi-put-after "$@"
}

__dotfiles_zsh_put_replace_selection_clipboard() {
  emulate -L zsh

  __dotfiles_zsh_load_clipboard_to_cutbuffer || true
  zle .put-replace-selection "$@"
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
  zle -N vi-yank __dotfiles_zsh_vi_yank_clipboard
  zle -N vi-yank-whole-line __dotfiles_zsh_vi_yank_whole_line_clipboard
  zle -N vi-yank-eol __dotfiles_zsh_vi_yank_eol_clipboard
  zle -N vi-delete __dotfiles_zsh_vi_delete_clipboard
  zle -N vi-change __dotfiles_zsh_vi_change_clipboard
  zle -N vi-change-eol __dotfiles_zsh_vi_change_eol_clipboard
  zle -N vi-change-whole-line __dotfiles_zsh_vi_change_whole_line_clipboard
  zle -N vi-kill-eol __dotfiles_zsh_vi_kill_eol_clipboard
  zle -N vi-substitute __dotfiles_zsh_vi_substitute_clipboard
  zle -N __dotfiles_zsh_vi_delete_char_clipboard
  zle -N __dotfiles_zsh_vi_backward_delete_char_clipboard
  zle -N vi-put-before __dotfiles_zsh_vi_put_before_clipboard
  zle -N vi-put-after __dotfiles_zsh_vi_put_after_clipboard
  zle -N put-replace-selection __dotfiles_zsh_put_replace_selection_clipboard
  zmodload zsh/complist

  add-zle-hook-widget -d line-init __dotfiles_zsh_set_cursor_for_keymap 2>/dev/null || true
  add-zle-hook-widget -d keymap-select __dotfiles_zsh_set_cursor_for_keymap 2>/dev/null || true
  add-zle-hook-widget -d line-finish __dotfiles_zsh_reset_cursor 2>/dev/null || true
  add-zle-hook-widget line-init __dotfiles_zsh_set_cursor_for_keymap
  add-zle-hook-widget keymap-select __dotfiles_zsh_set_cursor_for_keymap
  add-zle-hook-widget line-finish __dotfiles_zsh_reset_cursor

  # Disable zsh's temporary standout highlight for bracketed paste text.
  zle_highlight=("${(@)zle_highlight:#paste:*}" paste:none)

  # Open the current command in $EDITOR from vi insert or command mode.
  bindkey -M viins '^E' edit-command-line
  bindkey -M vicmd '^E' edit-command-line

  # Keep Backspace/Delete useful after returning to insert mode mid-command.
  bindkey -M viins '^?' backward-delete-char
  bindkey -M viins '^H' backward-delete-char
  bindkey -M viins '^[[3~' delete-char

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
  bindkey -M vicmd x __dotfiles_zsh_vi_delete_char_clipboard
  bindkey -M vicmd X __dotfiles_zsh_vi_backward_delete_char_clipboard
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
