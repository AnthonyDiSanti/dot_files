[ "${ENV:-}" = "$HOME/.shrc" ]
[ "${XDG_CONFIG_HOME:-}" = "$HOME/.config" ]
[ "${XDG_CACHE_HOME:-}" = "$HOME/.cache" ]
[ "${XDG_DATA_HOME:-}" = "$HOME/.local/share" ]
[ "${XDG_STATE_HOME:-}" = "$HOME/.local/state" ]
[ "${dotfiles_config_home:-}" = "$HOME/.config" ]
[ "${dotfiles_shell_config_home:-}" = "$HOME/.config/shell" ]
command -v brew >/dev/null 2>&1 || { [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; }
command -v make-chrome-app >/dev/null 2>&1
