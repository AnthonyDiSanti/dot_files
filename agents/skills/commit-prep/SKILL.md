---
name: commit-prep
description: Prepare a completed work unit for commit by updating durable docs, agent context, handoff state, and a final commit message. Use proactively when finalizing implementation work, pausing for handoff, journaling context, or handling requests such as "commit prep", "prep commit", "before committing", "draft commit message", or "save context". Do not stage, unstage, reset, restore, discard, amend, rebase, rewrite history, or commit unless explicitly asked.
---

# Commit Prep

Use this skill near the end of a coherent work unit, before a commit, or whenever the
current session should leave durable context for a future agent. It may be invoked
explicitly by the user or implicitly when the work is complete enough that docs,
context, handoff, or a commit message would be useful.

The goal is to leave the repository easier to resume and to draft a commit message
based on the actual working tree, not on memory alone.

## Core rules

- Do not run `git add`, `git commit`, `git amend`, `git rebase`, `git reset`, or
  other git-state-changing commands unless the user explicitly asks.
- Do inspect git state and diffs before writing context or drafting the commit
  message.
- Prefer existing repository instructions over this skill when they are more
  specific. Honor global and repo `AGENTS.md` commit-message guidance.
- Keep updates high-signal and retrieval-oriented. Do not journal every step.
- Never store secrets, credentials, tokens, private keys, customer data, or raw
  sensitive logs in docs, context, handoff, scratch, or commit messages.
- Do not let `.context` become the canonical documentation system. Stable repo
  truth belongs in `/docs` when that directory exists.

## Constraints / Safety

The git index (staging area) must be treated as user-owned state and preserved exactly.

- Do NOT stage files (`git add`) unless explicitly asked
- Do NOT unstage files (`git restore --staged`, `git reset`, etc.)
- Do NOT modify the index in any way
- Do NOT discard changes (`git checkout`, `git restore`, etc.)
- Do NOT amend, rebase, or rewrite history

The current staging state is intentional and must be preserved exactly.

You may:

- Read `git status`
- Read `git diff`
- Read `git diff --staged`

You must:

- Clearly indicate whether the commit message reflects:
  - staged changes only, or
  - all working directory changes

If the staging state appears inconsistent or surprising, surface it to the user instead of modifying it.

## Initial inspection

Before writing files or drafting the message, inspect enough live state to ground
the output:

1. Run `git status --short --branch`.
2. Inspect staged changes:
   - `git diff --staged --stat`
   - `git diff --staged` when needed for accuracy.
3. Inspect unstaged changes:
   - `git diff --stat`
   - `git diff` when needed for accuracy.
4. Inspect untracked files from `git status`; open only those likely relevant to
   the commit or documentation update.
5. Read repo guidance when present:
   - `AGENTS.md`
   - `AGENTS.local.md` for local-only command/environment caveats
   - `README.md`
   - `docs/README.md`
   - `.context/README.md`
   - `.context/handoff.md`
   - `.context/tasks.md`
   - `.context/decisions.md`
   - `.context/knowledge/index.md`

If the diff is too large, sample strategically by file type and change area, then
state the limitation in the final response.

## Decide what to preserve

Classify each useful piece of context before writing it down.

### Stable repo-level truth

Examples: architecture, behavior, setup, testing, integrations, operations,
debugging guidance, feature behavior, important code paths, data flows, failure
modes, or vendor details that materially affect this repo.

Destination:

1. Write to `/docs` when `/docs` exists.
2. If `/docs` does not exist, fall back to `.context/knowledge/` when that exists.
3. If neither exists, do not create a new documentation system just for this
   skill. Mention the missing destination in the final response.

When adding or renaming docs under `/docs`, update `/docs/README.md` so future
agents can find the topic.

### Agent-specific reusable learnings

Examples: agent workflow tips, sandbox/tooling quirks, environment notes,
retrieval hints, recurring pitfalls, or compact heuristics that help future agents
but are not canonical repo truth.

