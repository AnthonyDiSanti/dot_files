# Solarized assets (no submodule)

- **Vim:** `lifepillar/vim-solarized8` in `home/dot_vimrc` / `~/.vim/plugged` — not `altercation/vim-colors-solarized`.
- **Ghostty:** `home/dot_config/ghostty/config` → `~/.config/ghostty/config` — Solarized Dark (canonical hex from upstream Xresources); `alpha-blending = native` (Display P3 on macOS); `palette-generate = true` for a Solarized-derived 256-color cube; `macos-titlebar-style = transparent` so window chrome matches base03.
- **Repo:** We removed the **`settings/solarized`** git submodule (full upstream monorepo). It was reference-only and unused by bootstrap. Restoring it is optional: Ghostty/iTerm2 theming does not require the submodule if hex values are inlined or fetched from upstream when needed.
- **When to consult:** You need Terminal.app / iTerm2-only assets or other ports — clone [altercation/solarized](https://github.com/altercation/solarized) or use app-specific docs; see `settings/README.md`.
