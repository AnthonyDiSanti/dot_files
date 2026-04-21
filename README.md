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
1. Run `script/verify`

Vim
===
Plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug). The
loader lives at `lib/vim-plug` (submodule) and is symlinked from
`home/.vim/autoload/plug.vim`; clones install under `~/.vim/plugged/` (gitignored).

### Initial Plugin Setup ###
1. Clone this repo with submodules: `git clone --recurse-submodules …` (or run
   `git submodule update --init` after clone).
2. Run `./bootstrap.sh` so `~/.vim` points at this checkout.
3. Open Vim and run `:PlugInstall`
4. If you previously used Vundle, remove the stale ignored tree: `rm -rf ~/.vim/bundle`

### Updating Plugins ###
1. Open Vim
2. Run `:PlugUpdate`

### Upgrading the vim-plug script itself ###
The loader is the **`lib/vim-plug` git submodule** (not only a downloaded file), so prefer updating it from the repo:

1. `git submodule update --remote lib/vim-plug`
2. Commit the submodule pointer if it changed

Alternatively, from Vim, **`:PlugUpgrade`** updates `plug.vim` (including when it is the target of `~/.vim/autoload/plug.vim`’s symlink). If you use that, check `git status` in `lib/vim-plug` and commit when you want the new version recorded.

### Adding New Plugins ###
1. Add a `Plug 'owner/repo'` line in `home/dot_vimrc` inside the `plug#begin` /
   `plug#end` block.
2. Run `:PlugInstall`
