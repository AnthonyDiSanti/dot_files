# settings/

Scripts and assets for applying **macOS defaults**, **Git config**, and similar.
See individual files and `settings/osx_all.sh` / `settings/git.sh` entry points.

## Solarized (not vendored here)

This repo **does not** ship the full [altercation/solarized](https://github.com/altercation/solarized) tree anymore. It was an unused **git submodule** (~19MB of reference ports for dozens of apps) and nothing in `bootstrap.sh` or shell automation consumed it.

- **Vim** uses **[lifepillar/vim-solarized8](https://github.com/lifepillar/vim-solarized8)** via vim-plug (`home/.vimrc`).
- **tmux** colors in this repo are inlined in `home/.tmux.conf` (Solarized-inspired hex in comments and status bar).
- **Ghostty** Solarized Dark is checked in as `home/.config/ghostty/config` (bootstrap links `~/.config/ghostty/config`). Reload Ghostty after changes (e.g. **Cmd+Shift+,**).
- **Other apps** (iTerm2, Terminal.app, Xresources, etc.): clone or browse upstream when you need a profile, or copy canonical hex values from the [Solarized homepage](https://ethanschoonover.com/solarized/) / repo README.

See also `.context/knowledge/solarized.md`.
