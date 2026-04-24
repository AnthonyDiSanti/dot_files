# AGENTS.md — Project Contract for Coding Agents

This repo contains personal dotfiles, system settings scripts, and a few small utilities for macOS-oriented setup.
Keep changes small, reversible, and consistent with existing patterns. Do not include secrets.

## 0) Local overrides (AGENTS.local.md)
If `AGENTS.local.md` exists at the repo root:
- Read it at the start of work and treat it as **machine-specific overrides**.
- It is gitignored and must not be relied on for shared/team workflows.

What belongs in `AGENTS.local.md`:
- Local environment quirks (broken Node/npm, alternate commands, paths, ports, OS-specific steps)
- Anything that is true for *this machine* but not necessarily for others

What does NOT belong there:
- Global behavioral instructions (those live in your global setup)
- Repo truth (tech stack, architecture, standard commands that should apply to everyone)
- Large duplicated content from this file

Precedence:
- This file (`AGENTS.md`) is the source of truth for repo details.
- `AGENTS.local.md` may override **commands and environment steps** only when necessary on this machine.
- If local overrides materially change how the project is run/tested, record a short note in `/context/handoff.md`.

Maintenance:
- Keep `AGENTS.local.md` short and delta-based.
- If a local override turns out to be broadly applicable, migrate it into `AGENTS.md`.

## 1) Project overview
- What this project is: Personal dotfiles and setup scripts for shell, Vim, tmux, Git, and agent configs, primarily on macOS.
- Key user-facing behavior: `./bootstrap.sh` hydrates git submodules from a real checkout, then interprets the tracked `home/` tree as a literal `$HOME` mirror and symlinks managed targets into place; shell startup reads shared config from `~/.config/shell/` and shell-specific config from `~/.config/bash/` or `~/.config/zsh/`; `settings/*.sh` apply macOS defaults and Git config; `~/.local/bin/make-chrome-app` generates a Chrome app wrapper.
- Non-goals / out of scope: Not a general-purpose app/library; not cross-platform; no CI/test harness; avoid ad-hoc edits inside vendored directories.
- Definition of done: Dotfiles updated in the literal `home/` target-tree form (plus `managed/` for whole-directory symlink cases), bootstrap/scripts run without errors on macOS, and `/context` is kept current.

## 2) Tech stack & constraints
- Languages + versions: Shell (bash/sh, system), Vimscript (`home/.vimrc`), TOML (`home/.codex/config.toml`), plist/dict (`settings/OSXKeyBindings.dict`). Vendored C/etc lives under `lib/git/` (do not edit).
- Frameworks: None.
- Package manager: None in-repo (system installs via Homebrew/RubyGems are assumed externally).
- Storage/database: None.
- Deployment target: Local macOS workstation; **WSL** is supported (e.g. block-cursor tweak in `home/.config/bash/rc.bash` only after `[[ -r /proc/version ]]`). Vim configuration targets **vanilla Vim** (8+) so dotfiles stay usable over SSH on typical servers; Neovim is optional future work—see `/context/decisions.md`.
- Constraints (perf/security/compliance/no-new-deps/etc.): Prefer macOS-compatible commands (`defaults`, `sips`, `tiff2icns`); avoid touching vendored directories; keep scripts compatible with their shebang (`bash` vs `sh`); no secrets in repo. **Live-update principle:** `git pull` on the repo should update deployed config without re-running bootstrap except when the deployment shape changes. Prefer symlinks into the repo, including real symlink nodes in `home/` for vendored assets or whole-directory cases such as `home/.vim`, over copied/runtime-generated files for long-lived config.

