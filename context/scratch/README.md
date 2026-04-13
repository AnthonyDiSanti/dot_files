# /context/scratch

Git-tracked staging area for drafts, collaborative work with the user, experiments, and other artifacts that do not yet have a stable home in the repo.
Use this for exploratory notes, pre-repo code, prototypes, working drafts, or temporary debugging artifacts that are worth retaining in git for a while.

## Naming
- Create a subfolder per task or work thread, e.g. `/<task-ulid>/`.
- If no task exists, use a timestamp prefix like `YYYYMMDD-HHMM-<short-label>/`.

## Promotion and cleanup
- Move stable repo documentation into the repo's durable documentation location.
- Move stable repo code or assets into their proper home in the source tree.
- Move agent-only reusable learnings into `/context/knowledge/`.
- Delete scratch folders once the contents have been promoted or are no longer needed.

## Boundaries
- Do not store secrets or credentials.
- Use `/tmp` for truly disposable files.
