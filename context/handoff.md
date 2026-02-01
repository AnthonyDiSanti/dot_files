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
- 2026-01-18 — Updated AGENTS/context docs with repo-specific details.
- 2026-01-20 — Switched `tasks.md` to ULID-based IDs and updated templates/README guidance.
- 2026-01-20 — Added `/context/user_shared` to support collaborative drafts and pre-repo code.
- 2026-01-20 — Added `/context/scratch` for transient session artifacts.
- 2026-01-20 — Migrated knowledge to `/context/knowledge/` with an index and topic files.
