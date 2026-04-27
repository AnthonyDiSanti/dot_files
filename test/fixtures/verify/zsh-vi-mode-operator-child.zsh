emulate -L zsh
setopt ERR_EXIT NO_UNSET

: "${DOTFILES_ZSH_VI_MODE_LOG:?missing zsh vi-mode operator log path}"

__dotfiles_verify_dump_buffer() {
  emulate -L zsh

  # Record ZLE state without executing the command under test.
  print -r -- "dump K=$KEYMAP R=$REGION_ACTIVE C=$CURSOR M=$MARK L=$#BUFFER BUFFER=${(qqq)BUFFER} CUT=${(qqq)CUTBUFFER}" \
    >>"$DOTFILES_ZSH_VI_MODE_LOG"
  BUFFER=
  zle accept-line
}

__dotfiles_verify_load_clipboard_and_dump() {
  emulate -L zsh

  # Exercise the paste-time clipboard refresh without relying on terminal keys.
  __dotfiles_zsh_load_clipboard_to_cutbuffer || true
  __dotfiles_verify_dump_buffer
}

zle -N dotfiles-verify-dump-buffer __dotfiles_verify_dump_buffer
zle -N dotfiles-verify-load-clipboard-and-dump __dotfiles_verify_load_clipboard_and_dump
bindkey -M vicmd Q dotfiles-verify-dump-buffer
bindkey -M main '^G' dotfiles-verify-load-clipboard-and-dump
bindkey -M emacs '^G' dotfiles-verify-load-clipboard-and-dump
bindkey -M viins '^G' dotfiles-verify-load-clipboard-and-dump
