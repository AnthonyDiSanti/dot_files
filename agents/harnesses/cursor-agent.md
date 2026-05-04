# Cursor Agent Harness Adapter

Cursor Agent discovers personal skills from `~/.cursor/skills/<skill>/SKILL.md`.
In this repo, deployment paths under `home/.cursor/skills/` are symlink nodes
that point back to runtime artifact directories under `agents/skills/artifacts/`.

Official Cursor docs commonly show the executable as `agent`, and this machine
has both `agent` and `cursor-agent` aliases installed. This repo intentionally
uses `cursor-agent` as the harness id because it is unambiguous in repo paths,
matches `agents/harnesses/cursor-agent.yaml`, and avoids collisions with other
generic agent CLIs.

## Runtime Shape

Cursor Agent runtime artifacts use:

```text
agents/skills/artifacts/cursor-agent/<model>/skills/<skill>/
  SKILL.md
```

`SKILL.md` frontmatter provides Cursor skill identity and trigger metadata.
Keep `name` and `description` explicit. Cursor supports
`disable-model-invocation: true` for explicit-only skills; omit it for skills
that should be available for automatic invocation from their descriptions.

Cursor's built-in skills live under `~/.cursor/skills-cursor/`. Do not deploy
repo-managed skills there; that directory is system-managed.

## User Config Boundary

Cursor CLI global state normally lives in `~/.cursor/cli-config.json`, but the
official docs say `CURSOR_CONFIG_DIR` can override the directory and
`XDG_CONFIG_HOME` can move it to `$XDG_CONFIG_HOME/cursor/cli-config.json`.
This repo's shell startup exports `CURSOR_CONFIG_DIR=$XDG_CONFIG_HOME/cursor`,
so the live macOS path is `~/.config/cursor/cli-config.json`. Official docs
describe this file as the home for model selection and most CLI settings;
project config only supports permissions. The global file contains local state,
caches, auth metadata, privacy settings, model picker state, and CLI-managed
fields, so this repo does not symlink the whole file.

Repo-managed Cursor CLI preferences live in `settings/cursor-agent-cli.json`
and are applied with `settings/cursor-agent-cli.sh`, which merges those
preferences into the live config while preserving Cursor-owned keys. The
managed JSON is self-contained enough to create a valid first-time config, but
it is still a patch over live state rather than the full tracked config file.

The symlink deployer reads the configured model from `modelId` in that file when
discovering live Cursor targets. Public docs describe a `model` object, but the
observed local config exposes `modelId`; keep that key explicit in
`cursor-agent.yaml` instead of relying on a default parser heuristic.

Cursor supports `auto` as a documented model selector through `/model auto`, and
Free plans can require Auto instead of named models for non-interactive runs.
Cursor may self-repair Auto config to `modelId: default` with
`displayModelId: auto`, so this repo maps both `auto` and `default` to the
canonical `composer-2-fast` artifact target in `cursor-agent.yaml`. Treat that
mapping as live product state: inspect `cursor-agent --list-models`,
`cursor-agent about`, and the official Cursor models page before retargeting
artifacts.

For repo `home/` deployment, prefer explicit targeting such as:

```text
agents/scripts/symlink-all.bash --home home --harness cursor-agent --model composer-2-fast
```

Cached config references to consult before changing Cursor-managed config:

- `agents/official-docs/cursor-agent-cli-configuration.md` for the global
  config boundary and model setting shape.
- `agents/official-docs/cursor-agent-cli-parameters.md` for automation flags
  such as `--print`, `--output-format`, `--trust`, `--force`, `--sandbox`, and
  `--workspace`.
- `agents/official-docs/cursor-agent-cli-usage.md` and
  `cursor-agent-cli-overview.md` for CLI behavior and workflow expectations.
- `agents/official-docs/cursor-agent-rules.md` for `AGENTS.md` and Cursor rules
  behavior.
- `agents/official-docs/cursor-agent-cli-mcp.md` before relying on MCP during
  artifact production.
- `agents/official-docs/cursor-plugins/schemas/` before managing Cursor plugin
  metadata or marketplace files.
- `agents/official-docs/cursor-plugins/*/skills/` for official Cursor plugin
  skill examples when deciding whether plugin conventions should influence
  runtime skill artifacts.

## Runner Shape

Artifact production uses Cursor Agent in non-interactive print mode. The current
runner arguments are defined in `agents/harnesses/cursor-agent.yaml`.

Rationale:

- Print mode is Cursor's automation mode and has access to write and shell
  tools.
