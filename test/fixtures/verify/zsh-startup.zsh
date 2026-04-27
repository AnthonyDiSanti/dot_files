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
[[ -o EXTENDED_HISTORY ]]
(( ${+functions[history]} == 1 ))
history_fixture_dir="${DOTFILES_VERIFY_FIXTURE:h}"
history_fixture_input="$history_fixture_dir/zsh-history.input"
history_fixture_expected="$history_fixture_dir/zsh-history.expected"
history_fixture_file="${TMPDIR:-/tmp}/dotfiles_zsh_history_$$"
history_fixture_actual="${TMPDIR:-/tmp}/dotfiles_zsh_history_actual_$$"
cp "$history_fixture_input" "$history_fixture_file"
fc -p "$history_fixture_file" 10 0
TZ=UTC history 1 3 >"$history_fixture_actual"
diff -u "$history_fixture_expected" "$history_fixture_actual"
fc -P
rm -f "$history_fixture_file" "$history_fixture_actual"
unset history_fixture_actual history_fixture_dir history_fixture_expected history_fixture_file history_fixture_input
(( ${+widgets[edit-command-line]} == 1 ))
(( ${+widgets[history-beginning-search-menu]} == 1 ))
(( ${+widgets[up-line-or-beginning-search]} == 1 ))
(( ${+widgets[down-line-or-beginning-search]} == 1 ))
(( ${+widgets[select-bracketed]} == 1 ))
(( ${+widgets[select-quoted]} == 1 ))
(( ${+widgets[add-surround]} == 1 ))
(( ${+widgets[change-surround]} == 1 ))
(( ${+widgets[delete-surround]} == 1 ))
(( ${+widgets[__dotfiles_zsh_set_cursor_for_keymap]} == 1 ))
(( ${+widgets[__dotfiles_zsh_reset_cursor]} == 1 ))
(( ${+widgets[select-entire-buffer]} == 1 ))
zstyle -a zle-line-init widgets zle_line_init_widgets
zstyle -a zle-keymap-select widgets zle_keymap_select_widgets
zstyle -a zle-line-finish widgets zle_line_finish_widgets
quoted_outer_double=$'a"'
quoted_inner_double=$'i"'
quoted_outer_single="a'"
quoted_inner_single="i'"
(( ${zle_line_init_widgets[(I)*:__dotfiles_zsh_set_cursor_for_keymap]} > 0 ))
(( ${zle_keymap_select_widgets[(I)*:__dotfiles_zsh_set_cursor_for_keymap]} > 0 ))
(( ${zle_line_finish_widgets[(I)*:__dotfiles_zsh_reset_cursor]} > 0 ))
[[ "$(bindkey -M viins '^E')" == *edit-command-line ]]
[[ "$(bindkey -M vicmd '^E')" == *edit-command-line ]]
[[ "$(bindkey -M emacs '^[[A')" == *up-line-or-beginning-search ]]
[[ "$(bindkey -M emacs '^[[B')" == *down-line-or-beginning-search ]]
[[ "$(bindkey -M menuselect h)" == *vi-backward-char ]]
[[ "$(bindkey -M menuselect j)" == *vi-down-line-or-history ]]
[[ "$(bindkey -M menuselect k)" == *vi-up-line-or-history ]]
[[ "$(bindkey -M menuselect l)" == *vi-forward-char ]]
[[ "$(bindkey -M viopp ae)" == *select-entire-buffer ]]
[[ "$(bindkey -M viopp "$quoted_outer_double")" == *select-quoted ]]
[[ "$(bindkey -M viopp "$quoted_outer_single")" == *select-quoted ]]
[[ "$(bindkey -M viopp 'a`')" == *select-quoted ]]
[[ "$(bindkey -M viopp 'a(')" == *select-bracketed ]]
[[ "$(bindkey -M viopp 'ab')" == *select-bracketed ]]
[[ "$(bindkey -M visual "$quoted_inner_double")" == *select-quoted ]]
[[ "$(bindkey -M visual ae)" == *select-entire-buffer ]]
[[ "$(bindkey -M visual "$quoted_inner_single")" == *select-quoted ]]
[[ "$(bindkey -M visual 'i`')" == *select-quoted ]]
[[ "$(bindkey -M visual 'i[')" == *select-bracketed ]]
[[ "$(bindkey -M visual 'iB')" == *select-bracketed ]]
[[ "$(bindkey -M vicmd cs)" == *change-surround ]]
[[ "$(bindkey -M vicmd ds)" == *delete-surround ]]
[[ "$(bindkey -M vicmd ys)" == *add-surround ]]
[[ "$(bindkey -M visual S)" == *add-surround ]]
if command -v fzf >/dev/null 2>&1 \
  && fzf --zsh >/dev/null 2>&1; then
  [[ "$(bindkey -M viins '^R')" == *fzf-history-widget ]]
  [[ "$(bindkey -M emacs '\ec')" == *fzf-cd-widget ]]
  [[ "$(bindkey -M viins '\ec' 2>/dev/null || true)" != *fzf-cd-widget ]]
  [[ "$(bindkey -M vicmd '\ec' 2>/dev/null || true)" != *fzf-cd-widget ]]
