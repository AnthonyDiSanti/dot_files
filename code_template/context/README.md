# /context

This directory is shared working memory for humans + AI agents.
It is committed to git for continuity across devices and developers.

## What goes here
- Handoffs between sessions/agents (living snapshot)
- Concurrent task tracking
- Key decisions + rationale (including agent-made decisions)
- Curated doc insights that prevent repeated escalations
- A curated reference library of third-party docs (distilled notes, not raw dumps)

## What does NOT go here
- Secrets, API keys, credentials, private tokens

## Logging philosophy
- `handoff.md` is a living snapshot (current truth).
- `tasks.md` tracks concurrent workstreams.
- Git history is the long-term log; keep these files clean and pruned.

## Reference Library
- `reference/index.md` is the table of contents.
- `reference/` contains distilled notes and examples for external systems we integrate with.
