# Vim plugins (Vundle + vendored bundles)

- Source: `home/dot_vimrc`, `home/.vim/bundle/`
- Why it matters: plugin list and plugin source live in-repo.
- When to consult: adding/removing plugins or updating themes.
- Key points: Vundle bundle list is defined in `home/dot_vimrc`; plugin directories are stored under `home/.vim/bundle`.
- Gotchas: keep the bundle directory in sync with `.vimrc` when plugin changes are made.
- Planned cleanup: migrate away from Vundle to Vim's native package/plugin support and revisit non-portable color configuration separately.
