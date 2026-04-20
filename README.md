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
### Initial Plugin Setup ###
1. Open vim
2. Run :BundleInstall

### Updating Plugins ###
1. Open vim
2. Run :BundleInstall!

### Adding New Plugins ###
1. Add the new plugin to vimrc using the Vundle syntax
2. Open vim
3. Run :BundleInstall
