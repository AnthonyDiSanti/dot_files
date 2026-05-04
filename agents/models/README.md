# Models

This directory is the source of truth for model guidance. Each
`<model>.md` file stores repo-authored guidance derived from official
model prompt docs, including interpretation, comparison, local examples, and
skill-design implications that apply across skills.

Authoritative cached vendor docs belong in `../official-docs/`. Do not edit those
source documents while tuning these guidance files.

## Guides

- `gpt-5.5.md` - GPT-5.5 guidance for Codex and OpenAI reasoning models.
- `claude-opus-4-7.md` - Claude Opus 4.7 prompt and migration notes.
- `claude-opus-4-6.md` - Claude Opus 4.6 prompt and migration notes.
- `composer-2-fast.md` - Cursor Composer 2 Fast guidance for Cursor Agent.
- `gemini-3.1-pro-preview.md` - Gemini 3.1 Pro Preview guidance for Gemini CLI.

## Cross-Model Guidance

- Keep official docs, model guidance, harness guidance, and skill source
  separate.
- Prefer outcome-first instructions over long process scripts.
- Keep runtime skills concise; move large reference material to supporting files
  only when the skill needs it at runtime.
- Treat runtime skill descriptions as scarce trigger text. Several harnesses
  expose only metadata before loading full instructions, and Codex can shorten
  descriptions before omitting skills from a large initial list.
- Put skill trigger conditions in frontmatter descriptions rather than relying
  on body prose. The body is for the post-selection operating contract.
- Prefer concrete workflow structure over generic advice: objective, inputs,
  steps, guardrails, verification, and output expectations.
- Keep harness distribution surfaces separate. Codex sidecars, Cursor plugin
  manifests, Gemini extensions, hooks, rules, and agents should not be folded
  into canonical source skills unless that surface is the explicit target.
- Lean toward implicit invocation unless the workflow is unsafe or surprising.
- Use the local harness configuration as the authoring model; do not force
  target-model CLI overrides.
- Keep runtime artifact model directories canonical and versioned. If a harness
  exposes user-facing model aliases, normalize them in that harness's YAML
  config rather than in generic model guidance or Bash special cases.
- Treat artifacts as maintained outputs updated through scripts, not
  hand-edited generated blobs. Missing artifacts should stay missing until an
  updater invokes the target harness; do not manually bootstrap them or manually
  record freshness stamps.
- Put per-skill tuning in `model-notes/`, not in generic model files. Omit
  model-note files when the source skill and generic model guide already cover
  the target.
- Preserve user-owned git/index state as a cross-harness invariant for
  commit-related skills.

## Maintenance

- Consult official docs before updating these notes.
- Keep notes source-linked and concrete.
- Prefer model-specific implications over generic prompt-engineering advice.
- When tuning a skill, record reusable model-specific notes in
  that skill's `model-notes/` directory under `../skills/src/` rather than
  turning the generic guide into a per-skill audit log.
