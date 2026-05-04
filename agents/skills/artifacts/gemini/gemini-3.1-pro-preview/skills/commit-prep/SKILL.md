---
name: commit-prep
description: Prepare a completed work unit for commit by inspecting the full dirty git state, updating durable docs/context/handoff, recording important decisions or learnings, running relevant verification, and drafting a commit message for all uncommitted changes unless the user explicitly narrows scope. Use when work is complete or paused, or when the user asks for commit prep, a commit message, handoff notes, journaling, context capture, or save context. Preserve the user's git index exactly unless explicitly asked otherwise.
---

# Commit Prep

At the end of a coherent work unit, prepare the repository for review/commit by refreshing useful durable context, recording verification, and drafting a commit message grounded in the live dirty tree. Commit prep reports state; it does not silence dirty state by manufacturing generated outputs, freshness stamps, or commit operations.

## Invariants

- Do not stage, unstage, commit, amend, reset, restore, rebase, discard, or rewrite git state unless the user explicitly asks.
- Treat the staging area as user-owned review state, not commit-prep scope.
- Consider the full dirty tree by default: staged, unstaged, and untracked changes.
- Draft for a narrower subset only when the user explicitly asks for that scope, then call out dirty files excluded from the message.
- Never store secrets, credentials, tokens, private keys, customer data, or raw sensitive logs in docs, context, scratch files, or commit messages.
- Prefer repo instructions over skill instructions when they are more specific.
- Keep context updates compact and retrieval-oriented.
- Treat generated/maintained artifacts and freshness stamps as producer-owned outputs. Do not create, patch, or stamp them during commit prep. If artifacts are missing or stale, report the proper generation command or blocker.

## Required Evidence

- `git status --short --branch --untracked-files=all`
- staged diff summary, including renamed/deleted files
- unstaged diff summary, including renamed/deleted files
- untracked file list and enough content inspection to classify untracked work
- relevant full diffs and untracked files when needed for accuracy
- repo instructions and context when present

## Durable Context Rules

- Stable repo truth belongs in the repo's docs when available.
- Reusable agent workflow learnings belong in `.context/knowledge/` when present.
- Live work state, next steps, blockers, and verification belong in `.context/handoff.md` when present.
- Durable decisions belong in `.context/decisions.md` when present.
- Task state changes belong in `.context/tasks.md` when present.
- Do not invent a parallel documentation system for commit prep alone.

## Verification

Run relevant checks when safe and useful. Prefer targeted checks first, then the repo's full gate when the work warrants it and the command is available. If verification cannot run, explain why and name the next best check. Do not run generation or stamp-recording commands as verification unless the user explicitly asks for that production step.

## Commit Message Format

Use the active repository's documented or clearly established commit-message convention when one is apparent. If no convention is apparent, use imperative mood: a concise title, blank line, then high-signal bullets. Example:

```text
Add shell startup verification

- Add startup smoke coverage for bash and zsh
- Keep generated fixture output out of the committed home tree
```

Describe the inspected diff, not future plans, guessed motivation, or unverified tests. Include docs/context bullets only when they are primary user-facing value or materially explain the change.

## Final Response Contract

Return:

- docs/context/handoff updates, or `none` with a reason
- verification result, or why verification did not run
- commit scope
- proposed commit message following the active repo's convention, or the imperative default above
- dirty files excluded from the message only when the user narrowed scope
- blockers or follow-ups that affect the commit decision