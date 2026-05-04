# Cursor Agent Commit-Prep Notes

Cursor Agent commit-prep artifacts should remain a single `SKILL.md`; do not
create Codex `agents/openai.yaml`, Claude-only frontmatter, plugin manifests, or
Cursor plugin packaging unless plugin deployment becomes an explicit target.

Keep `name` and `description` explicit, and omit
`disable-model-invocation: true` so the skill can be selected automatically when
the user asks for commit prep, handoff notes, saved context, or a commit message.

Cursor artifacts should be compact and action-oriented. Preserve the core
commit-prep invariants, especially full-dirty-tree scope by default and leaving
the user's git index exactly as found.
