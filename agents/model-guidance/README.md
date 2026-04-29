# Model Guidance

This directory stores repo-authored guidance derived from official model prompt
docs. It is the place for interpretation, comparison, local examples, and
skill-design implications that apply across skills.

Authoritative cached vendor docs belong in `../official-docs/`. Do not edit those
source documents while tuning these guidance files.

## Guides

- `openai-gpt-5.5.md` - GPT-5.5 guidance for Codex and OpenAI reasoning models.
- `anthropic-claude-opus-4.7.md` - Claude Opus 4.7 prompt and migration notes.
- `anthropic-claude-opus-4.6.md` - Claude Opus 4.6 prompt and migration notes.

## Maintenance

- Consult official docs before updating these notes.
- Keep notes source-linked and concrete.
- Prefer model-specific implications over generic prompt-engineering advice.
- When tuning a skill, record reusable model-specific notes in
  `../skills/_models/` rather than turning the generic guide into a per-skill
  audit log.
