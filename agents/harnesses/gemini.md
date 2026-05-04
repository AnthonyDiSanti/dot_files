# Gemini CLI Harness Adapter

Gemini CLI discovers personal skills from `~/.gemini/skills/<skill>/SKILL.md`
and `~/.agents/skills/<skill>/SKILL.md`. In this repo, the Gemini-specific
deployment path under `home/.gemini/skills/` is a symlink node that points back
to runtime artifact directories under `agents/skills/artifacts/`.

The harness id is `gemini`, matching the `gemini` executable.

## Runtime Shape

Gemini runtime artifacts use:

```text
agents/skills/artifacts/gemini/<model>/skills/<skill>/
  SKILL.md
```

`SKILL.md` frontmatter provides the skill name and trigger description. Gemini
does not use Codex `agents/openai.yaml`, Claude-specific frontmatter, or Cursor
plugin metadata for ordinary personal skills.

## Skill Discovery

Gemini CLI discovers skills from workspace, user, and extension tiers. Workspace
skills override user skills, and user skills override extension skills.

Within the same tier, `.agents/skills/` takes precedence over `.gemini/skills/`.
That matters in this dotfiles repo because Codex uses `.agents/skills` for the
same personal skill names. The Gemini harness therefore uses `.gemini/skills` so
Gemini deployment never rewrites or steals Codex's `.agents/skills` symlink.

Consequence: on a home tree where `~/.agents/skills/commit-prep` and
`~/.gemini/skills/commit-prep` both exist, Gemini's documented precedence means
the `.agents` copy shadows the `.gemini` copy. To test the Gemini-specific
artifact for a skill with the same name, use a workspace-level Gemini skill,
temporarily remove the same-named `.agents` user skill, or explicitly inspect
Gemini's `/skills list` output to confirm which path is active.

Gemini skill activation is progressive:

- Only skill names and descriptions are injected initially.
- Gemini calls `activate_skill` when a task matches a skill description.
- The user approves activation.
- Gemini loads the `SKILL.md` body and bundled resource tree for the session.

Implications for artifacts:

- Keep `description` precise and trigger-oriented.
- Keep runtime `SKILL.md` concise and procedural.
- Put bulky examples, references, or scripts in supporting files only when the
  runtime artifact needs them.
- Do not rely on body prose to make Gemini choose the skill; the body is loaded
  only after activation.

## User Config Boundary

Gemini CLI user settings live in `~/.gemini/settings.json`; this repo manages
the corresponding literal home-tree file at `home/.gemini/settings.json`.

The exact harness config lives in `agents/harnesses/gemini.yaml`. It records the
Gemini settings file, the nested `model.name` config key, the skill deployment
directory, runtime output paths, and runner arguments.

Anthony's preferred managed Gemini settings currently use:

- OAuth personal auth.
- `model.name = "pro"` so live Gemini CLI sessions target the strongest
  available Pro route.
- `agents/harnesses/gemini.yaml` maps Gemini CLI's `pro` alias to the canonical
  `gemini-3.1-pro-preview` artifact target, keeping artifact directories
  explicit and versioned.
- A custom alias for the concrete `gemini-3.1-pro-preview` model extending
  `chat-base-3` with `thinkingLevel = "HIGH"`.

Do not manage Gemini local state or credentials in this repo, including
`oauth_creds.json`, `google_accounts.json`, `installation_id`, `state.json`,
`projects.json`, history, tmp logs, or `trustedFolders.json`.

Cached config references to consult before changing Gemini-managed config:

- `agents/official-docs/gemini-cli/docs/reference/configuration.md` for
  settings scopes, `model.name`, model configs, skills settings, approval mode,
  trust, output formats, and CLI flags.
- `agents/official-docs/gemini-cli/docs/cli/skills.md` for skill discovery,
  precedence, activation, management commands, and `.agents` alias behavior.
- `agents/official-docs/gemini-cli/docs/cli/creating-skills.md` for skill file
  structure and authoring expectations.
- `agents/official-docs/gemini-cli/docs/tools/activate-skill.md` for activation
  behavior.
- `agents/official-docs/gemini-cli/docs/cli/headless.md` and
  `agents/official-docs/gemini-cli/docs/cli/tutorials/automation.md` for
  non-interactive runner behavior.
- `agents/official-docs/gemini-cli/docs/cli/model-routing.md` and
  `agents/official-docs/gemini-cli/docs/get-started/gemini-3.md` for model
  precedence, routing, fallback, and Gemini 3 preview behavior.

## Runner Shape

Artifact production uses Gemini CLI headless mode. The current runner arguments
are defined in `agents/harnesses/gemini.yaml`.

Rationale:

- The rendered updater prompt is sent on stdin, which Gemini's documented
  headless mode accepts as context when stdin is redirected.
- Harness-specific runner instructions live in prompt artifacts under
  `agents/prompts/harnesses/gemini/`, not as prose embedded in `runner_args`.
- `--include-directories {{repo_root}}` makes the repo available even if the
  script is invoked from another working directory.
- `--skip-trust` trusts the current workspace for this session.
- `--approval-mode auto_edit` allows file edits while avoiding full YOLO command
  approval by default.
- Text output keeps updater transcripts simple.

Do not add `--model` to the runner. This repo's production policy is to use the
local user's configured harness model; the target artifact model is represented
by the artifact directory, model guide, and model notes.

If Gemini prompts for model fallback, lacks preview access, is unauthenticated,
or cannot complete because headless mode denies a tool, leave the artifact stale
and give Anthony the exact updater command to run or debug from a normal shell.
If fallback was used, record it because the target model did not fully author
the artifact.

## Update Policy

When updating a Gemini skill artifact:

- Preserve useful existing structure and wording.
- Create only the files listed by the harness config.
- Do not create Codex `agents/openai.yaml`, Claude-specific metadata, Cursor
  plugin files, or updater stamp files inside the artifact.
- Keep the source skill description as the activation contract.
- Preserve the canonical source invariants exactly, especially git/index
  ownership and dirty-tree scope for commit-related skills.
- Do not modify the git index.

## Gemini 3.1 Pro Preview Target

For `gemini/gemini-3.1-pro-preview`, use:

- `agents/models/gemini-3.1-pro-preview.md`
- the skill's `model-notes/gemini-3.1-pro-preview.md` beside its source
  `SKILL.md` when present
- official Gemini CLI docs from `agents/official-docs/gemini-cli/` only when the
  guide or notes are insufficient

Gemini 3.1 Pro Preview is availability-gated. Re-check access with `/model` or
a direct `gemini -m gemini-3.1-pro-preview ...` smoke test before assuming a
runtime artifact was actually authored by that model.

For live personal use, `gemini --model pro --output-format stream-json` showed
the final stats resolving `pro` to `gemini-3.1-pro-preview` on 2026-05-03.
