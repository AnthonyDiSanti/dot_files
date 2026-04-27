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

zle -N dotfiles-verify-dump-buffer __dotfiles_verify_dump_buffer
bindkey -M vicmd Q dotfiles-verify-dump-buffer
