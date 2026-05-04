# Codex Commit-Prep Notes

Codex commit-prep artifacts should include both:

- `SKILL.md` for the runtime skill body and trigger metadata.
- `agents/openai.yaml` for Codex-specific list/prompt-chip metadata.

Keep `agents/openai.yaml` derived from the canonical source skill:

- `interface.display_name` should stay short and human-readable.
- `interface.short_description` should summarize full-dirty-tree commit prep.
- `interface.default_prompt` should ask for context updates, verification, and a
  commit message while preserving the git index.
- `policy.allow_implicit_invocation` should remain `true`; commit prep is safe
  for implicit use because its invariants prohibit staging, committing, or
  rewriting git state without an explicit request.

Do not deploy this skill under `~/.codex/skills`; Codex uses this repo's
`.agents/skills` symlink path for runtime discovery.