Destination:

1. Write to `.context/knowledge/` when it exists.
2. Update `.context/knowledge/index.md` when adding a new topic file.
3. If `.context/knowledge/` does not exist, include the learning in handoff only
   if it is needed to resume the current work. Otherwise report it as a suggested
   note rather than creating a new location.

### Live work state

Examples: current status, what works, what is in progress, broken/flaky areas,
next steps, verification commands, active tasks, blockers, and recent updates.

Destination:

- Update `.context/handoff.md` when it exists.
- Treat handoff as a living snapshot, not a dumping ground.
- Make it possible for a new agent to resume without rereading the whole
  conversation.

### Decisions

Write to `.context/decisions.md` only when a durable decision was actually made
or discovered. Preserve its format when present. Include decision maker, decision,
rationale, alternatives, consequences/follow-ups, and revisit trigger when useful.

### Tasks

Update `.context/tasks.md` when task state changed. Keep active items current,
move completed work to completed when appropriate, and preserve the repo's task
ID/status style.

## Handoff update requirements

Give `.context/handoff.md` special attention. When the file exists, update it even
if no other context file needs changes, unless the current turn clearly did not
change the work state.

A good handoff update should include:

- `Current State`: what works, what is in progress, and what is broken/flaky.
- `Next Steps`: ordered, concrete actions; avoid vague advice.
- `Active Tasks`: either a short pointer to `tasks.md` or a compact current list.
- `Quick Verify`: fast checks and full gate commands, with known caveats.
- `Recent Updates`: add a timestamped one-line summary and keep only the most
  recent entries when the file asks for pruning.

Use the repository's existing handoff structure. Prefer targeted edits over a full
rewrite unless the file is empty or clearly stale.

## Documentation hygiene

When writing docs or context:

- Prefer concise, explicit, path-rich notes over broad summaries.
- Link from context to canonical docs instead of duplicating stable docs.
- Promote stable truth from `.context` into `/docs` when appropriate.
- Leave breadcrumbs in `.context/knowledge/` when a note was promoted to `/docs`.
- Preserve existing formatting conventions, heading order, and newest-first rules.
- Avoid creating many tiny files. Add a topic file only when it improves retrieval.
- Remove or flag stale context that conflicts with live repo evidence.

## Verification

Before the final response:

1. Record checks already run during the work.
2. Run lightweight verification only when safe, relevant, and consistent with repo
   instructions and available time.
3. Do not run destructive, production-affecting, or unusually long commands
   unless the user or repo instructions explicitly allow them.
4. If verification was not run, say so and give the reason.

## Commit message drafting

Draft the commit message after docs/context/handoff updates, so the message can
include those updates when they are part of the work.

1. Re-run `git status --short` after any context/doc edits.
2. Determine the commit scope:
   - If staged changes exist, draft for the staged changes and separately mention
     unstaged/untracked changes that are not covered.
   - If nothing is staged, draft for the full working tree and say that it is for
     unstaged changes.
3. Base the message on actual diffs and repository instructions, not memory alone.
4. Honor global and repo commit-message guidance. If no guidance is available,
   use this fallback format:

   ```text
   Present-tense title

   - Key change
   - Key change
   - Verification or docs/context note when relevant
   ```

5. Keep the title specific and concise. Avoid vague titles such as "Update files"
   or "Fix stuff".
6. Include documentation/context updates in the bullets when they are meaningful.
7. Do not include secrets, internal-only sensitive details, or excessive file lists.

## Final response

Return a compact summary with:

- Files updated for docs/context/handoff, or "none" with a reason.
- Verification run, or why it was not run.
- Commit scope: staged-only or full working tree.
- Proposed commit message in a copyable fenced block.
- Unstaged/untracked files not covered by the proposed commit, if any.
- Any blockers, risks, or follow-ups that should affect the commit decision.

Do not claim the commit was created unless it was explicitly requested and actually
completed.
