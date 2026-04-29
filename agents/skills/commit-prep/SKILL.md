---
name: commit-prep
description: Prepare a completed work unit for commit by inspecting the full dirty git state, updating durable docs/context/handoff, recording important decisions or learnings, running relevant verification, and drafting a commit message for all uncommitted changes unless the user explicitly narrows scope. Use when work is complete or paused, or when the user asks for commit prep, a commit message, handoff notes, journaling, context capture, or save context. Preserve the user's git index exactly unless explicitly asked otherwise.
---

# Commit Prep

Use this skill at the end of a coherent work unit, before a commit, or before a
handoff. The outcome is a repository that is easier to resume plus a commit
message grounded in the actual working tree.

This skill is tuned for GPT-5.5. Prefer outcome-first execution: preserve the
invariants, inspect real state, update only useful durable notes, verify what is
safe and relevant, then draft the message.

## Non-negotiable Invariants

- Do not stage, unstage, commit, amend, reset, restore, rebase, discard, or
  rewrite git state unless the user explicitly asks.
- Treat the staging area as user-owned review state, not commit-prep scope.
  Consider the full dirty tree by default: staged, unstaged, and untracked
  changes. Leave staged state exactly as found.
- Draft for a narrower subset only when the user explicitly asks for that scope,
  then call out dirty files excluded from the message.
- Never store secrets, credentials, tokens, private keys, customer data, or raw
  sensitive logs in docs, context, scratch files, or commit messages.
- Prefer repo instructions over this skill when they are more specific.
- Keep context updates compact and retrieval-oriented.

## Success Criteria

Before final response, make sure:

- Git status and relevant staged, unstaged, and untracked diffs were inspected.
- Durable docs/context were updated only where they help future work.
- Any new reusable learning is recorded in the right place.
- Verification run is recorded, or the reason for skipping it is explicit.
- The commit message covers the full dirty tree unless the user requested a
  narrower scope.
- The commit message matches the chosen scope and repo commit-message format.
- Any dirty files outside a user-requested narrow scope are called out.

## Inspect

Start from live evidence, not memory.

Run:

- `git status --short --branch --untracked-files=all`
- `git diff --staged --stat`
- `git diff --stat`

Read full diffs only as needed for accuracy. Inspect untracked files that appear
relevant. Read repo instructions and context when present, especially `AGENTS.md`,
`AGENTS.local.md`, `README.md`, `.context/handoff.md`, `.context/tasks.md`,
`.context/decisions.md`, and `.context/knowledge/index.md`.

## Update Durable Context

Choose destinations by the type of information:

- Stable repo truth: update `/docs` when it exists; otherwise use
  `.context/knowledge/` when appropriate.
- Agent workflow learnings and tool quirks: use `.context/knowledge/` and update
  its index when adding a topic.
- Live work state, next steps, blockers, and verification status: update
  `.context/handoff.md`.
- Durable decisions: update `.context/decisions.md` in the repo's existing
  newest-first format.
- Task status changes: update `.context/tasks.md`.

Use the repo's existing documentation and context structure. It is fine to
reorganize `docs/` or `.context/knowledge/` when that improves retrieval, but do
not invent a parallel documentation system for commit prep alone. Do not journal
routine steps. Remove or reconcile context that conflicts with live repo
evidence.

## Verify

Run lightweight checks when safe and relevant. Use the repo's preferred targeted
checks first, then the full gate when the work warrants it and the command is
available. Do not run destructive, production-affecting, or unusually long
commands unless instructed.

If verification cannot be run, explain why and name the next best check.

## Draft The Commit Message

Draft after docs/context updates.

Determine scope:

- Default to the full dirty tree, regardless of staging state.
- Treat staged files as reviewed markers only; do not infer commit scope from the
  index.
- If the user explicitly asks for staged-only, path-limited, or otherwise narrow
  scope, draft for that scope and separately list excluded dirty files.

Use the repo's commit-message format. If no format exists, use:

```text
Third-person present-tense title

- Third-person present-tense bullet
- Third-person present-tense bullet
```

Prefer concise titles and high-signal bullets. Include docs/context bullets only
when they are primary user-facing value or materially explain the change.

## Final Response

Return:

- What docs/context/handoff files changed, or `none` with a reason.
- Verification run and result, or why it was not run.
- Commit scope: full dirty tree by default, or the explicit user-requested
  subset.
- A copyable commit message in a fenced block.
- Any dirty files not covered by the message because the user narrowed scope.
- Any blockers or follow-ups that should affect the commit decision.
