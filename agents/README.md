# Agents

This tree contains repo-managed agent infrastructure.

## Layout

- `skills/` — canonical shared skill sources. Harness-specific deployment paths
  live under `home/` as symlink nodes.
- `skills/_models/` — model-specific notes for individual skills. These are
  development references, not runtime skill bodies.
- `official-docs/` — authoritative cached vendor docs copied from official
  sources. Treat these files as source material: do not hand-edit or distill them
  in place.
- `model-guidance/` — repo-authored guidance derived from the official docs, with
  local interpretations, prompt blocks, and skill-design notes.

## Rules

- Keep official vendor docs and derived guidance separate.
- Refresh `official-docs/` from the vendor source of truth when needed.
- Put repo-local interpretation in `model-guidance/`, not in `official-docs/`.
- Put skill-specific model tuning notes in `skills/_models/`, not in generic
  model guidance.
- Keep skills concise and point to deeper references when they need model-specific
  behavior.
