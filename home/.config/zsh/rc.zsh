dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

if (( ! $+functions[dotfiles_git_share_roots] )); then
  source "$dotfiles_shell_config_home/functions.sh" || return 1
fi

if [[ ! -d "$dotfiles_zsh_state_home" ]]; then
  mkdir -p "$dotfiles_zsh_state_home"
fi
HISTFILE="$dotfiles_zsh_state_home/history"
# zsh predefines HISTSIZE, so assign the repo default before .zsh_local overrides.
HISTSIZE=50000
SAVEHIST=50000
export HISTFILE HISTSIZE SAVEHIST

if [[ -r "$dotfiles_zsh_config_home/completion.zsh" ]]; then
  source "$dotfiles_zsh_config_home/completion.zsh"
fi

if [[ -r "$dotfiles_zsh_config_home/prompt.zsh" ]]; then
  source "$dotfiles_zsh_config_home/prompt.zsh"
fi
