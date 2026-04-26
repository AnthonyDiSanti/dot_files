[[ "${XDG_CONFIG_HOME:-}" == "$HOME/.config" ]]
[[ "${XDG_CACHE_HOME:-}" == "$HOME/.cache" ]]
[[ "${XDG_DATA_HOME:-}" == "$HOME/.local/share" ]]
[[ "${XDG_STATE_HOME:-}" == "$HOME/.local/state" ]]
[[ "${dotfiles_config_home:-}" == "$HOME/.config" ]]
[[ "${dotfiles_shell_config_home:-}" == "$HOME/.config/shell" ]]
[[ "${dotfiles_bash_config_home:-}" == "$HOME/.config/bash" ]]
[[ "${dotfiles_state_home:-}" == "$HOME/.local/state" ]]
[[ "${dotfiles_bash_state_home:-}" == "$HOME/.local/state/bash" ]]
[[ "${HISTFILE:-}" == "$HOME/.local/state/bash/history" ]]
[[ "${HISTSIZE:-}" == 50000 ]]
[[ "${HISTFILESIZE:-}" == 50000 ]]
shopt -q histappend cmdhist lithist

if [[ -x /opt/homebrew/bin/brew ]]; then
  [[ "$(command -v brew 2>/dev/null)" == "/opt/homebrew/bin/brew" ]]
  [[ "${HOMEBREW_PREFIX:-}" == "/opt/homebrew" ]]
elif [[ -x /usr/local/bin/brew ]]; then
  [[ "$(command -v brew 2>/dev/null)" == "/usr/local/bin/brew" ]]
  [[ "${HOMEBREW_PREFIX:-}" == "/usr/local" ]]
fi

command -v make-chrome-app >/dev/null
declare -F __git_ps1 >/dev/null 2>&1
declare -F __git_complete >/dev/null 2>&1
declare -F __dotfiles_set_ps1 >/dev/null 2>&1
case ";${PROMPT_COMMAND:-};" in
  *";__dotfiles_set_ps1;"*) ;;
  *) exit 1 ;;
esac
