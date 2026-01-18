# AGENTS.md — Project Contract for Coding Agents

This repo contains personal dotfiles, system settings scripts, and a few small utilities for macOS-oriented setup.
Keep changes small, reversible, and consistent with existing patterns. Do not include secrets.

## 0) Local addendum (AGENTS.local.md)
If `AGENTS.local.md` exists at the repo root:
- Read it at the start of work and treat it as personal addendum.
- It may be a symlink to user-global guidance.

Precedence rules:
- Repo facts (commands/paths/stack/constraints): this file (AGENTS.md) wins.
- Personal workflow + behavioral defaults: AGENTS.local.md may override.

Editing:
- You MAY edit AGENTS.local.md (silent edits allowed), but keep it behavioral and high-signal.
- Do NOT move repo-specific commands or stack details into AGENTS.local.md.

## 1) Project overview
- What this project is: Personal dotfiles and setup scripts for shell, Vim, tmux, Git, and agent configs, primarily on macOS.
- Key user-facing behavior: `./bootstrap.sh` symlinks dotfiles into `$HOME` via Puppet; `home/.bash_profile` sources `bash/*` and adds `bin/` to `PATH`; `settings/*.sh` apply macOS defaults and Git config; `bin/make-chrome-app` generates a Chrome app wrapper.
- Non-goals / out of scope: Not a general-purpose app/library; not cross-platform; no CI/test harness; avoid ad-hoc edits inside vendored directories.
- Definition of done: Dotfiles updated in the correct location, `site.pp` updated when links change, scripts run without errors on macOS, and `/context` is kept current.

## 2) Tech stack & constraints
- Languages + versions: Shell (bash/sh, system), Puppet DSL (`site.pp`), Vimscript (`home/.vimrc`), TOML (`home/.codex/config.toml`), plist/dict (`settings/OSXKeyBindings.dict`). Vendored C/etc lives under `lib/git/` (do not edit).
- Frameworks: None.
- Package manager: None in-repo (system installs via Homebrew/RubyGems are assumed externally).
- Storage/database: None.
- Deployment target: Local macOS workstation (with a small WSL/Linux check in `home/.bash_profile`).
- Constraints (perf/security/compliance/no-new-deps/etc.): Prefer macOS-compatible commands (`defaults`, `sips`, `tiff2icns`); avoid touching vendored directories; keep scripts compatible with their shebang (`bash` vs `sh`); no secrets in repo.

## 3) Repo map
- Key directories:
  - `home/` — dotfiles (shell, Vim, tmux, Codex/Claude config) to be linked into `$HOME`.
  - `bash/` — shell functions sourced by `home/.bash_profile`.
  - `bin/` — executable utilities added to `PATH`.
  - `settings/` — macOS defaults scripts, Git config scripts, keybindings, Solarized theme assets.
  - `lib/` — vendored dependencies (`lib/git` for prompt/completion; `lib/make-chrome-app`).
  - `context/` — shared working memory for humans and agents.
  - `code_template/` — template skeleton for new repos (AGENTS/context, etc.).
- Where to add new:
  - Shell functions: `bash/` (auto-sourced by `.bash_profile`).
  - CLI utilities: `bin/` (ensure executable bit).
  - Dotfiles: `home/` and update `site.pp` for new links.
  - macOS defaults: `settings/osx_*.sh` (wire into `settings/osx_all.sh` if needed).
  - Git config: `settings/git/*.sh` (invoked by `settings/git.sh`).
  - Vim plugins: update the Vundle list in `home/.vimrc` and vendor under `home/.vim/bundle/` to match current practice.
- “Do not touch” paths (if any):
  - `lib/git/`, `settings/solarized/`, `home/.vim/bundle/` are vendored; update only via upstream/versioned refreshes.

## 4) Commands
Setup:
- Install deps: Puppet (required for `bootstrap.sh`), Vim + Vundle (for `home/.vimrc`), `tiff2icns` if using `make-chrome-app`.
- Env setup: `./bootstrap.sh` (creates symlinks via Puppet).

Run:
- Apply macOS defaults: `settings/osx_all.sh` (or `settings/osx_general.sh` and `settings/safari.sh` individually).
- Apply Git config: `settings/git.sh`.
- Create a Chrome app wrapper: `bin/make-chrome-app` (macOS only).

