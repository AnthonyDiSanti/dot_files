dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

if (( ! $+functions[dotfiles_homebrew_prefix_roots] )); then
  source "$dotfiles_shell_config_home/functions.sh" || return 1
fi
# Git's upstream zsh wrapper sources Git's Bash completion script internally.
if (( ! $+functions[dotfiles_bash_git_completion_candidates] )); then
  source "$dotfiles_bash_config_home/git-completion.sh" || return 1
fi

__dotfiles_zsh_prepend_fpath() {
  emulate -L zsh
  local path="${1:-}" existing

  [[ -n $path && -d $path ]] || return 0

  for existing in $fpath; do
    [[ $existing == "$path" ]] && return 0
  done

  fpath=("$path" $fpath)
}

# Make package-manager zsh completions available before compinit builds its table.
__dotfiles_zsh_add_homebrew_fpath() {
  emulate -L zsh
  local prefix

  while IFS= read -r prefix; do
    __dotfiles_zsh_prepend_fpath "$prefix/share/zsh/site-functions"
  done < <(dotfiles_homebrew_prefix_roots)
}

__dotfiles_zsh_fpath_has_function() {
  emulate -L zsh
  local function_name="$1" path

  for path in $fpath; do
    [[ -r "$path/$function_name" ]] && return 0
  done

  return 1
}

__dotfiles_zsh_configure_git_completion() {
  emulate -L zsh
  local git_share_root git_completion_dir="" git_bash_completion="" existing_script=""
  local git_completion_cache_dir git_completion_file candidate

  __dotfiles_zsh_fpath_has_function _git && return 0

  # Fill in active-Git completion only when no native _git is already visible.
  while IFS= read -r git_share_root; do
    if [[ -z $git_completion_dir ]]; then
      git_completion_file="$git_share_root/zsh/site-functions/_git"
      if [[ -r $git_completion_file ]]; then
        git_completion_dir="${git_completion_file:h}"
      else
        for candidate in \
          "$git_share_root/zsh/site-functions/git-completion.zsh" \
          "$git_share_root/git-core/git-completion.zsh"; do
          [[ -r $candidate ]] || continue
          git_completion_cache_dir="$dotfiles_zsh_cache_home/git-completion"
          if mkdir -p "$git_completion_cache_dir" && ln -sf "$candidate" "$git_completion_cache_dir/_git"; then
            git_completion_dir="$git_completion_cache_dir"
          fi
          break
        done
      fi
    fi

  done < <(dotfiles_git_share_roots)

  [[ -n $git_completion_dir ]] && __dotfiles_zsh_prepend_fpath "$git_completion_dir"

  if [[ -n $git_completion_dir ]] && ! zstyle -s ':completion:*:*:git:*' script existing_script; then
    while IFS= read -r candidate; do
      [[ -r $candidate ]] || continue
      git_bash_completion="$candidate"
      break
    done < <(dotfiles_bash_git_completion_candidates)
    [[ -n $git_bash_completion ]] && zstyle ':completion:*:*:git:*' script "$git_bash_completion"
  fi
}

# Use command-provided generators only when no native zsh function is available.
__dotfiles_zsh_load_generated_completion() {
  emulate -L zsh
  local command_name="$1"
  shift

  command -v "$command_name" >/dev/null 2>&1 || return 0
  eval -- "$("$@" 2>/dev/null)"
}

__dotfiles_zsh_init_completion() {
  emulate -L zsh
  local zcompdump_dir zcompdump_path

  __dotfiles_zsh_add_homebrew_fpath
  __dotfiles_zsh_configure_git_completion

  autoload -Uz compinit

  # Keep compinit's cache under XDG cache instead of littering $HOME.
  zcompdump_dir="$dotfiles_zsh_cache_home"
  zcompdump_path="$zcompdump_dir/zcompdump"
  [[ -d $zcompdump_dir ]] || mkdir -p "$zcompdump_dir"
  compinit -d "$zcompdump_path"

  # Some tools ship completion generators instead of package-manager functions.
  (( ${+_comps[docker]} )) || __dotfiles_zsh_load_generated_completion docker docker completion zsh
  (( ${+_comps[gh]} )) || __dotfiles_zsh_load_generated_completion gh gh completion -s zsh
  (( ${+_comps[kubectl]} )) || __dotfiles_zsh_load_generated_completion kubectl env KUBECONFIG=/dev/null kubectl completion zsh
}

__dotfiles_zsh_init_completion

unset -f __dotfiles_zsh_prepend_fpath
unset -f __dotfiles_zsh_add_homebrew_fpath
unset -f __dotfiles_zsh_fpath_has_function
unset -f __dotfiles_zsh_configure_git_completion
unset -f __dotfiles_zsh_load_generated_completion
unset -f __dotfiles_zsh_init_completion
