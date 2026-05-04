# Codex Harness Adapter

Codex is this repo's primary agent harness. Runtime artifacts for Codex should
feel native to Codex while still being derived from canonical source skills under
`agents/skills/src/`.

Codex discovers this repo's personal skills from
`~/.agents/skills/<skill>/SKILL.md`. In this repo, deployment paths under
`home/.agents/skills/` are symlink nodes that point back to runtime artifact
directories under `agents/skills/artifacts/`.

This path matches current public Codex docs and has been verified against the
installed Codex CLI with `codex debug prompt-input`. Older repo revisions used
`~/.codex/skills`; do not restore that path without retesting live CLI
discovery.

## Runtime Shape

Codex runtime artifacts use:

```text
agents/skills/artifacts/codex/gpt-5.5/skills/<skill>/
  SKILL.md
  agents/openai.yaml
```

`SKILL.md` frontmatter is the canonical source for skill identity and trigger
metadata in the runtime artifact. `agents/openai.yaml` provides Codex-specific
UI metadata for skill lists and prompt chips.

Do not add Claude or Cursor metadata to Codex artifacts. Do not move
Codex-specific `openai.yaml` fields into canonical source skill frontmatter.

## Skill Discovery

Codex skills are directories with a required `SKILL.md` file and optional
supporting directories such as `scripts/`, `references/`, `assets/`, and
`agents/`.

Codex uses progressive disclosure:

- The initial prompt includes each available skill's name, description, and
  file path.
- Codex reads the full `SKILL.md` only after selecting the skill.
- The initial skills list is budgeted; current docs describe a cap around 2% of
  context, or 8,000 characters when the context window is unknown.
- Large skill sets can cause descriptions to be shortened first, then omitted
  from the initial skills list.

Implications for runtime artifacts:

- Keep `description` concise, front-loaded, and trigger-oriented.
- Put safety boundaries in the description only when they affect whether the
  skill should trigger.
- Keep the runtime `SKILL.md` compact enough to load directly when selected.
- Put long reusable reference material in `references/` only when the runtime
  skill needs it, and tell Codex exactly when to read it.

Codex supports both explicit and implicit invocation. A user can explicitly name
a skill with `$skill-name`, and Codex can implicitly choose a skill when the task
matches the description. This repo generally leans toward implicit invocation
unless a skill is unsafe, broad, or surprising when auto-selected.

If two discovered Codex skills share the same `name`, Codex does not merge them;
both can appear in selectors. This repo is stricter: source skill directory
names must be globally unique because the directory name is also the runtime
artifact id.

## Symlink Deployment

This repo deploys skills with directory symlinks, not individual file symlinks.
That shape is both documented by Codex and verified locally.

The deployed path is intentionally two hops:

```text
~/.agents/skills/<skill>
  -> repo/home/.agents/skills/<skill>
  -> repo/agents/skills/artifacts/codex/<model>/skills/<skill>
```

The first hop lets `bootstrap.sh` manage the literal `home/` mirror. The second
hop lets the active runtime artifact move as harness/model artifacts evolve.

Avoid symlinking only `SKILL.md` or only files inside a skill directory. That
shape previously failed local Codex discovery because Codex expects a skill
directory, not a partially linked directory tree.

## `.codex` Versus `.agents`

Use `.codex` for Codex client configuration and user instructions:

- `~/.codex/config.toml` / `home/.codex/config.toml`
- `~/.codex/AGENTS.md` / `home/.codex/AGENTS.md`
- Codex rules, hooks, MCP config, plugin enabled/disabled state, and similar
  client settings

Use `.agents` for reusable agent assets that are meant to be discovered across
agent surfaces:

- user skills under `$HOME/.agents/skills`
- repo-scoped Codex skills under `.agents/skills`, discovered from the current
  working directory up to the repository root
- repo plugin marketplaces under `$REPO_ROOT/.agents/plugins/marketplace.json`
- personal plugin marketplaces under `~/.agents/plugins/marketplace.json`

Plugin packages themselves are not stored directly in `.agents/plugins` by
requirement. The marketplace file points at plugin directories, which may live
under a repo `plugins/` directory, `~/.codex/plugins/`, or another path inside
the marketplace root.

## `agents/openai.yaml`

