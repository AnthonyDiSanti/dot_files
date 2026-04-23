dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

if [[ ${DOTFILES_ZSH_RC_LOADED:-0} == 1 ]]; then
  return
fi
DOTFILES_ZSH_RC_LOADED=1

__dotfiles_zsh_init_completion() {
  emulate -L zsh
  local zcompdump_dir zcompdump_path

  if [[ -r "$dotfiles_zsh_config_home/_git" ]]; then
    fpath=("$dotfiles_zsh_config_home" $fpath)
  fi

  autoload -Uz compinit

  # Keep compinit's cache under XDG cache instead of littering $HOME.
  zcompdump_dir="$dotfiles_zsh_cache_home"
  zcompdump_path="$zcompdump_dir/zcompdump"
  [[ -d $zcompdump_dir ]] || mkdir -p "$zcompdump_dir"
  compinit -d "$zcompdump_path"

  DOTFILES_ZSH_COMPLETION_LOADED=1
}

if [[ ! -d "$dotfiles_zsh_state_home" ]]; then
  mkdir -p "$dotfiles_zsh_state_home"
fi
HISTFILE="$dotfiles_zsh_state_home/history"
HISTSIZE="${HISTSIZE:-50000}"
SAVEHIST="${SAVEHIST:-$HISTSIZE}"
export HISTFILE HISTSIZE SAVEHIST

__dotfiles_zsh_init_completion
unset -f __dotfiles_zsh_init_completion

if [[ -r "$dotfiles_zsh_config_home/prompt.zsh" ]]; then
  source "$dotfiles_zsh_config_home/prompt.zsh"
fi
