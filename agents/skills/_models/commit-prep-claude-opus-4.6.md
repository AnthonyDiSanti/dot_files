# Commit Prep — Claude Opus 4.6 Notes

- Skill: `agents/skills/commit-prep/SKILL.md`
- Model guide: `agents/model-guidance/anthropic-claude-opus-4.6.md`
- Status: future tuning notes; GPT-5.5 is the current implementation target
- Last reviewed: 2026-04-29

## Assessment

Opus 4.6 needs special care not to over-explore or over-journal. A future Claude
4.6 variant should keep retrieval budgets and stop rules more explicit than the
GPT-5.5 skill.

Skill-specific points to preserve:

- Treat staged state as user-owned review state, not scope.
- Draft for the full dirty tree unless the user explicitly narrows scope.
- Preserve the index exactly.
- Record durable context only where useful.
- Avoid turning `.context` into a transcript.
- Avoid repeated status/diff reads after the needed evidence is available.

## Examples

Use examples when output format starts drifting:

```text
<examples>
  <example name="mixed-index">
    <status>staged changes exist because the user reviewed them; unstaged edits
    are part of the same work unit</status>
    <response>Draft a commit message for the full dirty tree and preserve staged
    state exactly.</response>
  </example>
  <example name="user-narrowed-scope">
    <status>the user explicitly asks for a message covering only docs/</status>
    <response>Draft for docs/ and separately list dirty files outside that
    requested scope.</response>
  </example>
  <example name="blocked-verification">
    <status>verification command missing dependency</status>
    <response>Name the failed check, explain the missing dependency, and propose
    the next best validation.</response>
  </example>
</examples>
```

## Final Shape

```text
Return docs/context changes, verification, commit scope, copyable commit message,
and excluded dirty files or blockers.
```
