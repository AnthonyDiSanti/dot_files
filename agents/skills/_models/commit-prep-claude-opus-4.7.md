# Commit Prep — Claude Opus 4.7 Notes

- Skill: `agents/skills/commit-prep/SKILL.md`
- Model guide: `agents/model-guidance/anthropic-claude-opus-4.7.md`
- Status: future tuning notes; GPT-5.5 is the current implementation target
- Last reviewed: 2026-04-29

## Assessment

A Claude Opus 4.7 variant should likely be slightly more explicit than the
GPT-5.5 skill about scope and examples because Opus 4.7 follows instructions
literally.

Skill-specific points to preserve:

- Apply rules to staged, unstaged, and untracked changes.
- Treat the full dirty tree as default scope regardless of staged state.
- Preserve the git index exactly.
- Explain when to update handoff versus knowledge notes.
- Report excluded dirty files only when the user explicitly narrows scope.
- Keep progress updates sparse and final output concise.

## Output Contract

Use a concrete final-output contract if Claude starts varying the shape:

```text
Return a short summary, verification status, commit scope, one copyable commit
message, and any excluded dirty files if the user explicitly narrowed scope. Do
not include a long narrative of how the message was derived.
```

## Long-Context Pattern

When the skill is tuned under Claude, structure repo context explicitly:

```text
<repo_context>
  <document path="AGENTS.md">...</document>
  <document path=".context/handoff.md">...</document>
  <document path="changed-file">...</document>
</repo_context>

<task>
Prepare the work for commit. Preserve hard constraints from AGENTS.md and do not
duplicate unrelated guidance.
</task>
```
