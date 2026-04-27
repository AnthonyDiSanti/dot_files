# Clipboard integration

When to consult: changing Vim clipboard settings, zsh ZLE yank/paste widgets, tmux copy-mode bindings, or shell clipboard provider behavior.

## Current plan
- Vim's anonymous register behavior appears correct with the current `.vimrc`; do not change it unless a specific mismatch appears.
- zsh vi-mode should start with explicit yank integration: after `vi-yank`, `vi-yank-whole-line`, and `vi-yank-eol`, copy `CUTBUFFER` to the system clipboard.
- zsh paste integration can refresh `CUTBUFFER` from the system clipboard immediately before `vi-put-before` / `vi-put-after`. This is acceptable even if slightly imperfect; avoid background real-time watchers unless a clear need appears.
- Smaller zsh delete/change sync from `d` / `c` motions is optional final polish only after explicit yanks and paste-time refresh work. Do not copy every delete/change by default without an explicit decision.
- tmux copy-mode `y` should ideally copy the selection into both the tmux paste buffer and the system clipboard.
- Prefer app-native clipboard options where they cover the use case. Add a small internal provider only if needed for shared macOS plus Ubuntu-under-WSL behavior.
- Avoid submodule-backed clipboard dependencies; prefer built-in app options, system clipboard commands, or small repo-owned helpers.

## Provider stance
- macOS provider: `pbcopy` / `pbpaste`.
- WSL provider: Windows clipboard bridge, likely PowerShell / `clip.exe` for copy and PowerShell `Get-Clipboard` for paste if available.
- Avoid a heavy third-party clipboard dependency unless the internal adapter grows beyond a small, auditable script.
- Do not expose public shell helper commands such as `copyfile` / `copypath` unless they naturally fall out of the provider and are wanted as user-facing commands.
