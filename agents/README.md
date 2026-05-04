# Agents

This tree contains repo-managed agent infrastructure.

## Layout

- `skills/src/**/<skill>/` — canonical shared skill source directories plus
  optional model notes, harness notes, and eval fixtures. `SKILL.md`
  frontmatter is the source of skill identity. The skill directory name is the
  runtime skill id and must be unique across the source tree.
- `skills/artifacts/<harness>/<model>/` — maintained runtime artifacts using each
  harness/model target's deployable shape, such as
  `codex/gpt-5.5/skills/commit-prep/`.
- `skills/.update-stamps/<harness>/<model>/skills/<skill>/inputs.sha256` —
  committed content digest of the source/guidance inputs used for that artifact.
  The updater uses this instead of file mtimes.
- `prompts/src/**/<prompt>/` — canonical updater prompt source directories.
  `PROMPT.md` is the source prompt, and optional `harness-notes/` files record
  harness-specific deltas.
- `prompts/harnesses/<harness>/<prompt>.md` — maintained prompt artifacts used
  by updater scripts when asking a harness to update another artifact.
- `prompts/.update-stamps/<harness>/<prompt>/inputs.sha256` — committed content
  digest of the source/guidance inputs used for that prompt artifact.
- `harnesses/` — machine-readable harness configs and adapter docs. Harness ids
  match executable names, such as `claude` for the Claude Code CLI,
  `cursor-agent` for Cursor Agent, and `gemini` for Gemini CLI.
- `scripts/` — agent infrastructure tools, including
  `update-skill.bash`, `update-prompt.bash`, `update-all.bash`,
  `symlink-skill.bash`, and `symlink-all.bash`.
- `scripts/lib/agent-harnesses.bash` — shared harness inventory and
  missing-harness policy used by production update runs.
- `scripts/lib/agent-updaters.bash` — shared source discovery, digest/stamp, and
  harness-runner helpers used by artifact updater scripts.
- `official-docs/` — authoritative vendor docs copied from official sources, or
  pinned as optional reference submodules for larger upstream source/example
  trees such as Codex, Anthropic skills, Cursor plugins, and Gemini CLI. Treat
  these files as source material: do not hand-edit or distill them in place.
- `models/` — model guidance derived from the official docs.

## Rules

- Keep official vendor docs and derived guidance separate.
- Refresh `official-docs/` from the vendor source of truth when needed. For
  submodule-backed docs, update the pinned submodule commit or tag instead of
  editing upstream files directly.
- Put repo-local interpretation in `models/`, not in `official-docs/`.
- Keep source `SKILL.md` frontmatter harness-neutral. It should describe
  canonical skill identity, not runtime interfaces, UI labels, default prompts,
  or model-specific customization.
- Let each harness config define its runtime artifact shape and runner
  arguments. Codex artifacts use `SKILL.md` plus `agents/openai.yaml`; Claude
  Code, Cursor Agent, and Gemini CLI artifacts currently use only `SKILL.md`.
- Put skill-specific model tuning notes beside the source skill in
  `model-notes/`, not in generic model guidance. Omit the note file when a
  model has no skill-specific delta beyond the source skill and model guide.
- Put skill-specific harness tuning notes beside the source skill in
  `harness-notes/`, not in generic harness adapter docs. Harness notes should
  capture how one skill should adapt to a harness's runtime shape; global
  discovery, config, and runner behavior stays in `harnesses/<harness>.md`.
  Omit the note file when a harness has no skill-specific delta beyond the
  source skill and harness guide.
- Put shared artifact-production rules in the canonical source prompt or source
  skill, not in every harness/model note. Notes should be concise deltas that
  intentionally affect that one target's prompt or artifact digest.
- Update existing runtime artifacts in place when an updater script invokes the
  target harness; avoid wiping and regenerating hand-tuned skill text unless
  explicitly requested.
- Do not hand-edit, directly generate, or manually bootstrap runtime skill
  artifact contents under `skills/artifacts/`. Use
  `scripts/update-skill.bash` or `scripts/update-all.bash`; if the selected
  harness cannot run in the current environment, leave the artifact
  missing/stale and give the user the exact command to run instead.
- Do not hand-edit, directly generate, or manually bootstrap prompt artifact
  contents under `prompts/harnesses/` to reflect source or instruction changes.
  Use `scripts/update-prompt.bash` or `scripts/update-all.bash --type prompt`;
  keep harness-specific runner prose in prompt artifacts or prompt harness
  notes, not in harness YAML `runner_args`.
- Use content-digest stamps for selective regeneration. Do not rely on Git
  checkout mtimes to decide whether a committed artifact is stale. Keep stamps
  under `skills/.update-stamps/...` or `prompts/.update-stamps/...`, outside
  deployable artifact directories. Do not run `record-stamp` or manually update
  stamps unless the user explicitly asks to mark artifacts current without a
  native harness run.
