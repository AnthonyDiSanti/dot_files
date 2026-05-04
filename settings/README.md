# settings/

Scripts and assets for applying **macOS defaults**, **Git config**, and similar.
See individual files and `settings/osx_all.sh` / `settings/git.sh` entry points.

## Cursor Agent CLI

`settings/cursor-agent-cli.sh` merges repo-managed Cursor Agent CLI preferences
into the live `cli-config.json` while preserving Cursor-owned auth, cache, and
local state. The shell startup layer exports `CURSOR_CONFIG_DIR` to
`$XDG_CONFIG_HOME/cursor`, so the managed live path is normally
`~/.config/cursor/cli-config.json`, not the official fallback
`~/.cursor/cli-config.json`.

- `settings/cursor-agent-cli.json` contains the stable preferences this repo
  manages, including the required baseline fields for a new config and the
  current Auto/default model selection required by the local Cursor Free-plan
  CLI behavior.
- Do not symlink the whole live Cursor config into the repo; it includes
  auth-adjacent and CLI-managed state.

## Solarized (not vendored here)

This repo **does not** ship the full [altercation/solarized](https://github.com/altercation/solarized) tree anymore. It was an unused **git submodule** (~19MB of reference ports for dozens of apps) and nothing in `bootstrap.sh` or shell automation consumed it.

- **Vim** uses **[lifepillar/vim-solarized8](https://github.com/lifepillar/vim-solarized8)** via vim-plug (`home/.vimrc`).
- **tmux** colors in this repo are inlined in `home/.tmux.conf` (Solarized-inspired hex in comments and status bar).
- **Ghostty** Solarized Dark is checked in as `home/.config/ghostty/config` (bootstrap links `~/.config/ghostty/config`). Reload Ghostty after changes (e.g. **Cmd+Shift+,**).
- **iTerm2** Solarized Dark is checked in as a dynamic profile at `home/Library/Application Support/iTerm2/DynamicProfiles/solarized-dark.json` (bootstrap links it into iTerm2's watched DynamicProfiles folder). Run `settings/iterm2.sh` to set **Solarized Dark (dotfiles)** as the default profile for new iTerm2 windows and make `tmux -CC` inherit the connecting session profile instead of iTerm2's special `tmux` profile.
- **Other apps** (Terminal.app, Xresources, etc.): clone or browse upstream when you need a profile, or copy canonical hex values from the [Solarized homepage](https://ethanschoonover.com/solarized/) / repo README.

See also `.context/knowledge/solarized.md`.
