# Commit Prep — GPT-5.5 Notes

- Skill source: `agents/skills/src/commit-prep/SKILL.md`
- Runtime artifact: `agents/skills/artifacts/codex/gpt-5.5/skills/commit-prep/`
- Model guide: `agents/models/gpt-5.5.md`
- Last reviewed: 2026-05-02

## Assessment

The Codex GPT-5.5 artifact should:

- stay compact enough to load cheaply
- preserve the user-owned index as a hard invariant
- treat staged state as review state, not commit scope
- inspect live git state before drafting
- update context based on classification, not habit
- run relevant verification but avoid unnecessary heavy checks
- draft for the full dirty tree by default
- identify excluded dirty files only when the user requests a narrower scope
- use existing docs/context organization without becoming the repo's only
  documentation system

The runtime artifact should not include a long command-by-command recipe for every
repo. Repo-specific commands live in AGENTS. The skill should force the agent to
look for those instructions and then apply them.

The cached Codex skills guide reinforces the compact description requirement:
Codex only includes skill metadata before selection, and large skill sets can
shorten descriptions first. Keep `commit-prep` trigger language front-loaded
around commit prep, journaling, handoff, context capture, and commit-message
drafting.

The pinned Codex source examples reinforce a second split: keep `SKILL.md` as
the operational contract, and use `agents/openai.yaml` for concise UI/default
prompt metadata. `commit-prep` should not become a long repo-generic script.
Preserve a tight runtime body with outcome, evidence, invariants, verification,
and final response requirements. Let `openai.yaml` carry the fuller default
prompt that reminds Codex to inspect the full dirty tree, preserve the index,
update context selectively, verify, and draft the message.

## Prompt Shape

The runtime artifact should stay outcome-first:

```text
Prepare the current work for commit. Inspect live git state, preserve the staging
area exactly, update durable context only where useful, run relevant verification,
and draft a commit message for the full dirty tree unless the user explicitly
narrows scope.
```

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
