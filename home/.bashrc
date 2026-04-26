#!/usr/bin/env bash

case $- in
  *i*) ;;
  *) return 0 ;;
esac

if [ -r "$HOME/.shrc" ]; then
  source "$HOME/.shrc" || return 1
fi

dotfiles_bash_bootstrap_home="${dotfiles_bash_config_home:-${dotfiles_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}}/bash}"
if [ -r "$dotfiles_bash_bootstrap_home/rc.bash" ]; then
  source "$dotfiles_bash_bootstrap_home/rc.bash" || return 1
fi

if [ -r "$HOME/.bashrc_local" ]; then
  source "$HOME/.bashrc_local" || return 1
fi

unset dotfiles_bash_bootstrap_home
