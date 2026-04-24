# Shared dotfiles path resolution for sh, bash, and zsh.
if [ "${DOTFILES_PATHS_LOADED:-0}" = 1 ]; then
  return 0
fi
DOTFILES_PATHS_LOADED=1

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

dotfiles_config_home=$XDG_CONFIG_HOME
dotfiles_cache_home=$XDG_CACHE_HOME
dotfiles_data_home=$XDG_DATA_HOME
dotfiles_state_home=$XDG_STATE_HOME

dotfiles_shell_config_home=$dotfiles_config_home/shell
dotfiles_bash_config_home=$dotfiles_config_home/bash
dotfiles_zsh_config_home=$dotfiles_config_home/zsh

dotfiles_bash_state_home=$dotfiles_state_home/bash
dotfiles_zsh_state_home=$dotfiles_state_home/zsh
dotfiles_zsh_cache_home=$dotfiles_cache_home/zsh
