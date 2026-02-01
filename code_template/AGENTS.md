# AGENTS.md — Project Contract for Coding Agents

This file teaches coding agents how to work in this repository.
Keep it concise, actionable, and current. Do not include secrets.

## 0) Local overrides (AGENTS.local.md)
If `AGENTS.local.md` exists at the repo root:
- Read it at the start of work and treat it as **machine-specific overrides**.
- It is gitignored and must not be relied on for shared/team workflows.

What belongs in `AGENTS.local.md`:
- Local environment quirks (broken Node/npm, alternate commands, paths, ports, OS-specific steps)
- Anything that is true for *this machine* but not necessarily for others

What does NOT belong there:
- Global behavioral instructions (those live in your global setup)
- Repo truth (tech stack, architecture, standard commands that should apply to everyone)
- Large duplicated content from this file

Precedence:
- This file (`AGENTS.md`) is the source of truth for repo details.
- `AGENTS.local.md` may override **commands and environment steps** only when necessary on this machine.
- If local overrides materially change how the project is run/tested, record a short note in `/context/handoff.md`.

Maintenance:
- Keep `AGENTS.local.md` short and delta-based.
- If a local override turns out to be broadly applicable, migrate it into `AGENTS.md`.

## 1) Project overview (FILL IN)
- What this project is:
- Key user-facing behavior:
- Non-goals / out of scope:
- Definition of done:

## 2) Tech stack & constraints (FILL IN)
- Languages + versions:
- Frameworks:
- Package manager:
- Storage/database:
- Deployment target:
- Constraints (perf/security/compliance/no-new-deps/etc.):

## 3) Repo map (FILL IN)
- Key directories:
  - `...`:
- Where to add new:
  - endpoints:
  - UI components:
  - services/modules:
- “Do not touch” paths (if any):

## 4) Commands (PUT THIS EARLY; FILL IN)
Setup:
- Install deps: `...`
- Env setup: `...`

Run:
- Dev server: `...`

Verify (targeted first, full at end):
- Fast checks (lint/typecheck/unit): `...`
- Run a single test: `...`
- Full suite (final gate): `...`
- Build (final gate if applicable): `...`

## 5) Engineering standards (FILL IN)
- Formatting:
- Lint rules:
- Types:
- Error handling/logging:
- Testing expectations:
- Dependency policy (optional; default: allowed):
- Refactor stance (optional; default: liberal refactors welcome):

## 6) /context — shared working memory (COMMITTED)
This repo uses `/context` as durable working memory for humans and agents.
It is committed to git to support continuity across devices and developers.

### Goals
- Prevent repeated escalations by recording knowledge once.
- Enable multi-session continuity and agent handoffs.
- Keep key decisions and references discoverable.

### Context structure
Keep this index updated as the project evolves.
- `/context/README.md` — what /context is and how to use it
- `/context/handoff.md` — current state + next steps (living snapshot)
- `/context/tasks.md` — active workstreams & status (supports concurrency)
- `/context/decisions.md` — decision log (include decision-maker)
- `/context/knowledge.md` — curated insights + “when to consult”
- `/context/user_shared/` — shared docs and drafts for user + agent collaboration (including pre-repo code or experiments)
- `/context/scratch/` — transient, session-scoped artifacts; namespace by task ID and clean up aggressively

### Reference Library (third-party docs, curated)
Maintain a deeper reference library at:

- `/context/reference/index.md` — catalog of reference items + “when to consult”
- `/context/reference/` — curated, digestible third-party reference notes

Use `/context/reference` when:
- you keep returning to the same third-party docs,
- a vendor/API/system has complex edge cases worth preserving,
- or a subtle constraint is likely to cause repeated failures.

Rules for reference items:
- Prefer distilled notes + examples over raw dumps.
- Include: Source, Retrieved date, Why it matters, When to consult, Key gotchas, Minimal examples.
- Avoid storing large verbatim copies of third-party docs unless licensing explicitly permits it.
- Keep it small and useful: update/merge entries instead of creating endless files.

Linking rule:
- Every reference item must be linked from `/context/reference/index.md`.
- `knowledge.md` should point to the deeper reference item when appropriate.

### /context hygiene rules
- Store summaries and insights, not giant dumps.
- Prefer updating existing notes over creating many redundant files.
- Never store secrets.

## 7) Documentation references (FILL IN + MAINTAIN)
List the project’s key references and *when* to consult them:
- `...` — consult before ...
- `/context/knowledge.md` — consult when ...
- `/context/reference/index.md` — consult when integrating or debugging external vendors/APIs

Capture external docs only when they are:
- repeatedly referenced,
- broadly insightful,
- or likely to prevent recurring mistakes.

## 8) Continuous improvement of instructions (silent edits allowed)
This file should evolve as friction is discovered.

Proactively update AGENTS.md when:
- repeated mistakes recur across sessions,
- missing command/path details cause slowdowns,
- new boundaries need to be enforced (security, do-not-touch paths, etc.).

Guidelines:
- Make changes small and specific.
- Avoid vague rules; prefer testable directives.
- Keep the file compact.

## 9) Workarounds and risk
If you are considering shipping a workaround instead of a root-cause fix:
- Pause and switch to interactive discussion.
- Propose the modified plan, justification, pros/cons, risks, and cleanup path.
- Do not degrade security posture for convenience.
