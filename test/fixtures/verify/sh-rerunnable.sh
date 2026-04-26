old_path=$PATH

. "$HOME/.profile"
[ "$PATH" = "$old_path" ]

. "$HOME/.shrc"
[ "$PATH" = "$old_path" ]
