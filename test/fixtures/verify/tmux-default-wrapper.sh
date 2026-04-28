: >"$DOTFILES_FAKE_TMUX_LOG"

type tmux >/dev/null 2>&1

tmux
tmux list-sessions
tmux -L custom list-sessions

first_line=$(sed -n '1p' "$DOTFILES_FAKE_TMUX_LOG")
second_line=$(sed -n '2p' "$DOTFILES_FAKE_TMUX_LOG")
third_line=$(sed -n '3p' "$DOTFILES_FAKE_TMUX_LOG")
fourth_line=$(sed -n '4p' "$DOTFILES_FAKE_TMUX_LOG")

[ "$first_line" = "new-session -A -s default" ]
[ "$second_line" = "list-sessions" ]
[ "$third_line" = "-L custom list-sessions" ]
[ -z "$fourth_line" ]
