# /context

Durable, agent-facing working memory for this repo.
Stable documentation belongs in `/docs/`; `/context/` is for live state, coordination, supplemental agent knowledge, drafts, and scratch work.

## What goes here
- Handoffs between sessions/agents (living snapshot)
- Concurrent task tracking
- Key decisions + rationale
- Short breadcrumbs back to canonical docs when needed
- Supplemental agent-oriented knowledge in `knowledge/`
- Drafts, collaborative artifacts, and experiments in `scratch/`

## What does NOT go here
- Stable architecture, feature, integration, or operational docs
- A separate reference library
- Secrets, API keys, credentials, private tokens

## Working set
- `handoff.md` — current state + next steps
- `tasks.md` — active/paused/completed workstreams (ULID IDs + short human-readable titles)
- `decisions.md` — decision log with rationale, newest first
- `knowledge/` — supplemental agent knowledge that is useful across sessions but not appropriate for `/docs/`
- `scratch/` — git-tracked staging area for collaborative docs, pre-repo code, and experiments (namespace by task ID or work thread)

## Hygiene
- Keep entries short and high-signal.
- Prefer promoting durable repo truth into `/docs/` instead of expanding `/context/`.
- Prune old items regularly.
- Keep `tasks.md` **Active** limited to in-progress/planned items; move completed items to **Completed** promptly.
- If a `knowledge/` note becomes stable repo truth, move it into `/docs/` and leave a short breadcrumb behind.
- If a `scratch/` artifact becomes stable repo truth, move it into `/docs/`, the source tree, or another durable home and remove the scratch copy when appropriate.
