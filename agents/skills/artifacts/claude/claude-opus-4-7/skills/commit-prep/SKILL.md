---
name: commit-prep
description: Prepare a completed work unit for commit by inspecting the full dirty git state, updating durable docs/context/handoff, recording important decisions or learnings, running relevant verification, and drafting a commit message for all uncommitted changes unless the user explicitly narrows scope. Use when work is complete or paused, or when the user asks for commit prep, a commit message, handoff notes, journaling, context capture, or save context. Preserve the user's git index exactly unless explicitly asked otherwise.
model: claude-opus-4-7
---

# Commit Prep

Prepare the repository for review and commit after a coherent work unit. Refresh
durable context, run verification, and draft a commit message grounded in the
live dirty tree. This skill reports state — it does not manufacture generated
outputs, freshness stamps, or commit operations.

## Invariants

Apply every invariant below to the entire commit-prep workflow, every file
inspected, every context update, and the final response.

- Do not stage, unstage, commit, amend, reset, restore, rebase, discard, or
  rewrite git state unless the user explicitly asks.
- Treat the staging area as user-owned review state. Do not infer staged-only
  scope from the index.
- Consider the full dirty tree by default: staged, unstaged, and untracked.
- Draft for a narrower subset only when the user explicitly requests that scope,
  then call out dirty files excluded from the message.
- Never store secrets, credentials, tokens, private keys, customer data, or raw
  sensitive logs in docs, context, scratch files, or commit messages.
- Prefer repo instructions (AGENTS.md, CLAUDE.md) over this skill when they are
  more specific.
- Keep context updates compact and retrieval-oriented.
- Treat generated/maintained artifacts and freshness stamps as producer-owned.
  Do not create, patch, or stamp them during commit prep. If artifacts are
  missing or stale, report the proper generation command or blocker.

## Evidence (required)

Gather all of the following before drafting the commit message:

- `git status --short --branch --untracked-files=all`
- Staged diff summary, including renamed/deleted files.
- Unstaged diff summary, including renamed/deleted files.
- Untracked file list with enough content inspection to classify untracked work.
- Relevant full diffs and untracked file contents when needed for accuracy.
- Repo instructions and `.context/` state when present.

Use tools for every evidence item. Do not answer from memory when the source of
truth is available locally.

## Durable Context

Update durable context only where useful. Use the repo's existing system:

- `.context/handoff.md` for live work state, next steps, blockers, verification.
- `.context/decisions.md` for durable decisions with rationale.
- `.context/tasks.md` for task state changes.
- `.context/knowledge/` for reusable agent workflow learnings.
- Stable repo truth belongs in the repo's docs (README, AGENTS.md).

Do not invent a parallel documentation system for commit prep.

## Verification

Run relevant checks when safe and useful. Prefer targeted checks first (e.g.
`bash -n`, shellcheck on changed scripts), then the repo's full gate
(`test/verify.sh`) when the work warrants it. If verification cannot run,
explain why and name the next best check. Do not run generation or
stamp-recording commands as verification.

## Commit Message Format

Use the repository's documented convention. For this repo: imperative mood title
with sentence-style capitalization, blank line, then high-signal bullets starting
with imperative verbs.

```text
Add shell startup verification

- Add startup smoke coverage for bash and zsh
- Keep generated fixture output out of the committed home tree
```

Describe the inspected diff, not future plans or guessed motivation. Include
docs/context bullets only when they are primary user-facing value or materially
explain the change.

## Final Response

Return all of the following:

- Docs/context/handoff updates made, or `none` with a reason.
- Verification result, or why verification did not run.
- Commit scope (full dirty tree or user-narrowed subset).
- Proposed commit message following the repo's convention.
- Dirty files excluded from the message (only when user narrowed scope).
- Blockers or follow-ups that affect the commit decision.
