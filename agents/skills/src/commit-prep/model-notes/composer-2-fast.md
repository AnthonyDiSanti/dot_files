# Commit Prep on Cursor Composer 2 Fast

- Runtime artifact: `agents/skills/artifacts/cursor-agent/composer-2-fast/skills/commit-prep/`
- Model guide: `agents/models/composer-2-fast.md`
- Harness guide: `agents/harnesses/cursor-agent.md`
- Last reviewed: 2026-05-02

## Tuning Notes

Composer 2 Fast should be able to maintain this skill with a compact runtime
artifact because root `AGENTS.md`, the source skill, and the model guide carry
most of the durable context. The Cursor artifact should therefore be direct,
operational, and strict about invariants rather than explanatory.

Preserve these points prominently:

- The git index is user-owned review state. Do not stage, unstage, commit,
  amend, reset, restore, or discard unless explicitly asked.
- Commit-prep scope is the full dirty tree by default: staged, unstaged, and
  untracked files. A staged-only or path-limited message requires an explicit
  user request.
- Durable context updates are selective. Record real decisions, blockers,
  verification, and reusable learnings; do not write a transcript.
- Commit messages should follow the active repo's documented or clearly
  established convention. If no convention is apparent, fall back to imperative
  mood with a concise title, blank line, and high-signal bullets.

Prompting pressure:

- Keep the artifact concise enough for Cursor Agent to load directly.
- Prefer outcome/invariant/evidence language over long step-by-step recipes.
- Assume Cursor Agent already reads root `AGENTS.md`; reference repo
  instructions instead of duplicating the full contract.
- Make final response requirements explicit so non-interactive print mode
  returns the docs/context updates, verification, scope, message, and blockers.
