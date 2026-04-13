# Repo Template Quick Start

This template is designed for agent-heavy workflows.
It keeps routing and live state lightweight while pushing durable, retrieval-oriented documentation into `/docs/`.

## What this template gives you
- `AGENTS.md` as the agent entrypoint and routing layer
- `/docs/` as the canonical documentation system
- `/context/` for live state, decisions, supplemental agent knowledge, and a git-tracked scratch/staging area

## Quick start
1. Read `AGENTS.md` and keep it concise.
2. Populate `/docs/README.md` with a real topic map for the repo.
3. Create only the `/docs/` topic files the repo actually needs.
4. Keep `/context/` limited to live state, supplemental agent knowledge, and scratch/staging artifacts.
5. Update docs alongside code whenever stable behavior or navigation changes.

## Documentation model
- `/docs/` is for stable repo truth.
- `/context/` is for live working memory and supplemental agent knowledge.
- Prefer topic files that are exhaustive within scope and easy for agents to retrieve.
- Keep the docs structure lightweight and repo-specific rather than forcing a fixed set of categories.
- Split or regroup topic files when retrieval starts to suffer, then update `/docs/README.md`.
- Keep stable repo-relevant external/vendor knowledge in `/docs/`, and keep agent-only workflows or learnings in `/context/knowledge/`.

## Suggested first customizations
- Rewrite `/docs/README.md` so it matches the real repo.
- Create the initial topic files and subfolders that fit the repo’s actual shape.
- Tighten `AGENTS.md` if the repo needs stronger workflow boundaries.
