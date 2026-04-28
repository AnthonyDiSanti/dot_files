# Tmux configuration

When to consult: changing `home/.tmux.conf`, tmux copy-mode bindings, terminal capability settings, or editor support for tmux config files.

## Current policy

- `home/.tmux.conf` targets modern tmux 3.x and is verified against tmux 3.6a.
- New panes/windows prefer interactive login zsh (`zsh -il`) when `zsh` exists on PATH, then interactive login Bash (`bash -il`) when `bash` exists, then tmux's default login-shell behavior. The fallback is implemented with tmux `if-shell` conditionals so hosts without zsh or bash keep normal tmux behavior.
- Interactive shell startup defines a `tmux` function when an external tmux binary is available: plain `tmux` runs `command tmux new-session -A -s default`, while any arguments delegate to `command tmux "$@"`. This makes vanilla `tmux` attach/create a session named `default`; if that session is renamed, the next plain `tmux` creates a new `default`.
- Inner terminal capabilities use `tmux-256color` and RGB passthrough via `terminal-features`. Keep `focus-events off` while using iTerm2 tmux control mode because focus transitions can produce unwanted bells/control-mode behavior; revisit only if Neovim/Vim focus-aware workflows become more important than control-mode quietness.
- Vi ergonomics are explicit: `status-keys vi` for tmux prompts and `mode-keys vi` for copy mode. Tmux prompt vi mode is a small prompt editor after `Esc`, not full Vim/ZLE; it supports motions like `h`/`l`, `0`/`$`, `b`/`w`, history with `k`/`j`, and prompt edits such as `D`.
- Copy mode uses Vim-like selection toggles: `v` for character selection, `V` for line selection, and `C-v` for rectangle selection. Repeating the active selection key clears selection; pressing another selection key switches mode. Tmux exposes rectangle state but not char-vs-line state, so the config tracks the mode selected by these bindings in `@dotfiles_copy_selection_mode` and calls `refresh-client` after mode changes. Fresh `V` uses `select-line` because tmux `selection-mode line` lazily applies and clobbers the anchor row; mid-selection `V` still uses the correct `rectangle-off ; selection-mode line` call and remains broken until tmux is fixed upstream. Avoid endpoint-bounce tricks such as `other-end` for repainting because they break line-mode selection semantics. Full upstream issue draft: [selection-mode line bug](../scratch/20260428-tmux-selection-mode-line-bug/report.md).
- New windows and custom split bindings preserve `#{pane_current_path}` so new panes/windows start from the active pane's directory.
- Side-by-side splits use prefix `v` / `V` / `C-v`; top/bottom splits use prefix `-`. This preserves tmux's default prefix `s` session chooser while trading away the lower-value default prefix `-` delete-buffer binding.
- Prefix `R` reloads `~/.tmux.conf`; prefix `C-b` intentionally maps to `last-window`, not nested-tmux `send-prefix`.
- Custom bindings use `bind -N` notes so prefix `?` documents prefix-table changes. Copy-mode binding notes are visible with `tmux list-keys -N -T copy-mode-vi`.
- Clipboard integration stays routed through `dotfiles-clipboard-tmux`. Do not enable tmux `set-clipboard` / OSC 52 in clipboard v1.
- iTerm2 tmux control mode (`tmux -CC`) rejects `aggressive-resize` and can mis-handle focus transitions. Keep `aggressive-resize` explicitly off as a global window option with `setw -g aggressive-resize off`, and keep `focus-events off` for control-mode compatibility. Preserve tmux's normal bell behavior with `bell-action any` and `monitor-bell on`; the focus problem is not solved by globally suppressing bells. `test/verify.sh` sources `home/.tmux.conf` into an isolated tmux server and asserts these stay set.
- Tmux paste buffers are process memory, not disk persistence, unless a user explicitly runs commands such as `save-buffer`. Automatic buffers are capped by `buffer-limit` and old automatic buffers are deleted when the cap is reached; explicitly named buffers persist in the tmux server until deleted. This makes default prefix `-` (`delete-buffer`) lower-value than an ergonomic split binding for this workflow.
- VS Code recommends the `malmaud.tmux` extension for tmux syntax highlighting; the extension handles tmux config file detection without a manual file association.
- No tmux plugin manager is configured. TPM, `tmux-resurrect`, and `tmux-continuum` are possible future work, but Anthony wants that evaluated after Neovim rather than in the current tmux/clipboard pass.

## Upstream line-selection bug follow-up

The saved upstream issue draft at [selection-mode line bug](../scratch/20260428-tmux-selection-mode-line-bug/report.md) has direct repo impact:

- Current fresh `V` line-selection entry intentionally uses `rectangle-off ; select-line` instead of the symmetric `begin-selection ; rectangle-off ; selection-mode line`. This avoids tmux's broken `selection-mode line` fresh-entry path.
- Current mid-selection `V` switching still uses `rectangle-off ; selection-mode line`, because that is the correct tmux command and there is no local replacement that preserves an existing multi-line range. This remains broken until tmux is fixed upstream.
- Once upstream fixes `selection-mode line`, the mid-selection path should work with no config change. Then optionally migrate fresh `V` back to `begin-selection ; rectangle-off ; selection-mode line` for symmetry and Vim-like cursor-column preservation.
- Before changing this config after an upstream fix, retest the full `v` / `V` / `C-v` / `Space` / `Escape` matrix from the issue draft, including fresh `V`, `v` to `V`, rectangle to `V`, `V` to `v`, and toggle-off behavior.
