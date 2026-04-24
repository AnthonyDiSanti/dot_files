if [ -r "$HOME/.profile" ]; then
  . "$HOME/.profile" || return 1
fi

if [ -r "$HOME/.zprofile_local" ]; then
  . "$HOME/.zprofile_local" || return 1
fi
