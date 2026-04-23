# Handoff

## Current State
- What works: chezmoi bootstrap (`bootstrap.sh`) installs dotfiles from `home/`; shell startup now uses a POSIX baseline (`.profile` / `.shrc`) plus bash and zsh wrappers backed by `~/.config/{shell,bash,zsh}/`; Vim plugins use **vim-plug** (`lib/vim-plug` submodule, `~/.vim/plugged/` after `:PlugInstall`).
- Editor direction: **Vanilla Vim** is the target for dotfiles (Vim 8+ compatible plugins, no Neovim requirement) so SSH sessions can stay simple: get dotfiles on the machine, bootstrap, use `vim`. **Neovim** is explicitly a possible next step—see `context/decisions.md`—not part of the current plugin migration.
- What’s in progress: Shell startup now has the new POSIX baseline plus bash/zsh wrappers; the remaining shell work is the zsh prompt/completion port on top of that shared layout. The shell-language split is now intentional rather than transitional: `bootstrap.sh` is POSIX `sh`, `scripts/verify.sh` remains bash as a repo-local dev tool, and zsh is the interactive target. Codex now loads the managed `~/.codex/rules/global.rules` symlink from chezmoi, with broad `git` and `npm` allow rules and an empty local `default.rules`.
- What’s broken / flaky: No known issues.

## Next Steps (ordered)
1. Finish the zsh prompt and completion port on top of the new shared shell baseline, while keeping bash stable.
2. Write a fuller repo documentation pass once the bootstrap, shell, and editor setup have a more permanent shape.
3. **Third-to-last (planned):** Re-evaluate all **git submodules** and managed CLI utilities (`~/.local/bin`) — see `context/tasks.md` task `01KPR9WB7K84CJXMSM8HD9VQRX`.
4. **Second-to-last (planned):** Review the **tmux** configuration after that submodule/CLI audit and before any Neovim decision — see `context/tasks.md` task `01KPVT9N992M71VGJVBXDATR7B`.
5. **Final (planned):** Consider **Neovim** only after that — see `context/tasks.md` / `context/decisions.md`; vanilla Vim remains the default until then.

## Active Tasks
None (see `tasks.md`).

## Quick Verify
- Fast checks: `bash -n` on edited shell scripts; `chezmoi --source "$PWD" diff` or temporary-destination apply for dotfile target-state review.
- Full gate: `scripts/verify.sh`; add manual smoke tests for touched interactive tools such as Vim when behavior changes.

