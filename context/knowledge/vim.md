# Vim plugins (vim-plug)

- Source: `home/dot_vimrc`, `lib/vim-plug/` (submodule) → `~/.vim/autoload/plug.vim` symlink, installs under `~/.vim/plugged/` (gitignored).
- Why it matters: [vim-plug](https://github.com/junegunn/vim-plug) manages clones; submodule ships the single `plug.vim` loader without curl on bootstrap.
- When to consult: adding/removing plugins, bootstrap on a new machine, or debugging loads.
- Key points: After `git clone --recurse-submodules` and `./bootstrap.sh`, run `:PlugInstall` in Vim. **Mundo** needs Vim built with `+python3`. Update plugins with `:PlugUpdate`; update the vim-plug loader via `git submodule update --remote lib/vim-plug` (or `:PlugUpgrade`, then commit submodule changes).
- Colors: `vim-colors-solarized` needs `g:solarized_termcolors=256` when `t_Co >= 256`. Keying off `&term` containing `"256"` misses terminals like **Ghostty** (`xterm-ghostty`), which then used 16-color ANSI and looked wrong unless the terminal’s 16-color palette matched Solarized.
- Gotchas: Remove maps/`g:` for plugins you delete. After moving to vim-plug, delete legacy `~/.vim/bundle/` (ignored clones) once `~/.vim/plugged/` is populated.
