# Skill Model Notes

This directory stores model-specific notes for individual skills. Use it for
skill tuning conclusions, eval observations, and prompt-shape decisions that are
too specific for `agents/model-guidance/` but useful when revising a skill.

## Naming

Use:

```text
<skill-name>-<model-name>.md
```

Examples:

- `commit-prep-gpt-5.5.md`
- `commit-prep-claude-opus-4.7.md`
- `commit-prep-claude-opus-4.6.md`

## Boundaries

- Keep generic model behavior in `agents/model-guidance/`.
- Keep runtime skill instructions in `agents/skills/<skill>/SKILL.md`.
- Keep these notes as development guidance; they are not loaded by Codex unless
  an agent explicitly opens them while tuning a skill.
