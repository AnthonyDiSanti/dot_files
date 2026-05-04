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
- If local overrides materially change how the project is run/tested, record a short note in `/.context/handoff.md`.

Maintenance:
- Keep `AGENTS.local.md` short and delta-based.
- If a local override turns out to be broadly applicable, migrate it into `AGENTS.md`.

## 1) Project overview
- What this project is: Personal dotfiles and setup scripts for shell, Vim, tmux, Git, and agent configs, primarily on macOS.
- Key user-facing behavior: `./bootstrap.sh` interprets the checked-out `home/` tree as a literal `$HOME` mirror and symlinks managed targets into place without requiring Git at runtime; shell startup reads shared config from `~/.config/shell/` and shell-specific config from `~/.config/bash/` or `~/.config/zsh/`; `settings/*.sh` apply macOS defaults and Git config.
- Non-goals / out of scope: Not a general-purpose app/library; not cross-platform; no CI/test harness; avoid ad-hoc edits inside vendored directories.
- Definition of done: Dotfiles updated in the literal `home/` target-tree form, bootstrap/scripts run without errors on macOS, and `/.context` is kept current.

## 2) Tech stack & constraints
- Languages + versions: Shell (bash/sh, system), Vimscript (`home/.vimrc`), TOML (`home/.codex/config.toml`), plist/dict (`settings/OSXKeyBindings.dict`).
- Frameworks: None.
- Package manager: None in-repo (system installs via Homebrew/RubyGems are assumed externally).
- Storage/database: None.
- Deployment target: Local macOS workstation; **WSL** is supported (e.g. block-cursor tweak in `home/.config/bash/rc.bash` only after `[[ -r /proc/version ]]`). Vim configuration targets **vanilla Vim** (8+) so dotfiles stay usable over SSH on typical servers; Neovim is optional future work—see `/.context/decisions.md`.
- Constraints (perf/security/compliance/no-new-deps/etc.): Prefer macOS-compatible commands such as `defaults`; avoid touching vendored directories; keep scripts compatible with their shebang (`bash` vs `sh`); no secrets in repo. **Live-update principle:** `git pull` on the repo should update deployed config without re-running bootstrap except when the deployment shape changes. Prefer symlinks into the repo for long-lived config, while leaving generated tool-managed directories such as `~/.vim/plugged/` local and unmanaged.

## 3) Repo map
- Key directories:
  - `home/` — literal `$HOME` target tree for managed dotfiles (shell, tmux, Vim, Codex/Claude config).
  - `home/.config/shell/` — POSIX-compatible shared shell baseline for `sh`, `bash`, and `zsh`.
  - `home/.config/bash/` — bash-specific interactive setup (prompt, system Git helper loading, WSL cursor tweak).
  - `home/.config/zsh/` — zsh-specific interactive setup.
  - `home/.local/bin/` — optional user CLI utilities installed to `~/.local/bin/` when present.
  - `agents/skills/` — shared agent skill source and runtime artifacts; source skills are directories containing `SKILL.md` anywhere under `agents/skills/src/`, with optional delta-only `model-notes/`, `harness-notes/`, and `evals/`, and runtime artifacts are exposed to harnesses through symlink nodes in `home/`.
  - `agents/prompts/` — canonical updater prompt source, optional delta-only prompt harness notes, harness-specific prompt artifacts, and prompt artifact digest stamps.
  - `agents/harnesses/` — harness YAML configs and adapter docs for maintaining runtime artifacts.
  - `agents/scripts/update-skill.bash` — fixed-point updater for one source skill across selected harness/model artifacts; `--harness` alone or `--model` alone filters existing artifacts, while `--harness` plus `--model` creates that explicit target if missing; `--force` re-runs selected targets on the first pass.
  - `agents/scripts/update-prompt.bash` — fixed-point updater for one source prompt across selected harness prompt artifacts; `--harness` creates that explicit target if missing.
  - `agents/scripts/update-all.bash` — fixed-point updater for maintained skill or prompt artifacts; `--type skill|prompt` selects the surface, `--prompt` is shorthand for prompt mode, and `--force` re-runs the selected matrix on the first pass.
  - `agents/scripts/symlink-skill.bash` — deploys one runtime skill artifact into selected harness skill directories under a home tree, discovering configured harness/model targets from harness user config files unless `--harness --model` is explicit.
  - `agents/scripts/symlink-all.bash` — deploys every selected runtime skill artifact into selected harness skill directories with the same target discovery and filtering semantics as `symlink-skill.bash`; accepts an optional `skills/src/`-relative prefix to deploy a whole source subtree such as a team-owned skill folder.
  - `agents/official-docs/` — authoritative cached vendor docs and optional reference submodules for source/example trees such as Codex, Anthropic skills, Cursor plugins, and Gemini CLI; do not hand-edit copied vendor documents or files inside vendor submodules.
  - `agents/models/` — model guidance derived from official docs.
  - `home/.claude/` — managed Claude Code user-scope memory, settings, and skill deployment symlink nodes; Claude Code is intentionally pinned to Opus 4.6 for now.
  - `home/.gemini/` — managed Gemini CLI user settings and skill deployment symlink nodes; do not manage Gemini credentials, account files, installation ids, trusted-folder state, history, tmp logs, or other local state.
  - `home/.cursor/skills/` — managed Cursor Agent skill deployment symlink nodes; do not symlink the full stateful Cursor CLI config. This repo exports `CURSOR_CONFIG_DIR=$XDG_CONFIG_HOME/cursor`, so the live macOS config path is `~/.config/cursor/cli-config.json`; stable preferences are applied through `settings/cursor-agent-cli.sh`.
  - `test/` — repo-local verification entrypoint (`test/verify.sh`) and test fixtures (`test/fixtures/`).
  - `scripts/` — bootstrap-support helpers and small tools (e.g. `home_tree_manifest.sh`, `shell_files.bash`, `print-ansi-colors.sh`); not added to `PATH`.
  - `settings/` — macOS defaults scripts, Git config scripts, keybindings; see `settings/README.md` (Solarized is not vendored; Vim uses vim-solarized8 via vim-plug).
  - `.context/` — shared working memory for humans and agents.
  - `code_template/` — template skeleton for new repos (`AGENTS.md`, `/.context`, etc.).
