if [[ ${DOTFILES_ZSH_RC_LOADED:-0} == 1 ]]; then
  return
fi
DOTFILES_ZSH_RC_LOADED=1

__dotfiles_zsh_init_completion() {
  emulate -L zsh
  local zcompdump_dir zcompdump_path

  if [[ -r "$HOME/.config/zsh/_git" ]]; then
    fpath=("$HOME/.config/zsh" $fpath)
  fi

  autoload -Uz compinit

  # Keep compinit's cache under XDG cache instead of littering $HOME.
  zcompdump_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  zcompdump_path="$zcompdump_dir/zcompdump"
  [[ -d $zcompdump_dir ]] || mkdir -p "$zcompdump_dir"
  compinit -d "$zcompdump_path"

  DOTFILES_ZSH_COMPLETION_LOADED=1
}

__dotfiles_zsh_init_completion
unset -f __dotfiles_zsh_init_completion

if [[ -r "$HOME/.config/zsh/prompt.zsh" ]]; then
  source "$HOME/.config/zsh/prompt.zsh"
fi

if [ -r "$HOME/.zsh_local" ]; then
  source "$HOME/.zsh_local"
fi
