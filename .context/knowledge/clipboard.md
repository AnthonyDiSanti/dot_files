# Clipboard integration

When to consult: changing Vim clipboard settings, zsh ZLE yank/paste widgets, tmux copy-mode bindings, or shell clipboard provider behavior.

## Current plan
- Clipboard v1 is scoped to macOS plus Ubuntu under WSL / Windows. Do not add untested Linux desktop providers or OSC 52 behavior in this pass.
- `home/.local/bin/dotfiles-clipboard` is the repo-owned wrapper API. It currently supports macOS via `pbcopy` / `pbpaste`.
- Vim's anonymous register behavior appears correct with the current `.vimrc`; do not change it unless a specific mismatch appears.
- zsh vi-mode wraps CUTBUFFER-producing widgets: explicit yanks plus delete/change/substitute paths (`d`, `c`, `C`, `D`, `S`, `s`, `x`, `X`) copy `CUTBUFFER` to the system clipboard when `dotfiles-clipboard status` succeeds.
- zsh paste integration refreshes `CUTBUFFER` from the system clipboard immediately before `vi-put-before` / `vi-put-after`, and before visual `put-replace-selection`. This is intentionally paste-time only; avoid background real-time watchers unless a clear need appears.
- tmux copy-mode `y` and `Enter` use `copy-pipe-and-cancel`, so the selection remains in the tmux paste buffer while a supported `dotfiles-clipboard copy` provider receives stdin. Unsupported providers drain stdin and return quietly.
- tmux prefix `]` refreshes the newest automatic tmux paste buffer from `dotfiles-clipboard paste`, then pastes it with native bracketed-paste behavior. If the provider is missing or unsupported, it falls back to native `paste-buffer -p`.
- tmux prefix `C-y` imports `dotfiles-clipboard paste` into the newest automatic tmux paste buffer without pasting. If unsupported, it leaves the existing tmux buffer alone.
- tmux prefix `p` remains the stock `previous-window` binding; do not reuse it for clipboard import.
- `home/.local/bin/dotfiles-clipboard-tmux` owns tmux-specific clipboard glue (`copy`, `import`, `paste`), including unsupported clipboard-provider fallbacks and `mktemp` buffer import handling. It requires `tmux`; keep graceful degradation scoped to missing platform clipboard support. Keep `.tmux.conf` focused on bindings.
- Tmux clipboard integration is complete for v1. Further tmux clipboard work should be a deliberate v2 item, such as OSC 52, broader mouse-copy handling, or named-buffer policy changes.
- Do not enable tmux `set-clipboard` in clipboard v1. It uses OSC 52-style terminal clipboard integration, which is useful later but would introduce a second clipboard path before the macOS/WSL wrapper is stable.
- Prefer app-native clipboard options where they cover the use case. Add a small internal provider only if needed for shared macOS plus Ubuntu-under-WSL behavior.
- Avoid submodule-backed clipboard dependencies; prefer built-in app options, system clipboard commands, or small repo-owned helpers.

## Provider stance
- macOS provider: `pbcopy` / `pbpaste`.
- WSL provider: Windows clipboard bridge. `win32yank.exe` is third-party and should be preferred if installed because it has symmetric copy/paste behavior; Microsoft-provided options include `clip.exe` for copy and PowerShell `Get-Clipboard` / `Set-Clipboard` where reliable.
- Linux desktop providers (`wl-copy` / `wl-paste`, `xclip`, `xsel`) are out of scope for v1 because they are not available for local testing in this workflow.
- Avoid a heavy third-party clipboard dependency unless the internal adapter grows beyond a small, auditable script.
- Do not expose public shell helper commands such as `copyfile` / `copypath` unless they naturally fall out of the provider and are wanted as user-facing commands.
- Integrations must degrade quietly when `dotfiles-clipboard` is missing or no provider is supported. Native app-local behavior should still work: zsh keeps normal `CUTBUFFER` yanks/pastes, and tmux keeps its paste buffer.

## Clipboard model
- Bash/readline and zsh/ZLE expose shell-local kill rings/registers, not an OS clipboard. Bash's Readline kill ring is mostly opaque; zsh exposes `CUTBUFFER`, `killring`, and vi registers directly.
- Linux GUI clipboards belong to the display/session layer: X11 has selections such as `CLIPBOARD` and `PRIMARY`, while Wayland exposes clipboard behavior through the compositor/protocol stack. A headless SSH shell has no inherent GUI clipboard.
- OSC 52 is a terminal escape sequence that asks the terminal emulator to set clipboard text. It can copy from a remote SSH program to the local terminal clipboard if the terminal and any multiplexer allow it, but paste/read-back is terminal-dependent and commonly restricted.

## Wrapper API direction
- Treat this as unifying app-local buffers/registers with real platform clipboards. Do not spend much effort on a shadow clipboard for shells that lack useful native integration unless a concrete workflow demands it.
- Preferred internal command surface is text-first and pipe-oriented:
  - `dotfiles-clipboard copy` reads stdin and stores text in the selected platform clipboard.
  - `dotfiles-clipboard paste` writes platform clipboard text to stdout.
  - `dotfiles-clipboard status` prints the detected provider and exits nonzero when no provider is usable.
- Preserve bytes/text as faithfully as the provider permits: do not add a trailing newline, trim content, or normalize line endings unless a provider requires it. If WSL needs CRLF/LF normalization, keep it inside that provider branch.
- Defer MIME/data-type variants until a real need appears. zsh and tmux integrations need `text/plain`; image/file/rich-text clipboard formats would add provider complexity without current value.
- Provider priority should target macOS and WSL/Windows first: `pbcopy`/`pbpaste` on macOS; `win32yank.exe` if installed on WSL, otherwise PowerShell/Windows clipboard commands where reliable.
- Keep OSC 52 as a copy-only terminal path to evaluate separately from the core provider wrapper; it is useful across SSH but is not a symmetric paste API.

## External inspiration
- `clipboard-cli` / `clipboardy`: useful precedent for a tiny cross-platform copy/paste surface; also confirms headless Linux lacks a system clipboard.
- `tmux-yank`: useful precedent for tmux integration using a provider command that accepts stdin, with macOS, Linux, Cygwin, and WSL provider detection.
- `wl-clipboard`, `xclip`, and `xsel`: useful precedent for pipe-oriented Linux desktop provider behavior and the `CLIPBOARD` vs `PRIMARY` distinction.
- `win32yank`: useful precedent for WSL/Windows Vim-style clipboard bridging, especially copy/paste symmetry and CRLF/LF handling.
