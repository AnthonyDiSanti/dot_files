# Shared dotfiles path resolution for sh, bash, and zsh.
# Safe to rerun: we simply derive the internal path layer from current XDG/HOME state.
# This sourced helper intentionally publishes path variables for shell-specific startup files.
# shellcheck disable=SC2034

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${CURSOR_CONFIG_DIR:=$XDG_CONFIG_HOME/cursor}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME CURSOR_CONFIG_DIR

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
