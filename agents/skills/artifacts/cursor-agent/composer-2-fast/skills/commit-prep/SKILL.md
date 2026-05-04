---
name: commit-prep
description: Prepare a completed work unit for commit by inspecting the full dirty git state, updating durable docs/context/handoff, recording important decisions or learnings, running relevant verification, and drafting a commit message for all uncommitted changes unless the user explicitly narrows scope. Use when work is complete or paused, or when the user asks for commit prep, a commit message, handoff notes, journaling, context capture, or save context. Preserve the user's git index exactly unless explicitly asked otherwise.
---

# Commit Prep

Prepare the current work for review or commit. Success means useful durable
context is current, verification status is recorded accurately, and the proposed
commit message is grounded in the live dirty tree. Keep context updates compact
and retrieval-oriented.

## Invariants

- Do not stage, unstage, commit, amend, reset, restore, rebase, discard, or
  rewrite git state unless the user explicitly asks.
- Treat the staging area as user-owned review state, not commit-prep scope.
- Consider the full dirty tree by default: staged, unstaged, and untracked
  changes.
- Draft for a narrower subset only when the user explicitly asks for that scope,
  then call out dirty files excluded from the message.
- Never store secrets, credentials, tokens, private keys, customer data, or raw
  sensitive logs in docs, context, scratch files, or commit messages.
- Prefer repo instructions over this skill when they are more specific.
- Treat generated artifacts and freshness stamps as producer-owned outputs. Do
  not create, patch, or stamp them during commit prep; report the proper
  generation command or blocker instead.

## Evidence

Inspect enough live state to make the commit message and context updates
accurate:

- `git status --short --branch --untracked-files=all`
- staged diff summary, including renamed and deleted files
- unstaged diff summary, including renamed and deleted files
- untracked file list, with enough content inspection to classify untracked work
- relevant full diffs or untracked file contents when summaries are insufficient
- repo instructions and existing context when present

## Durable Context

Record durable learnings, not a transcript. Use the repository's existing
documentation and working-memory structure:

- Stable repo truth belongs in the nearest durable docs.
- Live work state, next steps, blockers, and verification belong in
  `.context/handoff.md` when present.
- Task state changes belong in `.context/tasks.md` when present.
- Durable decisions belong in `.context/decisions.md` when present.
- Reusable workflow or vendor learnings belong in `.context/knowledge/` when
  present.
- Prefer updating existing notes over adding new files. Do not invent a parallel
  documentation system for commit prep.

## Verification

Record verification that has already run for the work. Run safe, relevant checks
needed to prepare the commit: targeted checks first, then the repo's full gate
when the work warrants it and the command is available. If verification cannot
run, explain why and name the next best check. Do not run generation or
stamp-recording commands as verification unless the user explicitly asks for
that production step.

## Commit Message

Use the repository's documented or clearly established convention. If no
convention is apparent, use imperative mood: concise title, blank line, then
high-signal bullets.

Describe the inspected diff, not future plans, guessed motivation, or unverified
tests. Include docs/context bullets only when they are primary user-facing value
or materially explain the change.

## Final Response

Return:

- docs/context/handoff updates, or `none` with a reason
- verification result, or why verification did not run
- commit scope
- proposed commit message
- dirty files excluded from the message only when the user narrowed scope
- blockers or follow-ups that affect the commit decision
