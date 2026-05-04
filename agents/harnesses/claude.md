# Claude Code Harness Adapter

Claude Code discovers personal skills from `~/.claude/skills/<skill>/SKILL.md`.
In this repo, deployment paths under `home/.claude/skills/` are symlink nodes
that point back to runtime artifact directories under `agents/skills/artifacts/`.

Claude Code is an important compatibility target, but Codex remains the primary
authoring environment for Anthony's day-to-day work. Keep Claude artifacts
native to Claude Code without making the canonical source skill Claude-specific.

## Runtime Shape

Claude Code runtime artifacts use:

```text
agents/skills/artifacts/claude/<model>/skills/<skill>/
  SKILL.md
```

`SKILL.md` frontmatter provides Claude Code trigger and runtime metadata. The
directory name becomes the slash-command name when `name` is omitted, but this
repo keeps `name` explicit for parity with other harnesses.

Claude Code does not use `agents/openai.yaml` or another YAML companion file for
personal skills. Do not create an `agents/` sidecar directory in Claude Code
runtime artifacts unless Claude Code adds a documented metadata file later.

## Skill Discovery

Claude Code skills are directories with a required `SKILL.md` file and optional
supporting files. Personal skills live under `~/.claude/skills/`; project skills
can live under `.claude/skills/`; plugin skills live inside enabled plugins.

Claude Code supports automatic model invocation and direct slash-command
invocation. Use the source skill description as the default trigger contract,
then tune Claude-only frontmatter only when the behavior is genuinely
Claude-specific.

Relevant Claude frontmatter fields:

- `name` gives the display/command name; keep it explicit.
- `description` tells Claude what the skill does and when to use it.
- `when_to_use` can add trigger context, but keep it short because it contributes
  to the skill listing budget.
- `disable-model-invocation: true` makes the skill explicit-only.
- `user-invocable: false` hides the skill from direct slash-command use.
- `allowed-tools` can pre-approve tools for a skill, but avoid adding broad
  grants to generated artifacts by default.
- `model` and `effort` can override the active session for the skill; use them
  only when the target artifact requires a deliberate model/effort choice.
- `context: fork` can run a skill in a subagent; do not add this unless the
  source skill is designed for that isolation.

This repo generally leans toward automatic invocation unless the workflow has
surprising side effects or should only run when Anthony explicitly invokes it.

## Supporting Files

Claude Code can load supporting files only when the skill points to them. Keep
runtime `SKILL.md` focused, and move large reference material into supporting
files only when the artifact actually needs those files at runtime.

Do not copy generic model guidance or full official docs into a runtime skill
body. The update prompt already passes canonical source, model guide, model
notes, harness guide, and existing artifact content to the authoring harness.

## User Config Boundary

Claude Code user settings live in `~/.claude/settings.json`; this repo manages
the corresponding literal home-tree file at `home/.claude/settings.json`.

The exact harness config lives in `agents/harnesses/claude.yaml`. It records the
Claude settings file, the explicit model config key, the skill deployment
directory, runtime output paths, runner arguments, and the small set of
Claude-native model aliases this repo currently supports.

Claude Code's `model` setting accepts either full model names or aliases.
According to the cached model-configuration docs, `best` currently resolves to
`opus`, and on the Anthropic API `opus` resolves to Opus 4.7. The repo keeps
runtime artifact directories canonical and versioned, so `claude.yaml` maps the
`best` and `opus` aliases to `claude-opus-4-7` for deployment and explicit
target selection.

Do not map `default`: it is a special value that clears the override and resolves
from account/provider policy. Do not map `sonnet`, `haiku`, `opusplan`, or
`[1m]` variants until the repo has corresponding runtime artifacts and a clear
deployment decision.

Do not manage `~/.claude.json` in this repo. It is Claude Code local state/cache,
not shared dotfile config.

Claude Code settings are hierarchical. User settings are the normal global
default for this repo's deployed home tree; project settings and command-line
flags can override them during a session. Artifact production should use the
local user's configured Claude Code model. Do not force a target model with
`--model` just because the artifact directory is named `claude-opus-4-7`.

Claude Code is intentionally pinned to Opus 4.6 in this repo's managed user
settings for now, while runtime artifacts may still target newer Claude Opus
models for evaluation or future opt-in.

Cached config references to consult before changing Claude-managed config:

- `agents/official-docs/claude-settings.md` for settings scopes, precedence,
  schema, user/project/local boundaries, permissions, hooks, plugins, and
  managed policy behavior.
- `agents/official-docs/claude-model-config.md` for model aliases, full model
  names, effort levels, default behavior, provider-specific alias resolution,
  and model override settings.
- `agents/official-docs/claude-skills.md` for personal/project/plugin skill
  layout, frontmatter, invocation control, subagent execution, and supporting
  files.
