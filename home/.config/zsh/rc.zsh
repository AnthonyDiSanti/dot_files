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

__dotfiles_zsh_configure_line_editor() {
  emulate -L zsh
  local key

  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search

  for key in '^[[A' '^[OA'; do
    bindkey -M emacs "$key" up-line-or-beginning-search
    bindkey -M viins "$key" up-line-or-beginning-search
    bindkey -M vicmd "$key" up-line-or-beginning-search
  done

  for key in '^[[B' '^[OB'; do
    bindkey -M emacs "$key" down-line-or-beginning-search
    bindkey -M viins "$key" down-line-or-beginning-search
    bindkey -M vicmd "$key" down-line-or-beginning-search
  done

  # Native completion matching: case-insensitive, with - and _ treated alike.
  zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}'
}

__dotfiles_zsh_configure_line_editor

if [[ -r "$dotfiles_zsh_config_home/tool-support.zsh" ]]; then
  source "$dotfiles_zsh_config_home/tool-support.zsh"
fi

if [[ -r "$dotfiles_zsh_config_home/prompt.zsh" ]]; then
  source "$dotfiles_zsh_config_home/prompt.zsh"
fi

unset -f __dotfiles_zsh_configure_line_editor