Verify (targeted first, full at end):
- Fast checks (lint/typecheck/unit): `bash -n path/to/script.sh` for modified shell scripts; `puppet parser validate site.pp` if Puppet is installed.
- Run a single test: Manual smoke check of the changed script or config (e.g., open a new shell and ensure `.bash_profile` loads cleanly).
- Full suite (final gate): No automated suite; rely on manual validation of affected areas.
- Build (final gate if applicable): Not applicable.

## 5) Engineering standards
- Formatting: Match existing style; 2-space indentation in shell scripts, keep shebangs consistent (`/usr/bin/env bash` vs `sh`).
- Lint rules: None enforced; optional `shellcheck` or `bash -n` for shell edits.
- Types: Not applicable.
- Error handling/logging: Prefer explicit error checks and clear `echo` output; reuse `bash/exit_if_error.sh` where useful.
- Testing expectations: Manual smoke tests of touched scripts; confirm symlinks with `ls -l` after `bootstrap.sh`.
- Dependency policy: Allowed, but keep vendored deps isolated and update them as cohesive version bumps.
- Refactor stance: Prefer clarity and consistency, but avoid rewriting vendored directories.

## 6) /context — shared working memory (COMMITTED)
This repo uses `/context` as durable working memory for humans and agents.
It is committed to git to support continuity across devices and developers.

### Goals
- Prevent repeated escalations by recording knowledge once.
- Enable multi-session continuity and agent handoffs.
- Keep key decisions and references discoverable.

### Context Structure
- `/context/README.md` — purpose, scope, and how the context files are used in this repo.
- `/context/handoff.md` — current state and next steps (living snapshot).
- `/context/tasks.md` — active/paused/completed workstreams.
- `/context/decisions.md` — decision log with dates and rationale.
- `/context/knowledge.md` — curated repo insights and “when to consult”.
- `/context/reference/index.md` — index of deep reference notes (if/when needed).

### Reference Library (third-party docs, curated)
Maintain a deeper reference library at:
- `/context/reference/` — curated, digestible third-party reference notes.

Use `/context/reference` when:
- a vendor/API/system has complex edge cases worth preserving,
- you keep returning to the same third-party docs,
- or a subtle constraint is likely to cause repeated failures.

Rules for reference items:
- Prefer distilled notes + examples over raw dumps.
- Include: Source, Retrieved date, Why it matters, When to consult, Key gotchas, Minimal examples.
- Avoid storing large verbatim copies of third-party docs unless licensing explicitly permits it.
- Keep it small and useful: update/merge entries instead of creating endless files.

Linking rule:
- Every reference item must be linked from `/context/reference/index.md`.
- `knowledge.md` should point to the deeper reference item when appropriate.

### /context hygiene rules
- Store summaries and insights, not giant dumps.
- Prefer updating existing notes over creating many redundant files.
- Never store secrets.

## 7) Documentation references (maintain)
List the project’s key references and when to consult them:
- `README.md` — Vim plugin install/update steps.
- `bootstrap.sh` and `site.pp` — before adding/removing dotfiles or changing symlink behavior.
- `home/.bash_profile` — before changing shell startup, PATH, or sourced functions.
- `settings/osx_*.sh` — before changing macOS defaults.
- `settings/git.sh` and `settings/git/*.sh` — before altering Git global config.
- `settings/solarized/README.md` — before touching the Solarized theme assets.
- `/context/knowledge.md` — quick repo-specific notes.
- `/context/reference/index.md` — consult before integrating or debugging external vendors/APIs.

Capture external docs only when they are:
- repeatedly referenced,
- broadly insightful,
- or likely to prevent recurring mistakes.

## 8) Continuous improvement of instructions (silent edits allowed)
This file should evolve as friction is discovered.

Proactively update AGENTS.md when:
- repeated mistakes recur across sessions,
- missing command/path details cause slowdowns,
- new boundaries need to be enforced (security, do-not-touch paths, etc.).

Guidelines:
- Make changes small and specific.
- Avoid vague rules; prefer testable directives.
- Keep the file compact.

## 9) Workarounds and risk
If you are considering shipping a workaround instead of a root-cause fix:
- Pause and switch to interactive discussion.
- Propose the modified plan, justification, pros/cons, risks, and cleanup path.
- Do not degrade security posture for convenience.