- `agents/official-docs/anthropic-skills/spec/agent-skills-spec.md` for the
  official skill spec when shaping canonical source skills or evaluating
  cross-harness compatibility.
- `agents/official-docs/anthropic-skills/template/SKILL.md` and
  `agents/official-docs/anthropic-skills/skills/` for official skill templates
  and examples.
- `agents/official-docs/claude-llms.txt` as the current Claude Code docs index
  before adding new surfaces such as hooks, MCP, subagents, or plugins.

## Runner Shape

Artifact production uses Claude Code print mode. The current runner arguments
are defined in `agents/harnesses/claude.yaml`.

Rationale:

- Print mode runs a prompt non-interactively and exits.
- Accept-edits permission mode allows the harness to apply artifact edits
  without repeatedly prompting inside the tightly scoped update run.
- The rendered updater prompt is sent on stdin so the script can assemble the
  full task from canonical source, model notes, harness notes, and existing
  artifact content.

Do not add `--dangerously-skip-permissions` for normal artifact production. If a
future runner needs structured output, prefer Claude Code's documented output
format flags over scraping interactive output.

The cached Claude CLI reference also documents `--max-turns`, `--max-budget-usd`,
`--setting-sources`, `--no-session-persistence`, and `--bare`. Keep them out of
the default runner until there is a concrete problem to solve: the current
runner intentionally uses the local user's normal Claude Code settings, while
the update prompt supplies the repo-specific source and guidance. Do not pass
`--model` for artifact production just because the target artifact path names a
model.

## Update Policy

When updating a Claude Code skill artifact:

- Use `agents/scripts/update-skill.bash` or `agents/scripts/update-all.bash`.
- Do not hand-edit or directly generate artifact contents as a shortcut.
- Preserve useful hand-written structure and local phrasing.
- Do not wipe and regenerate the whole artifact unless explicitly requested.
- Keep `SKILL.md` concise enough to load directly into context.
- Keep Claude-specific model/effort settings in `SKILL.md` frontmatter for the
  target artifact.
- Use the local Claude Code configuration as the authoring model. Do not require
  an artifact to be written by the same target model version.
- If another agent invokes `claude` from inside its own sandbox and receives an
  auth/API failure, treat that as an expected harness-boundary failure. Hand the
  generated command to Anthony for a normal shell run instead of assuming the
  artifact or prompt is wrong.
- Preserve the repo's symlink deployment path.
- Do not modify the git index.

## Claude Opus Targets

For Claude Opus targets, use:

- `agents/models/<model>.md`
- the skill's `model-notes/<model>.md` beside its source `SKILL.md` when present
- official Anthropic docs from `agents/official-docs/` only when the guide or
  notes are insufficient

Claude model guides should tune model behavior. The Claude harness guide should
tune Claude Code runtime shape, discovery, frontmatter, CLI behavior, and
settings behavior. Keep those concerns separate when revising either file.

## Official Docs Status

The repo caches Anthropic model/prompt docs plus Claude Code CLI, keybinding,
skills, settings, model-configuration, and docs-index references. Re-check those
cached docs before changing Claude Code skill discovery, frontmatter, settings,
model selection, or runner behavior.

The optional `agents/official-docs/anthropic-skills` submodule supplements the
copied Claude Code skills page with official skill specs, templates, and example
skills. It is useful for canonical skill source design; it does not replace the
Claude Code docs page for Claude-specific discovery paths, frontmatter behavior,
or runtime distribution details.

Distilled patterns from official Anthropic skills:

- Put all trigger language in `description`. The `skill-creator` example
  explicitly treats the description as the primary trigger mechanism and makes
  it slightly assertive so the model does not undertrigger useful skills.
- Keep runtime `SKILL.md` focused and progressively disclosed. The examples use
  supporting files for bulky reference content, templates, scripts, and assets
  instead of loading everything into the main body.
- Write skills as operational procedures with success criteria, not as broad
  background essays. Strong examples name the user inputs, expected output, core
  workflow, verification, and guardrails.
- Include examples when they disambiguate format or behavior. Keep examples
  representative rather than exhaustive.
- Use evals/test prompts for skills whose behavior is objectively checkable.
  The source repo's `skill-creator` workflow emphasizes realistic prompts,
  baseline comparisons, and iteration from evaluation results; keep that
  process in source/evals rather than bloating runtime artifacts.
- Optional frontmatter such as `license`, `allowed-tools`, model overrides, or
  invocation controls should be added only when the runtime artifact genuinely
  needs them.

Use `agents/official-docs/claude-llms.txt` to discover additional Claude Code
pages before adding new managed surfaces. Likely future pages to cache only when
needed include hooks, MCP, subagents, plugins, plugin marketplaces, memory, and
debug-your-config.
