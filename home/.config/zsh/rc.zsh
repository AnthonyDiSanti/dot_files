dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

__dotfiles_zsh_prepend_fpath() {
  emulate -L zsh
  local path="${1:-}" existing

  [[ -n $path ]] || return 0

  for existing in $fpath; do
    [[ $existing == "$path" ]] && return 0
  done

  fpath=("$path" $fpath)
}

__dotfiles_zsh_init_completion() {
  emulate -L zsh
  local zcompdump_dir zcompdump_path

  if [[ -r "$dotfiles_zsh_config_home/_git" ]]; then
    __dotfiles_zsh_prepend_fpath "$dotfiles_zsh_config_home"
  fi

  autoload -Uz compinit

  # Keep compinit's cache under XDG cache instead of littering $HOME.
  zcompdump_dir="$dotfiles_zsh_cache_home"
  zcompdump_path="$zcompdump_dir/zcompdump"
  [[ -d $zcompdump_dir ]] || mkdir -p "$zcompdump_dir"
  compinit -d "$zcompdump_path"
}

if [[ ! -d "$dotfiles_zsh_state_home" ]]; then
  mkdir -p "$dotfiles_zsh_state_home"
fi
HISTFILE="$dotfiles_zsh_state_home/history"
HISTSIZE="${HISTSIZE:-50000}"
SAVEHIST="${SAVEHIST:-$HISTSIZE}"
export HISTFILE HISTSIZE SAVEHIST

__dotfiles_zsh_init_completion
unset -f __dotfiles_zsh_prepend_fpath
unset -f __dotfiles_zsh_init_completion

if [[ -r "$dotfiles_zsh_config_home/prompt.zsh" ]]; then
  source "$dotfiles_zsh_config_home/prompt.zsh"
fi
