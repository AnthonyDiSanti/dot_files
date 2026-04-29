# Commit Prep — GPT-5.5 Notes

- Skill: `agents/skills/commit-prep/SKILL.md`
- Model guide: `agents/model-guidance/openai-gpt-5.5.md`
- Last reviewed: 2026-04-29

## Assessment

The current `commit-prep` skill should be judged against GPT-5.5 guidance as
follows:

- It should be compact enough to load cheaply.
- It should preserve the user-owned index as a hard invariant.
- It should treat staged state as review state, not commit scope.
- It should inspect live git state before drafting.
- It should update context based on classification, not habit.
- It should run relevant verification but avoid unnecessary heavy checks.
- It should draft for the full dirty tree by default.
- It should identify excluded dirty files only when the user requests a narrower
  scope.
- It should use existing docs/context organization without becoming the repo's
  only documentation system.

The skill should not include a long command-by-command recipe for every repo.
Repo-specific commands live in AGENTS. The skill should force the agent to look
for those instructions and then apply them.

## Prompt Shape

The skill should stay outcome-first:

```text
Prepare the current work for commit. Inspect live git state, preserve the staging
area exactly, update durable context only where useful, run relevant verification,
and draft a commit message for the full dirty tree unless the user explicitly
narrows scope.
```

Key GPT-5.5 implications:

- Keep the skill body short and contract-like.
- Make invariants explicit and few.
- Prefer success criteria over procedural narration.
- Keep evidence rules concrete enough to prevent memory-based commit messages.
- Keep final response shape explicit because commit prep has a fixed artifact.
- Treat docs/context updates as part of the outcome when they improve future
  retrieval.

## Guardrails

Use this wording when the index boundary regresses:

```text
The staging area belongs to the user. Treat it as review state, not commit-prep
scope. Draft for the full dirty tree unless the user explicitly narrows scope.
Do not stage, unstage, reset, restore, commit, amend, or rebase unless explicitly
asked.
```

Use this wording when context updates become too broad:

```text
Record durable learnings, not a transcript. Put live state in handoff/tasks and
reusable knowledge in knowledge notes. Prefer updating existing notes over adding
new files. Never store secrets.
```

## Evaluation Checklist

Use a realistic request with mixed staged and unstaged changes. The skill passes
when the agent:

- Reads staged, unstaged, and untracked state.
- Leaves the index unchanged.
- Drafts for the full dirty tree by default.
- Lists excluded dirty files only when the user requested a narrower scope.
- Updates `.context` only where useful.
- Records verification accurately.
- Produces a concise, copyable commit message in the repo's format.
