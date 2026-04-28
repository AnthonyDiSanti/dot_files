# Zsh vi mode

When to consult: changing `home/.config/zsh/rc.zsh` line-editor bindings, ZLE widgets, completion menu behavior, or vi-mode ergonomics.

## Sources
- Local docs: `man zshzle`, `man zshcontrib`, and `man zshmodules`.
- Inspiration: Oh My Zsh `vi-mode` for conservative mode/cursor behavior; `jeffreytse/zsh-vi-mode` for a fuller plugin-style feature set.

## Notes
- zsh ships native vi text objects: `aw`/`iw`, `aW`/`iW`, and shell-argument objects `aa`/`ia`.
- `select-quoted` and `select-bracketed` are shipped contrib widgets and should be bound in `viopp` and `visual`, so combinations such as `ci"` and `da(` work as operator/text-object flows.
- `ae` is a custom whole-buffer text object in this repo, bound in `viopp` and `visual` for flows such as `dae`, `yae`, `cae`, and `vae`.
- Custom text objects that use `emulate -L zsh` should follow zsh's shipped endpoint pattern: set `MARK`, set `CURSOR` to the inclusive visual endpoint, then increment `CURSOR` once when `KEYMAP=vicmd` and `REGION_ACTIVE=0` so operators include the final character.
- zsh also ships `surround`, inspired by `vim-surround`; the documented bindings are `cs`, `ds`, `ys`, and visual `S`. It does not implement every Vim plugin gesture, notably `yss`.
- fzf's `Alt-C` binding is `Esc-c`; keep it out of zsh vi keymaps because it collides with `Esc` followed by `c` operators such as `caw` and `cae`.
- Non-clipboard vi mode is intentionally conservative now. Future clipboard work should reason about Vim's anonymous register and zsh's `CUTBUFFER` together rather than adding a broad copy-on-every-delete hook.
- `select-word-match` is a customizable word-style text object, not Vim `*` search. Leave it unbound unless a custom word style such as camel/subword matching becomes useful.
- `zsh/complist` menu selection uses the `menuselect` keymap. Bind `h`/`j`/`k`/`l` there rather than stealing terminal control chords like `Ctrl-H`, `Ctrl-J`, `Ctrl-K`, and `Ctrl-L`.
- Cursor strategy is aligned across Bash and zsh: insert/default mode uses a steady beam (`ESC [6 q`), while command/operator/visual mode uses a steady block (`ESC [2 q`). zsh drives this through ZLE keymap hooks; Bash drives it through Readline `vi-ins-mode-string` / `vi-cmd-mode-string` with nonprinting markers.