When creating or updating `agents/openai.yaml`:

- Derive `interface.display_name` from the source skill frontmatter `name`,
  rewritten as a short title.
- Derive `interface.short_description` from the source skill frontmatter
  `description`, shortened for list display.
- Derive `interface.default_prompt` from the source skill frontmatter and body,
  phrased as a concrete user request.
- Keep `policy.allow_implicit_invocation` explicit. Default to `true` for
  skills that can be used safely from their description; set it to `false` only
  when implicit use would be unsafe or likely to surprise the user.
- Add icons, colors, or asset paths only when the artifact actually ships the
  referenced assets.

`openai.yaml` is a Codex sidecar. If the canonical source skill does not need a
Codex-only interface field, do not copy that field upstream into source.

## User Config Boundary

Codex user defaults live in `~/.codex/config.toml`; this repo manages the
corresponding literal home-tree file at `home/.codex/config.toml`.

The exact harness config lives in `agents/harnesses/codex.yaml`. It records the
Codex config file, the explicit model config key, the skill deployment
directory, runtime output paths, and runner arguments.

Do not add parser heuristics for model discovery when a harness exposes an
explicit key. If Codex changes the config key or config format, update
`codex.yaml` and the symlink scripts together.

Codex configuration precedence matters when debugging skill updates:

- CLI flags and `--config` overrides win over profiles.
- Project `.codex/config.toml` layers can override user config for trusted
  projects.
- User `~/.codex/config.toml` is still the normal source for this repo's
  selected authoring model.

Artifact production should use the local user's configured Codex model. Do not
force the target model with `--model` just because the artifact directory is
named `gpt-5.5`.

Cached config references to consult before changing Codex-managed config:

- `agents/official-docs/codex-config-basics.md` for user/project config
  layering and common settings.
- `agents/official-docs/codex-config-reference.md` for exact key names and
  types.
- `agents/official-docs/codex-config-advanced.md` for profiles, custom
  providers, project roots, hooks, telemetry, and advanced integrations.
- `agents/official-docs/codex-sample-config.toml` for a broad example of
  current keys and comments.
- `agents/official-docs/codex/codex-rs/core/config.schema.json` when a schema
  check against the pinned CLI source is more useful than the public prose docs.
- `agents/official-docs/codex/codex-rs/hooks/schema/generated/` for pinned hook
  input/output schemas.

The current Codex docs do not expose a Claude-style semantic model alias such
as `best`. Codex config uses concrete model slugs such as `gpt-5.5`; the live
Codex models page remains external because recommended models and account
availability change over time. `notice.model_migrations` in Codex config is
product state for acknowledged migration notices, not this repo's artifact
alias map.

## Runner Shape

Artifact production uses `codex exec` in non-interactive mode. The current
runner arguments are defined in `agents/harnesses/codex.yaml`.

Rationale:

- `exec` is Codex's scripting/automation entrypoint.
- Ephemeral mode avoids persisting session rollout files for build-style runs.
- The repo-root working directory anchors the workspace before the prompt
  executes.
- Workspace-write sandboxing allows the harness to edit artifact files in the
  checkout while keeping normal filesystem boundaries.
- The rendered updater prompt is sent on stdin so the script can assemble the
  full task from canonical source, model notes, harness notes, and existing
  artifact content.

Do not use `--dangerously-bypass-approvals-and-sandbox`, `--yolo`, or
`danger-full-access` for normal artifact production. Those modes are only
appropriate inside isolated runners with an explicit reason.

`codex exec` defaults to more restrictive behavior in many contexts. If future
artifact runners need machine-readable transcripts, prefer `--json` or
`--output-last-message` over scraping terminal UI output.

`codex exec` requires a Git repository by default. Keep artifact production
anchored at the repo root instead of adding `--skip-git-repo-check`.

## Instructions And Context

Codex reads global instructions from `~/.codex/AGENTS.md` and project
instructions from repo `AGENTS.md` files. It loads one global file from
`CODEX_HOME` / `~/.codex` and one project instruction file per directory as it
walks from the repository root to the current working directory. Within a
directory, `AGENTS.override.md` wins over `AGENTS.md`, which wins over configured
fallback filenames.

This repo manages both:

- `home/.codex/AGENTS.md` for Anthony's personal global Codex defaults
- root `AGENTS.md` for shared repo instructions

