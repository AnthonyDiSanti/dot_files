# Dotfiles

Personal dotfiles and setup scripts for shell, Vim, tmux, Git, and macOS
workstation settings.

## Bootstrap

This repo uses a repo-native bootstrap to symlink dotfiles into `$HOME`.

### Initial Setup

1. Install `git` for your OS.
2. Clone this repo.
3. Run `./bootstrap.sh`.

`bootstrap.sh` interprets the checked-out `home/` tree as a literal `$HOME`
mirror and symlinks each managed leaf back into the repo. It keeps a small state
file under `XDG_STATE_HOME` / `~/.local/state/dotfiles/` so later bootstrap runs
can clean up removed or reshaped managed targets.

### Previewing Changes

1. Run `./bootstrap.sh --dry-run --verbose`.
2. Run `./bootstrap.sh --list-managed`.

### Verifying

1. Run `test/verify.sh`.

## Vim

Plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug).
The tracked `home/.vim/autoload/plug.vim` file is the vim-plug loader snapshot.
Bootstrap creates a real `~/.vim` directory and symlinks only repo-managed files
inside it; plugin clones install under the local `~/.vim/plugged/` directory.

The UI colorscheme is
[Solarized 8](https://github.com/lifepillar/vim-solarized8)
(`colorscheme solarized8`), which supports true color via `termguicolors` and
falls back to 256-color mode when that is off. `home/.vimrc` sets the `t_8f` /
`t_8b` sequences from `:help xterm-true-color`. tmux enables RGB passthrough
with `terminal-features` in `home/.tmux.conf`; reload tmux after pulling. If
true color is wrong over SSH, run `set notermguicolors` and
`:colorscheme solarized8` for the 256-color fallback.

### Initial Plugin Setup

1. Run `./bootstrap.sh` so `~/.vim/autoload/plug.vim` points at this checkout.
2. Open Vim and run `:PlugInstall`.

### Updating Plugins

1. Open Vim.
2. Run `:PlugUpdate`.

### Removing Old Plugin Directories

If you remove a `Plug` line from `home/.vimrc`, run `:PlugClean` in Vim to
delete the matching tree under `~/.vim/plugged/`. For example, run it after
replacing `vim-colors-solarized` with `vim-solarized8`.

### Upgrading the vim-plug Script Itself

From Vim, `:PlugUpgrade` updates `plug.vim`. Because `~/.vim/autoload/plug.vim`
points at the tracked `home/.vim/autoload/plug.vim` snapshot, the upgrade
changes this repo file directly. Review and commit the snapshot when you want
the new version recorded.

### Adding New Plugins

1. Add a `Plug 'owner/repo'` line in `home/.vimrc` inside the `plug#begin` /
   `plug#end` block.
2. Run `:PlugInstall`.

## Terminal Colors

Ghostty and iTerm2 Solarized Dark settings are managed under `home/` and linked
by `./bootstrap.sh`. iTerm2 gets a dynamic profile named
`Solarized Dark (dotfiles)` under
`~/Library/Application Support/iTerm2/DynamicProfiles/`. Run
`settings/iterm2.sh` to make that profile the default for new iTerm2 windows
and let `tmux -CC` sessions inherit the connecting session profile.
