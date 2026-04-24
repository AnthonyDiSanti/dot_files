# Vim plugins (vim-plug)

- Source: `home/.vimrc`, `home/.vim` -> `../managed/vim`, and `lib/vim-plug/` (submodule) → `managed/vim/autoload/plug.vim`; installs land under `~/.vim/plugged/` (gitignored via `managed/vim/plugged/`).
- Why it matters: [vim-plug](https://github.com/junegunn/vim-plug) manages clones; submodule ships the single `plug.vim` loader without curl on bootstrap.
- When to consult: adding/removing plugins, bootstrap on a new machine, or debugging loads.
- Key points: After `git clone --recurse-submodules` and `./bootstrap.sh`, run `:PlugInstall` in Vim. **Mundo** needs Vim built with `+python3`. Update plugins with `:PlugUpdate`; update the vim-plug loader via `git submodule update --remote lib/vim-plug` (or `:PlugUpgrade`, then commit submodule changes).
- Colors: **[lifepillar/vim-solarized8](https://github.com/lifepillar/vim-solarized8)** (`colorscheme solarized8`) replaces altercation’s theme so terminal Vim can use **`termguicolors`** (24-bit) with `guifg`/`guibg`; it falls back to 256/16 when true color is off. `home/.vimrc` sets `t_8f` / `t_8b` per `:help xterm-true-color`. **tmux:** `home/.tmux.conf` uses `terminal-features ',*:RGB'` so inner Vim sees RGB; reload tmux config after changes. **SSH / old terms:** if colors are off, `set notermguicolors` then `:colorscheme solarized8`.
- Gotchas: Remove maps/`g:` for plugins you delete. After swapping or removing a plugin, run **`:PlugClean`** so stale dirs (e.g. `plugged/vim-colors-solarized/`) are removed from `plugged/`.