- Where to add new:
  - Shared shell setup for `sh`/`bash`/`zsh`: `home/.config/shell/`.
  - Bash-only shell setup: `home/.config/bash/`.
  - Zsh-only shell setup: `home/.config/zsh/`.
  - CLI utilities: `home/.local/bin/`.
  - Shared agent skill source: any directory under `agents/skills/src/` that contains `SKILL.md`; the skill directory name is the runtime skill id and must be unique across the source tree.
  - Skill runtime artifacts: `agents/skills/artifacts/<harness>/<model>/skills/<skill>/`, then add a real symlink node at the harness path under `home/`.
  - Optional skill-specific model tuning notes: `agents/skills/src/**/<skill>/model-notes/<model>.md`; add only when that skill/model pair has a real delta.
  - Optional skill-specific harness tuning notes: `agents/skills/src/**/<skill>/harness-notes/<harness>.md`; add only when that skill/harness pair has a real delta.
  - Skill eval fixtures: `agents/skills/src/**/<skill>/evals/`.
  - Skill artifact input stamps: `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/inputs.sha256`.
  - Prompt source: any directory under `agents/prompts/src/` that contains
    `PROMPT.md`; the prompt directory name is the prompt id and must be unique
    across the source tree.
  - Prompt artifacts: `agents/prompts/harnesses/<harness>/<prompt>.md`.
  - Optional prompt harness notes: `agents/prompts/src/**/<prompt>/harness-notes/<harness>.md`; add only for real prompt/harness deltas.
  - Prompt artifact input stamps: `agents/prompts/.update-stamps/<harness>/<prompt>/inputs.sha256`.
  - Harness configs and adapter docs: `agents/harnesses/`;
    name `<harness>.yaml` and `<harness>.md` after the executable, e.g.
    `claude.yaml` / `claude.md` for Claude Code's `claude` command and
    `cursor-agent.yaml` / `cursor-agent.md` for Cursor Agent. Harness YAML also
    records `home_config`, `skills_dir`, and `model_config_key` so symlink
    scripts can deploy artifacts without implicit defaults; use optional
    `model_aliases` there for documented harness-native aliases such as Claude
    Code's `best`. `model_config_key` may be a dotted key for nested JSON config
    such as Gemini's `model.name`.
  - Official vendor prompt/migration docs: `agents/official-docs/<provider-model-topic>.md`; larger reference sets may live as optional pinned submodules, such as `agents/official-docs/codex`, `agents/official-docs/anthropic-skills`, `agents/official-docs/cursor-plugins`, and `agents/official-docs/gemini-cli`.
  - Derived agent model guidance: `agents/models/<model>.md`.
  - Dotfiles: `home/` using literal target names and real symlink nodes where appropriate.
  - macOS defaults: `settings/osx_*.sh` (wire into `settings/osx_all.sh` if needed).
  - Cursor Agent CLI preferences: `settings/cursor-agent-cli.json` plus `settings/cursor-agent-cli.sh`; preserve live auth/cache/local state by merging, not symlinking, the whole config file.
  - Git config: `settings/git/*.sh` (invoked by `settings/git.sh`).
  - Vim plugins: [vim-plug](https://github.com/junegunn/vim-plug); loader snapshot tracked at `home/.vim/autoload/plug.vim`; `:PlugInstall` populates local `~/.vim/plugged/`. Keep `home/.vimrc` free of stale references when plugins are removed.
- “Do not touch” paths (if any):
  - Local plugin installs under `~/.vim/plugged/` follow normal `:PlugInstall` / `:PlugUpdate` workflows and are not committed.
  - Skill runtime artifact contents under `agents/skills/artifacts/` must not
    be hand-edited or directly generated. Use `agents/scripts/update-skill.bash`
    or `agents/scripts/update-all.bash`; if the native harness cannot run here,
    leave the artifact missing/stale and give Anthony the exact command to run.
  - Prompt artifact contents under `agents/prompts/harnesses/` should be updated
    through `agents/scripts/update-prompt.bash` or
    `agents/scripts/update-all.bash --type prompt`; keep harness-specific runner
    prose in prompt artifacts or prompt harness notes, not in harness YAML
    `runner_args`. If the native harness cannot run here, leave the artifact
    missing/stale and give Anthony the exact command to run.
  - Vendor submodule contents under `agents/official-docs/`, currently
    `agents/official-docs/codex`, `agents/official-docs/anthropic-skills`,
    `agents/official-docs/cursor-plugins`, and
    `agents/official-docs/gemini-cli`, must not be edited in place. Update the
    pinned submodule commit or tag instead.

## 4) Commands
Setup:
- Install deps: `zsh`, `shellcheck`, `shfmt`, and `git` (required for `test/verify.sh` and Vim `:PlugInstall`, but not for `bootstrap.sh` itself), Vim 8+ with Python 3 linked if using vim-mundo (`:version` should show `+python3`).
- Hydrate optional reference docs when needed:
  `git submodule update --init --depth 1 agents/official-docs/codex agents/official-docs/anthropic-skills agents/official-docs/cursor-plugins agents/official-docs/gemini-cli`.
- Env setup: `./bootstrap.sh` (POSIX `sh`; applies the repo-native symlink-backed home tree).

Run:
- Apply macOS defaults: `settings/osx_all.sh` (or `settings/osx_general.sh` and `settings/safari.sh` individually).
- Apply Git config: `settings/git.sh`.

Verify (targeted first, full at end):
- Fast checks (lint/typecheck/unit): `bash -n path/to/script.sh`, `scripts/shellcheck-dotfiles.bash path/to/script.sh`, and `scripts/shfmt-dotfiles.bash --check path/to/script.sh` for modified shell scripts; `./bootstrap.sh --dry-run --verbose` for dotfile target-state review.
- Run a single test: Manual smoke check of the changed script or config (e.g., open a new shell and ensure `.bash_profile` loads cleanly).
- Full suite (final gate): `test/verify.sh`.
- Build (final gate if applicable): Not applicable.

## 5) Engineering standards
- Formatting: Match existing style; 2-space indentation in shell scripts, keep shebangs consistent (`/usr/bin/env bash` vs `sh`).
- Lint/format rules: `test/verify.sh` requires ShellCheck through `scripts/shellcheck-dotfiles.bash --all` and shfmt through `scripts/shfmt-dotfiles.bash --all --check`; VS Code ShellCheck uses the same wrapper for shell dialect mapping and repo-aware file handling. Put intentional ShellCheck suppressions in the owning source file, not in the wrapper, unless the suppression is truly repo-global. `scripts/shell_files.bash` owns Bash-only dev-tool shell file discovery/dialect classification and excludes `.gitmodules` paths from broad repo scans; do not use it from POSIX deployment paths.
- Types: Not applicable.
- Error handling/logging: Prefer explicit error checks and clear `echo` output; keep shared helpers in `home/.config/shell/functions.sh`.
- Shell data flow: Prefer explicit call-site data flow over string-encoded function names. When a helper consumes generated lines, make it read stdin and feed it with redirection/process substitution at the call site when shell semantics allow; document exceptions.
- Testing expectations: Run `test/verify.sh` for bootstrap/dotfile changes; it checks shell syntax/static analysis/formatting, repo-native managed target mapping, temporary-home apply behavior, live-home convergence, and shell startup.
- Dependency policy: Allowed, but keep vendored deps isolated and update them as cohesive version bumps.
- Refactor stance: Prefer clarity and consistency, but avoid rewriting vendored directories.
- Generated artifact policy: Do not manually patch runtime skill artifacts or
  prompt artifacts to reflect source or instruction changes. Artifact content
  changes must flow through the updater scripts so native-harness selection,
  prompts, validation, and digest stamps stay trustworthy. Do not manually
  bootstrap missing artifacts, and do not run `record-stamp` or otherwise update
  digest stamps unless the user explicitly asks to mark artifacts current
  without a native harness run.
- Agent-note policy: Put shared artifact-production guidance in source prompts
  or source skills. Keep model notes and harness notes optional and limited to
  target-specific deltas that should affect the prompt or artifact digest.

## 6) Git commits (workflow)
When a coherent unit of work is complete, pause and recommend a git commit with a proposed message. The message format must be:
1) Title in imperative mood and sentence-style capitalization, e.g. `Add shell startup verification`
2) Blank line
3) Bullet list of key changes, with each bullet starting capitalized and using imperative mood, e.g. `- Add ...`

