# /context/scratch

Session-scoped scratch space for transient artifacts the agent may want to keep briefly while debugging or exploring.
Use this for temporary notes, logs, or small files that are not ready for `/context/knowledge.md` and should not live in source code.

## Naming
- Create a subfolder per task or work thread, e.g. `/<task-ulid>/`.
- If no task exists, use a timestamp prefix like `YYYYMMDD-HHMM-<short-label>/`.

## Cleanup
- Delete scratch folders once the task is complete or the artifact is no longer needed.
- Keep contents small and temporary; move durable learnings to `/context/knowledge.md`.

## Boundaries
- Do not store secrets or credentials.
- Use `/tmp` for truly disposable files.
