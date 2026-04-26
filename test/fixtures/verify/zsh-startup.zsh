[[ "${XDG_CONFIG_HOME:-}" == "$HOME/.config" ]]
[[ "${XDG_CACHE_HOME:-}" == "$HOME/.cache" ]]
[[ "${XDG_DATA_HOME:-}" == "$HOME/.local/share" ]]
[[ "${XDG_STATE_HOME:-}" == "$HOME/.local/state" ]]
[[ "${dotfiles_config_home:-}" == "$HOME/.config" ]]
[[ "${dotfiles_shell_config_home:-}" == "$HOME/.config/shell" ]]
[[ "${dotfiles_zsh_config_home:-}" == "$HOME/.config/zsh" ]]
[[ "${dotfiles_state_home:-}" == "$HOME/.local/state" ]]
[[ "${dotfiles_zsh_state_home:-}" == "$HOME/.local/state/zsh" ]]
[[ "${dotfiles_zsh_cache_home:-}" == "$HOME/.cache/zsh" ]]
[[ "${HISTFILE:-}" == "$HOME/.local/state/zsh/history" ]]
[[ "${HISTSIZE:-}" == 50000 ]]
[[ "${SAVEHIST:-}" == 50000 ]]

if [[ -x /opt/homebrew/bin/brew ]]; then
  [[ "$(command -v brew 2>/dev/null)" == "/opt/homebrew/bin/brew" ]]
  [[ "${HOMEBREW_PREFIX:-}" == "/opt/homebrew" ]]
elif [[ -x /usr/local/bin/brew ]]; then
  [[ "$(command -v brew 2>/dev/null)" == "/usr/local/bin/brew" ]]
  [[ "${HOMEBREW_PREFIX:-}" == "/usr/local" ]]
fi

(( $+functions[_git] == 1 ))
if zstyle -s ":completion:*:*:git:*" script git_completion_script; then
  [[ -r "$git_completion_script" ]]
fi
autoload +X _git
if [[ -r "${dotfiles_zsh_config_home:-}/completion.zsh" ]] && command -v gh >/dev/null 2>&1; then
  (( ${+_comps[gh]} == 1 )) || exit 1
fi
if [[ -r "${dotfiles_zsh_config_home:-}/completion.zsh" ]] \
  && command -v kubectl >/dev/null 2>&1; then
  (( ${+_comps[kubectl]} == 1 )) || exit 1
fi

git_completion_error="${TMPDIR:-/tmp}/dotfiles_zsh_git_completion_$$.err"
COMP_WORDS=(git rebase fe)
COMP_CWORD=2
words=(git rebase fe)
CURRENT=3
cur=fe
_git >/dev/null 2>"$git_completion_error" || true
! grep -q "no such file or directory\\|command not found: __git_aliased_command" "$git_completion_error"
rm -f "$git_completion_error"

command -v make-chrome-app >/dev/null
count=0
for fn in $precmd_functions; do
  [[ $fn == __dotfiles_zsh_precmd ]] && (( count += 1 ))
done
(( count == 1 ))
