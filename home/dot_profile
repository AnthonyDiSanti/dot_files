export ENV="$HOME/.shrc"

dotfiles_shell_bootstrap_home="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

if [ -r "$dotfiles_shell_bootstrap_home/profile.sh" ]; then
  . "$dotfiles_shell_bootstrap_home/profile.sh" || return 1
fi

if [ -r "$HOME/.profile_local" ]; then
  . "$HOME/.profile_local" || return 1
fi

unset dotfiles_shell_bootstrap_home
