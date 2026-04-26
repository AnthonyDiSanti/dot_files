count=0
old_path=

old_path=$PATH

# Zsh interactive login startup runs .zprofile and then .zshrc.
. "$HOME/.zprofile"
. "$HOME/.zshrc"
[[ "$PATH" == "$old_path" ]]

. "$HOME/.zprofile"
. "$HOME/.zshrc"
[[ "$PATH" == "$old_path" ]]

for fn in $precmd_functions; do
  [[ $fn == __dotfiles_zsh_precmd ]] && (( count += 1 ))
done
(( count == 1 ))

if zstyle -s ":completion:*:*:git:*" script git_completion_script; then
  [[ -r "$git_completion_script" ]]
fi
autoload +X _git
