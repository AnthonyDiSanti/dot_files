# /context

Agent-facing working memory for this repo. Committed to git for continuity.
`context/user_shared/` is the collaborative exception for user+agent drafts and shared artifacts.

## Scope
- Dotfile changes and bootstrap behavior
- macOS defaults and system tweaks
- Shell/Vim/tmux configuration updates
- Vendored dependency updates (Solarized, Git prompt/completion, Vim bundles)
- Transient session artifacts and collaborative drafts (under `/context/scratch` and `/context/user_shared`)

## Exclusions
- Secrets, API keys, credentials, private tokens

## Context Structure
- `handoff.md` — current state and next steps after recent changes.
- `tasks.md` — active/paused/completed workstreams (ULID IDs + short human-readable titles).
- `decisions.md` — durable decisions with dates and rationale.
- `knowledge/` — repo-specific notes and gotchas (index at `knowledge/index.md`).
- `reference/index.md` — index of deeper reference notes (if needed).
- `user_shared/` — collaborative docs and draft artifacts between user and agent (can include pre-repo code).
- `scratch/` — session-scoped scratch space (namespace by task ID; clean up aggressively).

## Update cadence
- Update `handoff.md` after each meaningful change.
- Keep `tasks.md` current for concurrent work and preserve ULID task IDs.
- Log durable decisions in `decisions.md`.
- If a note becomes stable repo guidance, promote it into `docs/` and replace the `/context` content with a short summary plus link.
