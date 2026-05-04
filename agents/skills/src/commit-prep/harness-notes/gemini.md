# Gemini CLI Commit-Prep Notes

Gemini commit-prep artifacts should remain a single `SKILL.md`; do not create
Codex `agents/openai.yaml`, Claude-only frontmatter, Cursor plugin files, or
updater stamp files inside the runtime artifact.

Gemini progressively activates skills after the model chooses a matching
description and the user approves activation. Keep the `description` precise and
trigger-oriented, then keep the body concise enough to load cleanly after
activation.

Preserve the source skill's commit-prep invariants exactly, especially:

- Draft for the full dirty tree by default, regardless of staging state.
- Treat the git index as user-owned review state.
- Do not stage, unstage, commit, amend, reset, restore, rebase, discard, or
  rewrite git state unless explicitly asked.

The repo deploys Gemini under `.gemini/skills` to avoid clobbering Codex's
`.agents/skills` symlink, but Gemini's documented same-tier precedence means a
same-named `.agents` user skill can shadow the Gemini-specific artifact during
manual testing.
