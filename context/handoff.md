# Handoff

## Current State
- What works: chezmoi bootstrap (`bootstrap.sh`) links dotfiles from `home/`; shell startup sources `bash/*` and adds `bin/` to `PATH`; Vim plugins are vendored under `home/.vim/bundle` and configured via Vundle.
- What’s in progress: Current chezmoi migration is ready for Anthony's review/commit. Do not stage, unstage, or otherwise alter the index on Anthony's behalf.
- What’s broken / flaky: No known issues.

## Next Steps (ordered)
1. Commit the current chezmoi bootstrap migration once Anthony finishes reviewing staged/unstaged changes.
2. Split Codex approval rules into a curated managed global rules file and unmanaged Codex-generated `default.rules`.
3. Plan the separate Vim migration away from Vundle and revisit non-portable color configuration.
4. Plan the shell migration from bash infrastructure toward zsh, while generalizing the new `.zshrc` use case back to bash where appropriate.
5. Write a fuller repo documentation pass once the bootstrap, shell, and editor setup have a more permanent shape.

## Active Tasks
None (see `tasks.md`).

## Quick Verify
- Fast checks: `bash -n` on edited shell scripts; `chezmoi --source "$PWD" diff` or temporary-destination apply for dotfile target-state review.
- Full gate: `script/verify`; add manual smoke tests for touched interactive tools such as Vim when behavior changes.

## Recent Updates (keep last ~15; prune older)
- 2026-04-20 — Recorded future workstreams for Codex rule-file split, repo documentation, and bash-to-zsh migration.
- 2026-04-20 — Confirmed Codex scans `.rules` files under `~/.codex/rules/`; keep generated `default.rules` unmanaged and plan a curated managed `global.rules`.
- 2026-04-20 — Replaced Puppet bootstrap with chezmoi symlink-mode source state, ran bootstrap on the live home directory, and tracked the follow-up Vim migration.
- 2026-04-20 — Added `script/verify` as a lightweight full gate for shell syntax, chezmoi source mapping, temporary apply, live convergence, and shell startup.
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