Avoid third-person present (`Adds`), gerunds (`Adding`), past tense (`Added`), lowercase-leading bullets, and title-casing every word.

## 7) /.context — shared working memory (COMMITTED)
This repo uses `/.context` as durable, agent-facing working memory.
It is committed to git to support continuity across devices and developers.

### Goals
- Prevent repeated escalations by recording knowledge once.
- Enable multi-session continuity and agent handoffs.
- Keep key decisions and knowledge discoverable.

### .context Structure
- `/.context/README.md` — purpose, scope, and how the `.context` files are used in this repo.
- `/.context/handoff.md` — current state and next steps (living snapshot).
- `/.context/tasks.md` — active/paused/completed workstreams.
- `/.context/decisions.md` — decision log with dates and rationale, newest first. Use `Decider: Anthony` for human decisions and `Decider: Codex (model: gpt-5.2-codex)` for agent decisions.
- `/.context/knowledge/` — curated repo, vendor, and workflow insights with “when to consult” guidance (index at `knowledge/index.md`).
- `/.context/scratch/` — git-tracked staging area for collaborative drafts, experiments, pre-repo code, and other content that does not yet have a stable home in the repo; namespace by task ID or work thread and clean it up after promotion.

### /.context hygiene rules
- Store summaries and insights, not giant dumps.
- Prefer updating existing notes over creating many redundant files.
- Never store secrets.
- Keep `/.context` concise and retrieval-oriented: live state belongs in `handoff.md`, `tasks.md`, and `decisions.md`, while reusable knowledge belongs in `knowledge/`.
- Treat `/.context` as a helpful snapshot, not infallible ground truth: when it conflicts with live repo evidence (`git status`, current files, recent commits, or the working tree), prefer the live state and reconcile `/.context` before answering status or “what’s next?” questions.

