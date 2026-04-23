if [[ ${DOTFILES_BASH_RC_LOADED:-0} == 1 ]]; then
  return 0
fi
DOTFILES_BASH_RC_LOADED=1
export DOTFILES_BASH_RC_LOADED

__dotfiles_bash_source_first_readable() {
  local path

  for path in "$@"; do
    [[ -r "$path" ]] || continue
    source "$path"
    return 0
  done

  return 1
}

if command -v git >/dev/null 2>&1; then
  export GIT_PS1_SHOWDIRTYSTATE='auto'
  export GIT_PS1_SHOWUNTRACKEDFILES='auto'
  export GIT_PS1_SHOWUPSTREAM='auto'

  __dotfiles_bash_source_first_readable \
    "$HOME/.config/bash/git-prompt.sh" \
    "/opt/homebrew/etc/bash_completion.d/git-prompt.sh" \
    "/opt/homebrew/share/git-core/contrib/completion/git-prompt.sh" \
    "/usr/local/etc/bash_completion.d/git-prompt.sh" \
    "/usr/local/share/git-core/contrib/completion/git-prompt.sh" \
    "/usr/share/git/completion/git-prompt.sh" \
    "/usr/share/git-core/contrib/completion/git-prompt.sh"

  __dotfiles_bash_source_first_readable \
    "$HOME/.config/bash/git-completion.bash" \
    "/opt/homebrew/etc/bash_completion.d/git-completion.bash" \
    "/opt/homebrew/share/git-core/contrib/completion/git-completion.bash" \
    "/usr/local/etc/bash_completion.d/git-completion.bash" \
    "/usr/local/share/git-core/contrib/completion/git-completion.bash" \
    "/usr/share/bash-completion/completions/git"
fi

if [ -r "$HOME/.config/bash/prompt.bash" ]; then
  source "$HOME/.config/bash/prompt.bash"
fi

# Filled block cursor on WSL only (avoids grep noise on macOS where /proc/version is absent).
if [[ -r /proc/version ]] && grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
  echo -ne '\e[2 q'
fi

if [ -r "$HOME/.bash_local" ]; then
  source "$HOME/.bash_local"
fi

if [[ ${DOTFILES_USE_BUILTIN_PS1:-1} != 0 ]] && declare -F __dotfiles_set_ps1 >/dev/null 2>&1; then
  __dotfiles_set_ps1
fi
