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

## Working set
- `handoff.md` — current state + next steps
- `tasks.md` — active/paused/completed workstreams (ULID IDs + short human-readable titles)
- `decisions.md` — decision log with rationale
- `knowledge.md` — short, high-signal notes
- `reference/` — distilled third‑party notes (indexed in `reference/index.md`)

## Hygiene
- Keep entries short and high‑signal.
- Prefer updating existing notes over creating duplicates.
- Prune old items regularly.
- Keep `tasks.md` **Active** limited to in-progress/planned items; move completed items to **Completed** promptly.
