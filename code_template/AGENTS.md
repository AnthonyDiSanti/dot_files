# AGENTS.md — Project Contract for Coding Agents

This file is the entrypoint for agents working in this repository template.
Keep it concise, retrieval-oriented, and current. Do not include secrets.

## 0) Local overrides (AGENTS.local.md)
If `AGENTS.local.md` exists at the repo root:
- Read it at the start of work and treat it as **machine-specific overrides**.
- It is gitignored and must not be relied on for shared/team workflows.

What belongs in `AGENTS.local.md`:
- Local environment quirks (broken Node/npm, alternate commands, paths, ports, OS-specific steps)
- Anything that is true for *this machine* but not necessarily for others

What does NOT belong there:
- Global behavioral instructions (those live in your global setup)
- Repo truth (architecture, commands, workflows, navigation guidance)
- Large duplicated content from this file

Precedence:
- This file (`AGENTS.md`) is the source of truth for repo workflow expectations.
- `AGENTS.local.md` may override **commands and environment steps** only when necessary on this machine.
- If local overrides materially change how the project is run/tested, record a short note in `/context/handoff.md`.

Maintenance:
- Keep `AGENTS.local.md` short and delta-based.
- If a local override turns out to be broadly applicable, migrate it into `AGENTS.md`.

## 1) Start Here
Use this retrieval order unless the task clearly calls for something else:
1. Read `README.md` for the repo/template quick start.
2. Read `/docs/README.md` for the documentation map.
3. Open the most relevant topic file(s) under `/docs/`.
4. Read `/context/handoff.md`, `/context/tasks.md`, and `/context/decisions.md` for live state.
5. Only then dive into the code.

AGENTS is the routing layer, not the encyclopedia.
Stable repo truth belongs in `/docs/`.
Live working state belongs in `/context/`.

## 2) Canonical Docs (`/docs`)
`/docs/` is the canonical documentation system for this repo.
It is optimized for retrieval by agents, with humans as a secondary audience.

Rules:
- Put stable architecture, implementation, feature, integration, operational, and testing guidance in `/docs/`.
- Keep a landing page at `/docs/README.md` that routes readers to the right topic files.
- Let the repo decide the topic structure; do not assume a fixed taxonomy.
- Start with as few topic files as the repo needs and split them only when retrieval or maintenance suffers.
- Topic files should cross-link freely, and each file should still be fairly exhaustive for its scope.
- Favor explicit file paths, entrypoints, data flows, failure modes, and debugging guidance over high-level summaries.
- Roll external/vendor knowledge into the relevant `/docs/` topic when it materially affects stable repo behavior.

## 3) Live Working Memory (`/context`)
`/context/` is durable, agent-facing working memory.
It stores live state, coordination artifacts, and short-lived collaboration material.

### Context structure
- `/context/README.md` — what belongs in `/context` and what should be promoted into `/docs/`
- `/context/handoff.md` — current state + next steps (living snapshot)
- `/context/tasks.md` — active/paused/completed workstreams
- `/context/decisions.md` — decision log (newest first; include decision-maker)
- `/context/knowledge/` — agent-oriented supplemental knowledge that is useful but not appropriate as canonical repo docs
- `/context/scratch/` — git-tracked staging area for collaborative drafts, experiments, and other content that does not yet have a stable home in the repo

Rules:
- Do not let `/context/` become the primary documentation system.
- If a note becomes stable repo truth, move it into `/docs/` and leave only a short breadcrumb in `/context/`.
- Use `/context/knowledge/` for high-value agent notes that are reusable across sessions but do not belong in canonical repo docs.
- Namespace `/context/scratch/` by task ID or work thread and clean it up once the content is promoted or no longer needed.

## 4) Documentation Maintenance
Documentation is part of the product for agent workflows.

Rules:
- Documentation maintenance is mandatory, proactive, and part of every substantial turn. Do not wait for the user to ask.
- After every turn that materially changes code, behavior, architecture, integrations, debugging understanding, or workflow knowledge, update the relevant docs before finishing.
- When a change materially affects stable repo behavior, code navigation, setup, debugging, or integrations, update the relevant `/docs/` topic file in the same change.
- Update `/docs/README.md` whenever a new topic file is added, renamed, split, or removed.
- When the new knowledge is useful mainly to agents and not appropriate for canonical repo docs, update `/context/knowledge/` in the same turn.
- Prefer dense, explicit documentation that helps an agent find the right code quickly, even if it is more detailed than a human-oriented guide would be.
- Use `/context/` for live state, short breadcrumbs, and coordination; use `/docs/` for durable repo truth; use `/context/knowledge/` for agent-oriented supplemental knowledge.

## 5) Git commits (workflow)
When a coherent unit of work is complete, pause and recommend a git commit with a proposed message. The message format must be:
1. Title in present tense
2. Blank line
3. Bullet list of key changes

## 6) Continuous improvement of instructions (silent edits allowed)
This file should evolve as friction is discovered.

Proactively update AGENTS.md when:
- repeated mistakes recur across sessions,
- routing into the right docs/context files is unclear,
- documentation boundaries need to be tightened,
- or new workflow constraints need to be enforced.

Guidelines:
- Make changes small and specific.
- Avoid vague rules; prefer retrieval-oriented directives.
- Keep the file compact and focused on navigation + workflow.

## 7) Workarounds and risk
If you are considering shipping a workaround instead of a root-cause fix:
- Pause and switch to interactive discussion.
- Propose the modified plan, justification, pros/cons, risks, and cleanup path.
- Do not degrade security posture for convenience.
