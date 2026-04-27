dotfiles_paths_bootstrap_home="${dotfiles_shell_config_home:-${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
if [[ ! -r "$dotfiles_paths_bootstrap_home/paths.sh" ]]; then
  printf 'dotfiles: missing required shell paths helper: %s/paths.sh\n' "$dotfiles_paths_bootstrap_home" >&2
  return 1
fi
source "$dotfiles_paths_bootstrap_home/paths.sh" || return 1
unset dotfiles_paths_bootstrap_home

dotfiles_bash_tool_support_home="${dotfiles_bash_config_home:-}"
if [[ -z $dotfiles_bash_tool_support_home ]]; then
  printf 'dotfiles: missing required bash config path\n' >&2
  return 1
fi

if ! declare -F dotfiles_git_share_roots >/dev/null 2>&1; then
  source "$dotfiles_shell_config_home/functions.sh" || return 1
fi
source "$dotfiles_bash_tool_support_home/git-completion.sh" || return 1

__dotfiles_bash_source_if_readable() {
  local path="$1"

  [[ -r $path ]] || return 1
  source "$path"
}

# Prefer the package-manager framework when it is installed; it owns broad snippet loading.
__dotfiles_bash_load_completion_framework() {
  local candidate formula prefix sysconfdir datadir

  [[ -n ${BASH_COMPLETION_VERSINFO:-} ]] && return 0

  if command -v brew >/dev/null 2>&1; then
    for formula in bash-completion@2 bash-completion; do
      prefix=$(brew --prefix "$formula" 2>/dev/null) || continue
      for candidate in \
        "$prefix/etc/profile.d/bash_completion.sh" \
        "$prefix/share/bash-completion/bash_completion"; do
        __dotfiles_bash_source_if_readable "$candidate" && return 0
      done
    done
  fi

  if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists bash-completion 2>/dev/null; then
    sysconfdir=$(pkg-config --variable=sysconfdir bash-completion 2>/dev/null)
    datadir=$(pkg-config --variable=datadir bash-completion 2>/dev/null)
    for candidate in \
      "$sysconfdir/profile.d/bash_completion.sh" \
      "$datadir/bash-completion/bash_completion"; do
      __dotfiles_bash_source_if_readable "$candidate" && return 0
    done
  fi

  for candidate in \
    /etc/profile.d/bash_completion.sh \
    /usr/local/etc/profile.d/bash_completion.sh \
    /opt/local/etc/profile.d/bash_completion.sh \
    /etc/bash_completion \
    /usr/local/etc/bash_completion \
    /usr/share/bash-completion/bash_completion \
    /usr/local/share/bash-completion/bash_completion \
    /opt/local/share/bash-completion/bash_completion; do
    __dotfiles_bash_source_if_readable "$candidate" && return 0
  done

  return 1
}

__dotfiles_bash_load_git_completion() {
  complete -p git >/dev/null 2>&1 && return 0
  command -v git >/dev/null 2>&1 || return 0

  local candidate
  while IFS= read -r candidate; do
    __dotfiles_bash_source_if_readable "$candidate" && return 0
  done < <(dotfiles_bash_git_completion_candidates)

  return 0
}

# Use command-provided generators only for tools that lack reliable static snippets.
__dotfiles_bash_load_generated_completion() {
  local command_name="$1"
  local generated_completion
  shift

  command -v "$command_name" >/dev/null 2>&1 || return 0
  complete -p "$command_name" >/dev/null 2>&1 && return 0
  generated_completion="$("$@" 2>/dev/null)" || return 0
  [[ -n $generated_completion ]] || return 0
  eval "$generated_completion"
}

# Enable git-spice completion for the shared `gs` alias.
__dotfiles_bash_configure_git_spice_alias_completion() {
  local git_spice_path

  command -v git-spice >/dev/null 2>&1 || return 0
  [[ $(alias gs 2>/dev/null) == "alias gs='git-spice'" ]] || return 0
  complete -p gs >/dev/null 2>&1 && return 0

  git_spice_path=$(command -v git-spice) || return 0
  complete -o default -C "$git_spice_path" gs
}

__dotfiles_bash_load_fzf_shell_support() {
  local fzf_shell_support

  command -v fzf >/dev/null 2>&1 || return 0
  fzf_shell_support="$(fzf --bash 2>/dev/null)" || return 0
  [[ -n $fzf_shell_support ]] || return 0
  eval "$fzf_shell_support"
}

# Some snippets rely on bash-completion helper functions; avoid broad direct sourcing.
__dotfiles_bash_load_completion_framework || true

__dotfiles_bash_load_git_completion

# Some tools ship completion generators instead of package-manager snippets.
__dotfiles_bash_load_generated_completion codex codex completion bash
__dotfiles_bash_load_generated_completion docker docker completion bash
__dotfiles_bash_load_generated_completion gh gh completion -s bash
__dotfiles_bash_load_generated_completion git-spice git-spice shell completion bash
__dotfiles_bash_configure_git_spice_alias_completion
__dotfiles_bash_load_generated_completion kubectl env KUBECONFIG=/dev/null kubectl completion bash
__dotfiles_bash_load_fzf_shell_support

unset -f __dotfiles_bash_source_if_readable
unset -f __dotfiles_bash_load_completion_framework
unset -f __dotfiles_bash_load_git_completion
unset -f __dotfiles_bash_load_generated_completion
unset -f __dotfiles_bash_configure_git_spice_alias_completion
unset -f __dotfiles_bash_load_fzf_shell_support
unset dotfiles_bash_tool_support_home
