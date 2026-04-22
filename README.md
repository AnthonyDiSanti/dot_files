Bootstrap
=========

This repo uses [chezmoi](https://www.chezmoi.io/) to symlink dotfiles into
`$HOME`.

### Initial Setup ###
1. Install chezmoi for your OS: <https://www.chezmoi.io/install/>
   - On Homebrew systems: `brew install chezmoi`
2. Clone this repo, including submodules: `git clone --recurse-submodules ...`
3. Run `./bootstrap.sh`

`bootstrap.sh` runs `chezmoi apply` with this repo as the source, adding
`--init` only when the chezmoi config is missing or older than the repo
template. The chezmoi source root is `home/`, configured by `.chezmoiroot`, and
`home/.chezmoi.toml.tmpl` sets symlink mode.

### Previewing Changes ###
1. Run `chezmoi --source "$PWD" diff`
2. Run `./bootstrap.sh --dry-run --verbose`

### Verifying ###
1. Run `scripts/verify.sh`

Vim
===
Plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug). The
loader lives at `lib/vim-plug` (submodule) and is symlinked from
`home/.vim/autoload/plug.vim`; clones install under `~/.vim/plugged/` (gitignored).

The UI colorscheme is **[Solarized 8](https://github.com/lifepillar/vim-solarized8)** (`colorscheme solarized8`), which supports **true color** via `termguicolors` and falls back to 256-color mode when that is off. `dot_vimrc` sets the `t_8f` / `t_8b` sequences from `:help xterm-true-color`. **tmux** enables RGB passthrough with `terminal-features` in `dot_tmux.conf`; reload tmux after pulling. If true color is wrong over SSH, run `set notermguicolors` and `:colorscheme solarized8` (256-color fallback).

### Initial Plugin Setup ###
1. Clone this repo with submodules: `git clone --recurse-submodules …` (or run
   `git submodule update --init` after clone).
2. Run `./bootstrap.sh` so `~/.vim` points at this checkout.
3. Open Vim and run `:PlugInstall`
4. If you previously used Vundle, remove the stale ignored tree: `rm -rf ~/.vim/bundle`

### Updating Plugins ###
1. Open Vim
2. Run `:PlugUpdate`

### Removing old plugin directories ###
If you remove a `Plug` line from `home/dot_vimrc`, run **`:PlugClean`** in Vim to delete the matching tree under `~/.vim/plugged/` (for example after replacing **vim-colors-solarized** with **vim-solarized8**).

### Upgrading the vim-plug script itself ###
The loader is the **`lib/vim-plug` git submodule** (not only a downloaded file), so prefer updating it from the repo:

1. `git submodule update --remote lib/vim-plug`
2. Commit the submodule pointer if it changed

Alternatively, from Vim, **`:PlugUpgrade`** updates `plug.vim` (including when it is the target of `~/.vim/autoload/plug.vim`’s symlink). If you use that, check `git status` in `lib/vim-plug` and commit when you want the new version recorded.

### Adding New Plugins ###
1. Add a `Plug 'owner/repo'` line in `home/dot_vimrc` inside the `plug#begin` /
   `plug#end` block.
2. Run `:PlugInstall`
