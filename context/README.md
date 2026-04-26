# /context

Agent-facing working memory for this repo. Committed to git for continuity.
`context/scratch/` is the shared staging area for collaborative drafts, experiments, and other material that does not yet have a stable home in the repo.

## Scope
- Dotfile changes and bootstrap behavior
- macOS defaults and system tweaks
- Shell/Vim/tmux configuration updates
- Vendored dependency updates (vim-plug submodule / Vim `plugged/`; Git prompt/completion comes from the active system Git install); Solarized editor colors via vim-solarized8, not `settings/solarized`
- Drafts, collaborative artifacts, experiments, and transient session files (under `/context/scratch`)

## Exclusions
- Secrets, API keys, credentials, private tokens

## Context Structure
- `handoff.md` — current state and next steps after recent changes.
- `tasks.md` — active/paused/completed workstreams (ULID IDs + short human-readable titles).
- `decisions.md` — durable decisions with dates and rationale, newest first.
- `knowledge/` — repo, vendor, and workflow notes plus deeper topic files (index at `knowledge/index.md`).
- `scratch/` — git-tracked staging area for collaborative drafts, experiments, pre-repo code, and transient artifacts that are worth retaining briefly (namespace by task ID or work thread; clean up after promotion).

## Update cadence
- Update `handoff.md` after each meaningful change.
- Keep `tasks.md` current for concurrent work and preserve ULID task IDs.
- Log durable decisions in `decisions.md`.
- If a note becomes stable repo guidance, promote it into the appropriate durable doc location and replace the `/context` content with a short summary plus link.
