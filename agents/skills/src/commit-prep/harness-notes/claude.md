# Claude Code Commit-Prep Notes

Claude Code commit-prep artifacts should remain a single `SKILL.md`; do not
create Codex `agents/openai.yaml` sidecars or other companion metadata.

Keep Claude frontmatter explicit:

- Preserve `name: commit-prep`.
- Preserve the canonical trigger-oriented `description`.
- Keep the target artifact's `model` frontmatter aligned with the artifact model
  directory.

Do not add broad `allowed-tools`, `context: fork`, or invocation restrictions by
default. This skill should be available for automatic invocation because commit
prep is user-directed and bounded by the invariant that the agent must not stage,
unstage, commit, or rewrite git state unless explicitly asked.
