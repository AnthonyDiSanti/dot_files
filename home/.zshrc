if [ -r "$HOME/.shrc" ]; then
  . "$HOME/.shrc" || return 1
fi

dotfiles_zsh_bootstrap_home="${dotfiles_zsh_config_home:-${dotfiles_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}}/zsh}"
if [ -r "$dotfiles_zsh_bootstrap_home/rc.zsh" ]; then
  . "$dotfiles_zsh_bootstrap_home/rc.zsh" || return 1
fi

if [ -r "$HOME/.zshrc_local" ]; then
  . "$HOME/.zshrc_local" || return 1
fi

unset dotfiles_zsh_bootstrap_home