else
  [[ "$(bindkey -M viins '^R')" == *history-incremental-search-backward ]]
fi
zstyle -a ':completion:*' matcher-list completion_matchers
completion_matcher='m:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}'
(( ${completion_matchers[(Ie)$completion_matcher]} > 0 ))
zmodload -e zsh/complist
zstyle -t ':completion:*' verbose
zstyle -s ':completion:*' group-name completion_group_name
[[ -z "$completion_group_name" ]]
zstyle -s ':completion:*' list-colors completion_list_colors
[[ -z "$completion_list_colors" ]]
zstyle -s ':completion:*:descriptions' format completion_descriptions_format
[[ "$completion_descriptions_format" == '%F{yellow}%d%f' ]]
zstyle -s ':completion:*:messages' format completion_messages_format
[[ "$completion_messages_format" == '%F{cyan}%d%f' ]]
zstyle -s ':completion:*:warnings' format completion_warnings_format
[[ "$completion_warnings_format" == '%F{red}no matches: %d%f' ]]
zstyle -t ':completion:*' list-dirs-first
zstyle -a ':completion:*' menu completion_menu
(( ${completion_menu[(Ie)select=2]} > 0 ))
unset completion_descriptions_format completion_group_name completion_list_colors completion_matcher completion_matchers
unset completion_menu completion_messages_format completion_warnings_format
unset quoted_inner_double quoted_inner_single quoted_outer_double quoted_outer_single
unset zle_keymap_select_widgets zle_line_finish_widgets zle_line_init_widgets

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
if command -v codex >/dev/null 2>&1 \
  && codex completion zsh >/dev/null 2>&1; then
  (( ${+_comps[codex]} == 1 )) || exit 1
fi
if command -v docker >/dev/null 2>&1 \
  && docker completion zsh >/dev/null 2>&1; then
  (( ${+_comps[docker]} == 1 )) || exit 1
fi
if command -v gh >/dev/null 2>&1 \
  && gh completion -s zsh >/dev/null 2>&1; then
  (( ${+_comps[gh]} == 1 )) || exit 1
fi
if command -v git-spice >/dev/null 2>&1 \
  && git-spice shell completion zsh >/dev/null 2>&1; then
  (( ${+_comps[git-spice]} == 1 )) || exit 1
  [[ "${_comps[gs]-}" == "${_comps[git-spice]-}" ]] || exit 1
fi
if command -v kubectl >/dev/null 2>&1 \
  && env KUBECONFIG=/dev/null kubectl completion zsh >/dev/null 2>&1; then
  (( ${+_comps[kubectl]} == 1 )) || exit 1
fi
if command -v fzf >/dev/null 2>&1 \
  && fzf --zsh >/dev/null 2>&1; then
  (( ${+functions[fzf-file-widget]} == 1 )) || exit 1
  (( ${+functions[fzf-history-widget]} == 1 )) || exit 1
  (( ${+functions[fzf-completion]} == 1 )) || exit 1
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
