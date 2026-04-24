# Shared POSIX interactive shell config for sh, bash, and zsh.
dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
. "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

set -o vi 2>/dev/null || true

if [ -r "$dotfiles_shell_config_home/aliases.sh" ]; then
  . "$dotfiles_shell_config_home/aliases.sh"
fi

if [ -r "$dotfiles_shell_config_home/functions.sh" ]; then
  . "$dotfiles_shell_config_home/functions.sh"
fi
