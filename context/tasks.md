# Tasks

Task IDs are ULIDs; keep titles short and human-readable.

## Roadmap ordering (tail)
Planned **last three** items before considering the dotfiles “mature” for this phase:
1. **Third-to-last:** Re-evaluate all **git submodules** and managed CLI utilities under **`home/dot_local/bin/`** / `~/.local/bin` (still needed, versions, security, PATH ergonomics, docs).
2. Review the **tmux** configuration and decide what cleanup or modernization is still needed before editor-shell integration is considered stable.
3. **Final:** **Neovim** evaluation — see task `01KPNZ4YNEOVIMEVALSTEP2026` (optional; vanilla Vim stays the portable SSH baseline unless you deliberately switch).

## Active
- id: 01KPNZ3YBAKB9N4ZJEXW4P2EHP — title: Migrate shell infrastructure to zsh — owner: Anthony/Codex — status: active — last update: 2026-04-22 — note: POSIX baseline + bootstrap simplification checkpoint reached; zsh now has a native prompt/completion layer, and the next slice is tuning interactive UX on top of that shared layout while keeping bash stable.

## Paused / Blocked
- id: 01KPWZ6ZQPJHEE3YM1BYVPG679 — title: Do an XDG integration pass — owner: Anthony/Codex — status: planned — last update: 2026-04-23 — note: Planned immediately after the current zsh-focused shell work; audit config, cache, state, and data locations across shell/runtime files and managed utilities to move repo-managed behavior toward a cleaner XDG layout where it makes sense.
- id: 01KPR9WB7K84CJXMSM8HD9VQRX — title: Re-evaluate git submodules and CLI utility contents — owner: Anthony/Codex — status: planned — last update: 2026-04-22 — note: Roadmap **third-to-last** — audit `lib/*`, `.gitmodules`, and each managed `home/dot_local/bin/*` utility for currency and fit.
- id: 01KPVT9N992M71VGJVBXDATR7B — title: Review tmux configuration — owner: Anthony/Codex — status: planned — last update: 2026-04-22 — note: Planned after the submodule/CLI audit and before the Neovim evaluation.
- id: 01KPNZ3YB7K74CJXMSM8HD9VQR — title: Write repo documentation pass — owner: Anthony/Codex — status: planned — last update: 2026-04-20
- id: 01KPNZ4YNEOVIMEVALSTEP2026 — title: Evaluate Neovim after Vim migration stabilizes — owner: Anthony — status: planned — last update: 2026-04-21 — note: Roadmap **final** item after the submodule/CLI audit and tmux review; optional; vanilla Vim remains the portable SSH baseline.

## Completed (recent; keep last ~10)
- id: 01KPNC22ZGDW3M9SGG6GNTYNSW — title: Migrate Vim from Vundle to vim-plug + plugin refresh — owner: Anthony/Codex — status: done — last update: 2026-04-21 — note: vim-plug + lib submodule; upgraded repos; drop language plugins + capslock done earlier.
- id: 01KPNC22ZK4F5TBEQJ3QYXQXMK — title: Review non-portable Vim colors — owner: Anthony/Codex — status: done — last update: 2026-04-21 — note: Solarized 8 + termguicolors; tmux RGB passthrough; SSH fallback documented in knowledge/vim.md
- id: 01KPNZ3YB3YV5H4SW4NDFDRRE7 — title: Split Codex rules into curated global file — owner: Anthony/Codex — status: done — last update: 2026-04-20
- id: 01KPNCXYF9JGX5D6DPZE2FDHB7 — title: Add lightweight bootstrap verification — owner: Codex (model: gpt-5.4) — status: done — last update: 2026-04-20
- id: 01KPMQQMJB1875SVN6FMD2RVMG — title: Implement chezmoi bootstrap migration — owner: Codex (model: gpt-5.4) — status: done — last update: 2026-04-20
- id: 01KP3BK8CKJMEZMC402YYVPRVJ — title: Strengthen global notebook and commit rules — owner: Codex (model: gpt-5.2-codex) — status: done — last update: 2026-04-13
- id: 01KP3BBZ7QM352FJBYPXHES4D8 — title: Lighten code_template docs scaffold — owner: Codex (model: gpt-5.2-codex) — status: done — last update: 2026-04-13
- id: 01KP3B51BKMYS0GBYT6Z7921BX — title: Fold repo reference notes into knowledge — owner: Codex (model: gpt-5.2-codex) — status: done — last update: 2026-04-13
- id: 01KP39VX2MRPFN9W61ZF4TFAZ4 — title: Merge repo user_shared into scratch and reorder decisions — owner: Codex (model: gpt-5.2-codex) — status: done — last update: 2026-04-13
- id: 01KP39KSBFMKY3XE7GYXJV23MD — title: Merge code_template user_shared into scratch — owner: Codex (model: gpt-5.2-codex) — status: done — last update: 2026-04-13