## Recent Updates (keep last ~15; prune older)
- 2026-04-22 — **Shell language roles clarified:** treat POSIX `sh` as the portability layer for deployment/shared runtime baselines, keep `scripts/verify.sh` in bash for predictable repo-local command orchestration, and reserve zsh effort for interactive prompt/completion UX. This is now a deliberate policy, not just a legacy artifact.
- 2026-04-22 — **Bootstrap no longer depends on a chezmoi config template:** removed `home/.chezmoi.toml.tmpl`, made `bootstrap.sh` pass `--config /dev/null --config-format toml --mode symlink` directly, pinned its persistent state under `~/.local/state`, and updated `scripts/verify.sh` plus docs so bootstrap is self-contained and no longer warns about stale config-template state.
- 2026-04-22 — **Shell baseline refactor:** Replaced the repo-root `DOTFILESDIR` startup path with a POSIX baseline (`.profile` / `.shrc`), shell-specific wrappers for bash/zsh, shared config under `~/.config/shell/`, shell-specific config under `~/.config/{bash,zsh}/`, and CLI utilities under `~/.local/bin/`. The deployed shell stack is symlink-backed again, including symlink templates for vendored git helpers, so `git pull` and submodule updates flow through without re-running bootstrap; temp-home bash/zsh startup smoke passes with the new layout.
- 2026-04-22 — **Bootstrap now hydrates submodules:** `bootstrap.sh` runs `git submodule update --init --recursive` when the repo is a real git checkout, then applies chezmoi state. Live `./bootstrap.sh` and the full `./scripts/verify.sh` gate both pass after this change.
- 2026-04-22 — **Shell tooling split clarified:** `scripts/verify.sh` still uses bash as the driver but now treats `zsh` as a required dev dependency and always runs zsh checks. `bootstrap.sh` is now POSIX `sh`, since deployment portability matters more there.
- 2026-04-22 — **Roadmap tail update:** Inserted a planned **tmux config review** between the submodule/CLI audit and the final Neovim evaluation.
- 2026-04-21 — **Roadmap tail:** Planned **third-to-last** workstream — re-evaluate all **git submodules** and managed CLI utilities under `home/dot_local/bin/`; **Neovim** consideration is the **final** planned item (`context/tasks.md`).
- 2026-04-21 — **Vim + Solarized + Ghostty (single color stack):** **vim-plug** (`lib/vim-plug` submodule, `plug#begin('~/.vim/plugged')`, upgraded ctrlpvim / easymotion / mundo / preservim NERD*, Gundo → Mundo). **Vim colors:** **lifepillar/vim-solarized8** (`colorscheme solarized8`, `termguicolors`, `t_8f`/`t_8b`); removed unused **`settings/solarized`** submodule; **tmux** `terminal-features ',*:RGB'` for true-color passthrough. **Ghostty:** `home/dot_config/ghostty/config` → `~/.config/ghostty/config` — Solarized Dark (Xresources hex), `alpha-blending = native`, `palette-generate = true`, `macos-titlebar-style = transparent`. **`scripts/verify.sh`** extended for `.config/ghostty/*`; `settings/README.md`, `context/knowledge/solarized.md`, README/AGENTS/context updated. `scripts/verify.sh` passes.
- 2026-04-20 — Removed dropped Vim plugins from `home/dot_vimrc` and `home/.vim/bundle/` (language stacks, a.vim, capslock, matchit); removed LESS compile maps.
- 2026-04-20 — Decided to abandon Vundle for Vim native packages, drop language plugins and capslock, upgrade CtrlP/EasyMotion/Mundo/NERD* as planned, prefer ctrlpvim over fzf.vim for in-editor UX; require cleaning config references to removed plugins.
- 2026-04-20 — Committed to vanilla Vim for dotfile portability over SSH; recorded Neovim as a future step in `decisions.md` and tasks.
- 2026-04-20 — Replaced the seeded Codex rule list with broad managed `git` and `npm` allow rules, applied the live `~/.codex/rules/global.rules` symlink, and cleared the local `default.rules`.
- 2026-04-20 — Seeded managed `home/private_dot_codex/rules/global.rules` from the current local Codex `default.rules` so portable approvals can be curated back out of the generated file.
- 2026-04-20 — Clarified in repo and template `AGENTS.md` that `/context` is a helpful snapshot, but live repo evidence should win when they conflict.
- 2026-04-20 — Recorded future workstreams for Codex rule-file split, repo documentation, and bash-to-zsh migration.
- 2026-04-20 — Confirmed Codex scans `.rules` files under `~/.codex/rules/`; keep generated `default.rules` unmanaged and plan a curated managed `global.rules`.
- 2026-04-20 — Replaced Puppet bootstrap with chezmoi symlink-mode source state, ran bootstrap on the live home directory, and tracked the follow-up Vim migration.
- 2026-04-20 — Added `scripts/verify.sh` as a lightweight full gate for shell syntax, chezmoi source mapping, temporary apply, live convergence, and shell startup.
- 2026-04-20 — Replaced Homebrew-only chezmoi install guidance in bootstrap/README with generic OS-aware wording.
- 2026-04-20 — Switched the managed Codex directory to `private_dot_codex` so `~/.codex` stays `700`.
- 2026-04-13 — Strengthened the global AGENTS guidance to require proactive notebook updates and a proposed commit message for the full uncommitted diff after every turn.
- 2026-04-13 — Removed the seeded `code_template/docs` topic scaffold and replaced it with a lightweight landing page plus flexible docs guidance.
- 2026-04-13 — Folded the live repo `context/reference/` split into `context/knowledge/` and updated AGENTS/context guidance to match.
- 2026-04-13 — Merged `context/user_shared/` into `context/scratch/` so the repo has one git-tracked staging area for drafts, experiments, and collaborative work.
- 2026-04-13 — Standardized repo and template `decisions.md` files to keep newest entries first.
- 2026-04-13 — Reworked `code_template` around `/docs` as canonical documentation and trimmed `/context` to live working memory.
- 2026-04-13 — Updated `code_template` to require proactive doc maintenance and restored `context/knowledge` for agent-oriented supplemental notes.
- 2026-04-13 — Merged `code_template/context/user_shared/` into `code_template/context/scratch/`.
- 2026-02-04 — Added a no-tech-debt rule to the global AGENTS guidance.
- 2026-01-20 — Switched `tasks.md` to ULID-based IDs and updated templates/README guidance.
