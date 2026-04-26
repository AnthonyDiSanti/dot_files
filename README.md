Bootstrap
=========

This repo uses a repo-native bootstrap to symlink dotfiles into `$HOME`.

### Initial Setup ###
1. Install `git` for your OS.
2. Clone this repo, including submodules: `git clone --recurse-submodules ...`
3. Run `./bootstrap.sh`

`bootstrap.sh` hydrates git submodules, interprets the tracked `home/` tree as a
literal `$HOME` mirror, and symlinks each managed leaf back into the repo. It
keeps a small state file under `XDG_STATE_HOME` / `~/.local/state/dotfiles/` so
later bootstrap runs can clean up removed or reshaped managed targets.

### Previewing Changes ###
1. Run `./bootstrap.sh --dry-run --verbose`
2. Run `./bootstrap.sh --list-managed`

### Verifying ###
1. Run `test/verify.sh`

Vim
===
Plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug). The
loader lives at `lib/vim-plug` (submodule). The managed `home/.vim` entry is a
symlink node into `managed/vim/`, where `autoload/plug.vim` points at the
submodule; clones install under `~/.vim/plugged/` (gitignored in the repo via
`managed/vim/plugged/`).

The UI colorscheme is **[Solarized 8](https://github.com/lifepillar/vim-solarized8)** (`colorscheme solarized8`), which supports **true color** via `termguicolors` and falls back to 256-color mode when that is off. `home/.vimrc` sets the `t_8f` / `t_8b` sequences from `:help xterm-true-color`. **tmux** enables RGB passthrough with `terminal-features` in `home/.tmux.conf`; reload tmux after pulling. If true color is wrong over SSH, run `set notermguicolors` and `:colorscheme solarized8` (256-color fallback).

### Initial Plugin Setup ###
1. Clone this repo with submodules: `git clone --recurse-submodules …` (or run
   `git submodule update --init` after clone).
2. Run `./bootstrap.sh` so `~/.vim` points at this checkout.
3. Open Vim and run `:PlugInstall`

### Updating Plugins ###
1. Open Vim
2. Run `:PlugUpdate`

### Removing old plugin directories ###
If you remove a `Plug` line from `home/.vimrc`, run **`:PlugClean`** in Vim to delete the matching tree under `~/.vim/plugged/` (for example after replacing **vim-colors-solarized** with **vim-solarized8**).

### Upgrading the vim-plug script itself ###
The loader is the **`lib/vim-plug` git submodule** (not only a downloaded file), so prefer updating it from the repo:

1. `git submodule update --remote lib/vim-plug`
2. Commit the submodule pointer if it changed

Alternatively, from Vim, **`:PlugUpgrade`** updates `plug.vim` (including when it is the target of `~/.vim/autoload/plug.vim`’s symlink). If you use that, check `git status` in `lib/vim-plug` and commit when you want the new version recorded.

### Adding New Plugins ###
1. Add a `Plug 'owner/repo'` line in `home/.vimrc` inside the `plug#begin` /
   `plug#end` block.
2. Run `:PlugInstall`