- Aggregate artifact updates should iterate to a fixed point, so if an update changes a
  shared input, affected artifacts are revisited in a later pass.
- Pass `--force` to `update-skill.bash`, `update-prompt.bash`, or
  `update-all.bash` when selected artifacts should be re-run by their native
  harness on the first pass even though their input digest stamps are current.
  Later passes return to normal staleness checks so the fixed-point behavior
  still catches follow-on changes.
- `update-skill.bash` updates one source skill across selected harness/model
  artifacts. The skill argument can be a unique source skill directory name or a
  path relative to `skills/src/`. `--harness` alone or `--model` alone filters
  existing artifacts; pass both `--harness` and `--model` to create that
  explicit target if missing. Before running a skill update, it refreshes that
  harness's `update-skill-artifact` prompt artifact if stale. Skill artifact
  digests include the source `SKILL.md`, harness config/guide, model guide,
  optional harness notes, optional model notes, eval fixtures, and the harness
  prompt artifact when those inputs exist.
- `update-prompt.bash` updates one source prompt across selected harness prompt
  artifacts. The prompt argument can be a unique source prompt directory name or
  a path relative to `prompts/src/`. `--harness` creates the prompt artifact for
  that harness if missing. Prompt artifact digests include the source
  `PROMPT.md`, harness config/guide, optional prompt harness notes, and the
  harness prompt-updater template when those inputs exist.
- `update-all.bash` updates all maintained skill artifacts by default. Pass
  `--type prompt` to update prompt artifacts, or pass `--prompt <name>` as
  shorthand for one prompt across selected harness prompt artifacts. It
  intentionally does not accept skill filters; use `update-skill.bash <skill>`
  for skill-specific updates.
- Production update runs discover supported harnesses from
  `harnesses/<harness>.yaml`. If a selected native harness executable is
  missing, the run prompts to skip that target or to use an installed
  runner-capable fallback harness.
- Production update runs normally use each local harness configuration as the
  authoring model. Do not pass target artifact model versions as CLI overrides;
  model choices are represented by artifact paths, frontmatter, model guidance,
  and model notes. Narrow harness/account compatibility overrides such as Cursor
  Agent's `--model auto` are allowed when they do not name the target artifact
  model.
- Runtime artifacts should be maintained through `scripts/update-skill.bash`,
  `scripts/update-prompt.bash`, or `scripts/update-all.bash` so the target
  harness adapter, prompt artifacts, output checks, and digest stamps are all
  used. Treat missing artifacts as valid pre-bootstrap state, not as an excuse
  for manual file creation. Treat fallback harness production as an explicit
  exception to record, not the normal path.
- Updater scripts keep default output concise for bulk runs: bracketed status
  lines for changed/skipped targets, a fixed-point summary, and native harness
  output only on failure. Use `--verbose` when debugging stale reasons, nested
  updater behavior, or successful harness transcripts.
- `symlink-skill.bash` and `symlink-all.bash` deploy runtime artifacts into a
  selected home tree. They discover the configured target model from harness
  `home_config` files using each harness's explicit `model_config_key`, and
  apply any harness-owned `model_aliases` before selecting artifacts. They
  require explicit `--harness --model` when bootstrapping a target before that
  config exists. `symlink-all.bash [skill-prefix]` restricts bulk deployment to
  source skills under a `skills/src/` subtree, so a developer can link all skills
  for a team or domain without naming each skill individually. Symlink scripts
  intentionally print user-facing link summaries because they are the most common
  direct-developer deployment commands.
- Claude Code is currently pinned to Opus 4.6 through managed user settings,
  while separate runtime artifacts still exist for each supported Claude model.
  If the Claude settings file uses `best` or `opus`, deployment normalizes those
  aliases to the `claude-opus-4-7` artifact.
- Cursor Agent skill symlinks are managed under `home/.cursor/skills/`. The
  full Cursor CLI config remains local state, while stable CLI preferences are
  merged into the live config by `settings/cursor-agent-cli.sh`.
- Gemini skill symlinks are managed under `home/.gemini/skills/` to avoid
  rewriting Codex's `home/.agents/skills/` deployment. Gemini documents that
  same-named `.agents` skills shadow `.gemini` skills within the same tier, so
  confirm the active path with Gemini's skill listing when testing a
  Gemini-specific artifact for a skill that also exists under `.agents`.
- Any future production script that updates updater instructions or updater
  artifacts should source `scripts/lib/agent-harnesses.bash` and
  `scripts/lib/agent-updaters.bash` before invoking an agent harness.
- Keep skills concise and point to deeper references when they need model-specific
  behavior.