## 3) Repo map
- Key directories:
  - `home/` — literal `$HOME` target tree for managed dotfiles (shell, tmux, Codex/Claude config, symlink nodes such as `home/.vim`).
  - `home/.config/shell/` — POSIX-compatible shared shell baseline for `sh`, `bash`, and `zsh`.
  - `home/.config/bash/` — bash-specific interactive setup (prompt, git helpers, WSL cursor tweak).
  - `home/.config/zsh/` — zsh-specific interactive setup.
  - `home/.local/bin/` — user CLI utilities installed to `~/.local/bin/`.
  - `managed/` — repo-owned directories exposed through symlink nodes from `home/` when a whole target tree should stay linked as a directory (currently `managed/vim` via `home/.vim`).
  - `scripts/` — repo-local checks (`scripts/verify.sh`) and small tools (e.g. `print-ansi-colors.sh`); not added to `PATH`.
  - `settings/` — macOS defaults scripts, Git config scripts, keybindings; see `settings/README.md` (Solarized is not vendored; Vim uses vim-solarized8 via vim-plug).
  - `lib/` — vendored dependencies (`lib/git` for prompt/completion; `lib/make-chrome-app`).
  - `context/` — shared working memory for humans and agents.
  - `code_template/` — template skeleton for new repos (AGENTS/context, etc.).
- Where to add new:
  - Shared shell setup for `sh`/`bash`/`zsh`: `home/.config/shell/`.
  - Bash-only shell setup: `home/.config/bash/`.
  - Zsh-only shell setup: `home/.config/zsh/`.
  - CLI utilities: `home/.local/bin/`.
  - Dotfiles: `home/` using literal target names and real symlink nodes where appropriate.
  - Whole-directory symlink cases: put the real directory under `managed/`, then expose it via a symlink node in `home/` (for example `home/.vim` -> `../managed/vim`).
  - macOS defaults: `settings/osx_*.sh` (wire into `settings/osx_all.sh` if needed).
  - Git config: `settings/git/*.sh` (invoked by `settings/git.sh`).
  - Vim plugins: [vim-plug](https://github.com/junegunn/vim-plug); loader symlinked from `lib/vim-plug` into `managed/vim/autoload/plug.vim`; `:PlugInstall` populates `~/.vim/plugged/` (ignored via `managed/vim/plugged/`). Keep `home/.vimrc` free of stale references when plugins are removed.
- “Do not touch” paths (if any):
  - `lib/git/`, `lib/vim-plug/`, and plugin installs under `home/.vim/plugged/` (ignored) follow normal submodule / `:PlugUpdate` workflows.

## 4) Commands
Setup:
- Install deps: `git` (required for `bootstrap.sh`), `zsh` (required for `scripts/verify.sh`), Vim 8+ with `git` (for `:PlugInstall`), Python 3 linked to Vim if using vim-mundo (`:version` should show `+python3`), `tiff2icns` if using `make-chrome-app`.
- Env setup: `./bootstrap.sh` (POSIX `sh`; hydrates submodules and applies the repo-native symlink-backed home tree).

Run:
- Apply macOS defaults: `settings/osx_all.sh` (or `settings/osx_general.sh` and `settings/safari.sh` individually).
- Apply Git config: `settings/git.sh`.
- Create a Chrome app wrapper: `~/.local/bin/make-chrome-app` (macOS only).

Verify (targeted first, full at end):
- Fast checks (lint/typecheck/unit): `bash -n path/to/script.sh` for modified shell scripts; `./bootstrap.sh --dry-run --verbose` for dotfile target-state review.
- Run a single test: Manual smoke check of the changed script or config (e.g., open a new shell and ensure `.bash_profile` loads cleanly).
- Full suite (final gate): `scripts/verify.sh`.
- Build (final gate if applicable): Not applicable.

## 5) Engineering standards
- Formatting: Match existing style; 2-space indentation in shell scripts, keep shebangs consistent (`/usr/bin/env bash` vs `sh`).
- Lint rules: None enforced; optional `shellcheck` or `bash -n` for shell edits.
- Types: Not applicable.
- Error handling/logging: Prefer explicit error checks and clear `echo` output; keep shared helpers in `home/.config/shell/functions.sh`.
- Testing expectations: Run `scripts/verify.sh` for bootstrap/dotfile changes; it checks shell syntax, repo-native managed target mapping, temporary-home apply behavior, live-home convergence, and shell startup.
- Dependency policy: Allowed, but keep vendored deps isolated and update them as cohesive version bumps.
- Refactor stance: Prefer clarity and consistency, but avoid rewriting vendored directories.

## 6) Git commits (workflow)
When a coherent unit of work is complete, pause and recommend a git commit with a proposed message. The message format must be:
1) Title in present tense
2) Blank line
3) Bullet list of key changes

