# Handoff

## Current State
- What works: Puppet bootstrap (`bootstrap.sh`) links core dotfiles; shell startup sources `bash/*` and adds `bin/` to `PATH`; Vim plugins are vendored under `home/.vim/bundle` and configured via Vundle.
- What’s in progress: Nothing active.
- What’s broken / flaky: No known issues.

## Next Steps (ordered)
1. No queued work. Update this file when new changes land.

## Active Tasks
None (see `tasks.md`).

## Quick Verify
- Fast checks: `bash -n` on any edited shell script; `puppet parser validate site.pp` if Puppet is installed.
- Full gate: Manual smoke test of affected dotfiles (new shell session, run `vim` if Vim config changed, and re-run `bootstrap.sh` if links changed).

## Recent Updates (keep last ~15; prune older)
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
- 2026-01-20 — Added `/context/user_shared` to support collaborative drafts and pre-repo code.
- 2026-01-20 — Added `/context/scratch` for transient session artifacts.
- 2026-01-20 — Migrated knowledge to `/context/knowledge/` with an index and topic files.
- 2026-01-18 — Updated AGENTS/context docs with repo-specific details.