- `--model auto` is a Cursor Free-plan compatibility override. It does not
  name the target artifact model; it forces Cursor's account-allowed Auto route
  because headless print mode rejected named/default model selection even after
  the live config was set to Auto.
- Text output keeps the updater transcript simple.
- Workspace trust avoids headless trust prompts.
- Forced command approval avoids prompts during a tightly scoped artifact update
  run; the updater prompt and repo verification remain the safety rails.
- Disabled sandboxing is a local compatibility choice. Cursor advertised
  sandbox controls, but `--sandbox enabled` was unavailable on this macOS
  install during testing. Do not generalize that to all machines without
  re-testing.

Cursor CLI also supports `--workspace <path>`, `--mode plan|ask`, `--worktree`,
MCP commands, and `--approve-mcps`. Do not add these to the runner by default.
Use them only when the updater workflow has a concrete need.

## Update Policy

When updating a Cursor Agent skill artifact:

- Preserve useful hand-written structure and local phrasing.
- Do not wipe and regenerate the whole artifact unless explicitly requested.
- Do not hand-edit or directly generate artifact contents. Use
  `agents/scripts/update-skill.bash` or `agents/scripts/update-all.bash` so the
  prompt, adapter, validation, and digest stamps stay aligned.
- If Cursor Agent cannot run because of auth, sandbox, or account/model limits,
  leave the artifact stale and give Anthony the exact updater command to run
  from a normal shell.
- Keep `SKILL.md` concise enough to load directly into context.
- Do not create Codex `agents/openai.yaml` metadata or Claude-specific
  frontmatter in Cursor artifacts.
- Use the local Cursor Agent configuration as the authoring model. Do not
  require an artifact to be written by the same target model version. The
  harness runner may still pass `--model auto` when required by Cursor account
  policy; do not replace it with the artifact model id.
- Preserve the repo's symlink deployment path.
- Do not modify the git index.

## Rules And Context

Cursor Agent reads `.cursor/rules`, root `AGENTS.md`, root `CLAUDE.md`, and
nested `AGENTS.md` files. Root `AGENTS.md` is therefore the shared repo contract
for Cursor too; avoid duplicating it inside Cursor skill artifacts.

Use `.cursor/rules` only when this repo needs Cursor-specific scoping or rule
activation behavior. A normal cross-harness instruction should go in root
`AGENTS.md`, the canonical skill source, model notes, or the relevant harness
adapter instead.

Cursor CLI automatically discovers MCP config shared with the editor. Artifact
updates should not depend on MCP tools unless the harness notes or skill
model-notes explicitly say so.

## Composer Targets

For Composer targets, use:

- `agents/models/<model>.md`
- the skill's `model-notes/<model>.md` beside its source `SKILL.md` when present
- official Cursor docs from `agents/official-docs/` only when the guide or notes
  are insufficient

Composer 2 Fast is Cursor's default Composer 2 variant on this machine and is
the first target for this repo.

## Plugin Reference Status

The optional `agents/official-docs/cursor-plugins` submodule pins Cursor's
official plugin examples, marketplace metadata, schemas, hooks, rules, and
plugin-packaged skills. It supplements the copied Cursor CLI/rules docs; it does
not replace them.

Use that submodule when adding Cursor plugin support or deciding whether a
repo-managed skill should also ship as part of a Cursor plugin. Keep the current
plain skill artifact shape unless plugin packaging becomes an explicit target.

Distilled patterns from official Cursor plugin skills:

- Cursor skills are plain `SKILL.md` files even when packaged inside plugins.
  The plugin wrapper adds distribution, schemas, rules, hooks, agents, and MCP
  surfaces; it does not imply that every runtime skill artifact should become a
  plugin.
- Good Cursor workflow skills are compact and action-oriented: trigger,
  required inputs, target location, workflow, guardrails, and output report.
  They avoid long background material unless the skill is itself instructional.
- Skills that may rewrite history, push, create files outside the repo, or
  change plugin manifests state their safety boundaries before the risky step
  and ask/plan when user confirmation is appropriate.
- Cursor plugin manifests prefer explicit relative component paths only when
  defaults are insufficient. Apply the same principle to this repo's artifacts:
  keep the simple `skills/<skill>/SKILL.md` shape until plugin packaging or
  custom discovery paths are a real requirement.
- The plugin examples pair specialized skills with optional rules/agents/hooks.
  Do not copy those surfaces into a skill artifact; introduce them as separate
  repo-managed agent surfaces if a future workflow needs them.