## 7) /context — shared working memory (COMMITTED)
This repo uses `/context` as durable, agent-facing working memory.
It is committed to git to support continuity across devices and developers.

### Goals
- Prevent repeated escalations by recording knowledge once.
- Enable multi-session continuity and agent handoffs.
- Keep key decisions and knowledge discoverable.

### Context Structure
- `/context/README.md` — purpose, scope, and how the context files are used in this repo.
- `/context/handoff.md` — current state and next steps (living snapshot).
- `/context/tasks.md` — active/paused/completed workstreams.
- `/context/decisions.md` — decision log with dates and rationale, newest first. Use `Decider: Anthony` for human decisions and `Decider: Codex (model: gpt-5.2-codex)` for agent decisions.
- `/context/knowledge/` — curated repo, vendor, and workflow insights with “when to consult” guidance (index at `knowledge/index.md`).
- `/context/scratch/` — git-tracked staging area for collaborative drafts, experiments, pre-repo code, and other content that does not yet have a stable home in the repo; namespace by task ID or work thread and clean it up after promotion.

### /context hygiene rules
- Store summaries and insights, not giant dumps.
- Prefer updating existing notes over creating many redundant files.
- Never store secrets.
- Keep `/context` concise and retrieval-oriented: live state belongs in `handoff.md`, `tasks.md`, and `decisions.md`, while reusable knowledge belongs in `knowledge/`.
- Treat `/context` as a helpful snapshot, not infallible ground truth: when it conflicts with live repo evidence (`git status`, current files, recent commits, or the working tree), prefer the live state and reconcile `/context` before answering status or “what’s next?” questions.

## 8) Documentation references (maintain)
List the project’s key references and when to consult them:
- `README.md` — Vim plugin install/update steps.
- `bootstrap.sh` and `scripts/home_tree_manifest.sh` — before changing bootstrap or symlink behavior.
- `home/.profile`, `home/.shrc`, `home/.bash_profile`, `home/.bashrc`, `home/.zprofile`, `home/.zshrc`, and `home/.config/{shell,bash,zsh}/` — before changing shell startup, PATH, prompt, or shared functions.
- `settings/osx_*.sh` — before changing macOS defaults.
- `settings/git.sh` and `settings/git/*.sh` — before altering Git global config.
- `settings/README.md` — scope of `settings/`; Solarized reference links (upstream not vendored).
- `/context/knowledge/index.md` — quick repo, vendor, and workflow notes plus links to deeper topics.

Capture external docs only when they are:
- repeatedly referenced,
- broadly insightful,
- or likely to prevent recurring mistakes.

Documentation maintenance rule:
- When a change materially affects stable repo behavior, navigation, debugging, or an external system the repo depends on, update the nearest durable doc in the same change. In this repo that usually means `README.md`, a README in the touched subtree, or a topic under `/context/knowledge/` when the note is primarily agent-facing.
- Preserve the boundary: `/context/handoff.md`, `/context/tasks.md`, and `/context/decisions.md` are live state, while `/context/knowledge/` holds reusable knowledge.

## 9) Continuous improvement of instructions (silent edits allowed)
This file should evolve as friction is discovered.

Proactively update AGENTS.md when:
- repeated mistakes recur across sessions,
- missing command/path details cause slowdowns,
- new boundaries need to be enforced (security, do-not-touch paths, etc.).

Guidelines:
- Make changes small and specific.
- Avoid vague rules; prefer testable directives.
- Keep the file compact.

## 10) Workarounds and risk
If you are considering shipping a workaround instead of a root-cause fix:
- Pause and switch to interactive discussion.
- Propose the modified plan, justification, pros/cons, risks, and cleanup path.
- Do not degrade security posture for convenience.
