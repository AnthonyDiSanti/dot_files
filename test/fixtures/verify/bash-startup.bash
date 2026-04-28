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
[[ "${HISTTIMEFORMAT:-}" == "%F %T " ]]
shopt -q checkwinsize histappend cmdhist lithist
bind -m vi-insert -q edit-and-execute-command | grep -q 'edit-and-execute-command can be invoked via "\\C-e"'
bind -m vi-command -q vi-edit-and-execute-command | grep -q 'vi-edit-and-execute-command can be invoked via "\\C-e"'
bind -q history-search-backward | grep -q 'history-search-backward can be invoked'
bind -q history-search-forward | grep -q 'history-search-forward can be invoked'
bind -v | grep -q '^set completion-ignore-case on$'
bind -v | grep -q '^set enable-active-region off$'
bind -v | grep -q '^set show-mode-in-prompt on$'
bind -v | grep -Fqx $'set vi-ins-mode-string \001\e[6 q\002'
bind -v | grep -Fqx $'set vi-cmd-mode-string \001\e[2 q\002'
declare -F dotfiles_have_command >/dev/null 2>&1
declare -F dotfiles_command_succeeds >/dev/null 2>&1
if bind -v | grep -q '^set completion-map-case '; then
  bind -v | grep -q '^set completion-map-case on$'
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  [[ "$(command -v brew 2>/dev/null)" == "/opt/homebrew/bin/brew" ]]
  [[ "${HOMEBREW_PREFIX:-}" == "/opt/homebrew" ]]
elif [[ -x /usr/local/bin/brew ]]; then
  [[ "$(command -v brew 2>/dev/null)" == "/usr/local/bin/brew" ]]
  [[ "${HOMEBREW_PREFIX:-}" == "/usr/local" ]]
fi

declare -F __git_ps1 >/dev/null 2>&1
complete -p git >/dev/null 2>&1
if dotfiles_command_succeeds codex completion bash; then
  complete -p codex >/dev/null 2>&1 || exit 1
fi
if dotfiles_command_succeeds docker completion bash; then
  complete -p docker >/dev/null 2>&1 || exit 1
fi
if dotfiles_command_succeeds gh completion -s bash; then
  complete -p gh >/dev/null 2>&1 || exit 1
fi
if dotfiles_command_succeeds git-spice shell completion bash; then
  complete -p git-spice >/dev/null 2>&1 || exit 1
  complete -p gs >/dev/null 2>&1 || exit 1
fi
if KUBECONFIG=/dev/null dotfiles_command_succeeds kubectl completion bash; then
  complete -p kubectl >/dev/null 2>&1 || exit 1
fi
if dotfiles_command_succeeds fzf --bash; then
  declare -F fzf-file-widget >/dev/null 2>&1 || exit 1
  declare -F __fzf_history__ >/dev/null 2>&1 || exit 1
  complete -p fzf >/dev/null 2>&1 || exit 1
fi
declare -F __dotfiles_set_ps1 >/dev/null 2>&1
case ";${PROMPT_COMMAND:-};" in
  *";__dotfiles_set_ps1;"*) ;;
  *) exit 1 ;;
esac