## 8) Documentation references (maintain)
List the project’s key references and when to consult them:
- `README.md` — Vim plugin install/update steps.
- `bootstrap.sh` and `scripts/home_tree_manifest.sh` — before changing bootstrap or symlink behavior.
- `home/.profile`, `home/.shrc`, `home/.bash_profile`, `home/.bashrc`, `home/.zprofile`, `home/.zshrc`, and `home/.config/{shell,bash,zsh}/` — before changing shell startup, PATH, prompt, or shared functions.
- `settings/osx_*.sh` — before changing macOS defaults.
- `settings/git.sh` and `settings/git/*.sh` — before altering Git global config.
- `settings/README.md` — scope of `settings/`; Solarized reference links (upstream not vendored).
- `/.context/knowledge/index.md` — quick repo, vendor, and workflow notes plus links to deeper topics.

Capture external docs only when they are:
- repeatedly referenced,
- broadly insightful,
- or likely to prevent recurring mistakes.

Documentation maintenance rule:
- When a change materially affects stable repo behavior, navigation, debugging, or an external system the repo depends on, update the nearest durable doc in the same change. In this repo that usually means `README.md`, a README in the touched subtree, or a topic under `/.context/knowledge/` when the note is primarily agent-facing.
- Preserve the boundary: `/.context/handoff.md`, `/.context/tasks.md`, and `/.context/decisions.md` are live state, while `/.context/knowledge/` holds reusable knowledge.

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