Codex skips empty instruction files and stops adding project instructions once
`project_doc_max_bytes` is reached; the documented default is 32 KiB. Keep root
`AGENTS.md` practical and split specialized guidance into narrower files or
skills instead of relying on a huge root prompt.

Keep cross-harness repo truth in root `AGENTS.md`, not in Codex-only runtime
artifacts. Use Codex-specific instructions in `home/.codex/AGENTS.md`,
`codex.md`, or Codex runtime artifacts only when the behavior is genuinely
Codex-specific.

The update scripts intentionally pass the harness guide and model guide into
the artifact-maintenance prompt. Runtime artifacts should not duplicate all of
that guidance. They should preserve the concrete behavior needed when the skill
is selected.

## Update Policy

When updating a Codex skill artifact:

- Use `agents/scripts/update-skill.bash` or `agents/scripts/update-all.bash`.
- Do not hand-edit or directly generate artifact contents as a shortcut.
- Preserve useful hand-written structure and local phrasing.
- Do not wipe and regenerate the whole artifact unless explicitly requested.
- Keep `SKILL.md` concise enough to load directly into context.
- Keep Codex-specific metadata in `agents/openai.yaml`.
- Use the local Codex configuration as the authoring model. Do not require an
  artifact to be written by the same target model version.
- If Codex cannot run because of auth, sandbox, account, or environment issues,
  leave the artifact stale and give Anthony the exact updater command to run
  from a normal shell.
- Preserve the repo's symlink deployment path.
- Do not modify the git index.

## GPT-5.5 Target

For `codex/gpt-5.5`, use:

- `agents/models/gpt-5.5.md`
- the skill's `model-notes/gpt-5.5.md` beside its source `SKILL.md` when present
- official OpenAI docs from `agents/official-docs/` only when the guide or notes
  are insufficient

The GPT-5.5 guide should tune model behavior. The Codex harness guide should tune
Codex runtime shape, discovery, metadata, and CLI behavior. Keep those concerns
separate when revising either file.

## Source Snapshot Status

The optional `agents/official-docs/codex` submodule pins the `openai/codex`
source tree to tag `rust-v0.128.0`, matching the local `codex-cli 0.128.0`
checked during the reference pass.

Use that submodule for source-owned details that are not fully captured by the
public docs cache:

- built-in Codex skills under `.codex/skills/`
- generated config and hook schemas
- app-server protocol schemas
- source-level behavior checks when local CLI behavior and public docs diverge

Distilled patterns from built-in Codex skills:

- Keep ordinary workflow skills highly operational. The best examples define
  objective, inputs, workflow, commands, guardrails, validation, and output
  expectations instead of restating generic agent behavior.
- Use supporting `scripts/` and `references/` for deterministic or bulky logic.
  `SKILL.md` should explain when to run those assets and how to interpret their
  output; it should not inline large scripts or API notes.
- Put risky GitHub/Git behavior behind explicit guardrails: infer the target,
  inspect existing state, preserve user-owned work, avoid destructive commands,
  and continue/stop only on named conditions.
- Make `agents/openai.yaml` useful but concise. `display_name` and
  `short_description` are list/UI metadata; `default_prompt` can be more
  complete and action-oriented than the short description, especially for
  workflows with important invariants.
- Orchestrator skills can delegate to narrower skills, but only when the
  harness actually supports that pattern and the skill names/subtasks are
  concrete. Do not turn a normal single-skill workflow into an orchestrator just
  because examples exist.

Do not remove copied `agents/official-docs/codex-*.md` docs just because the
source snapshot exists. Several source docs are short stubs that link back to
developers.openai.com, while the copied exports contain the richer public docs.

## Official Docs Status

Core Codex harness docs are cached under `agents/official-docs/`, including
skills, config basics/reference/advanced/sample, `AGENTS.md`, rules, plugins,
CLI features/reference/slash commands, non-interactive mode, sandboxing, MCP,
subagents, hooks, memories, feature maturity, and Codex best practices.
Re-check those cached docs before changing the corresponding Codex-managed
surface.

Keep <https://developers.openai.com/codex/models> as a live external reference.
Consult it before changing Codex model slugs, choosing a new Codex target, or
documenting current model availability.
