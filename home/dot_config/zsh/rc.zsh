if [[ ${DOTFILES_ZSH_RC_LOADED:-0} == 1 ]]; then
  return
fi
DOTFILES_ZSH_RC_LOADED=1
export DOTFILES_ZSH_RC_LOADED

export EDITOR="vim -u NONE -N"
export VISUAL="$EDITOR"

if [ -r "$HOME/.zsh_local" ]; then
  source "$HOME/.zsh_local"
fi
