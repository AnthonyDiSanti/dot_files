# Gemini CLI

- Source: `agents/official-docs/gemini-cli/`, a pinned
  `google-gemini/gemini-cli` submodule at tag `v0.40.1`; copied Gemini model
  docs in `agents/official-docs/gemini-3*.md`; plus timely Google model
  references at <https://ai.google.dev/gemini-api/docs/models>.
- Why it matters: Gemini is planned as a future agent harness target, but only
  official docs should drive the runner, model config, skill deployment, and
  trust/sandbox behavior.
- When to consult: before adding a Gemini harness adapter, Gemini skill
  artifacts, or Gemini-specific symlink/deployment behavior.

## Current cache

- Cached when the submodule is hydrated: installation/authentication, CLI
  reference, slash commands, full configuration reference, `/settings`,
  headless mode, automation,
  `GEMINI.md` context files, `.geminiignore`, model selection/routing/steering,
  generation settings, plan mode, sandboxing, trusted folders, session
  management, skills, skill creation/usage/best-practices, custom commands,
  system-prompt overrides, tools reference, and extensions.
- Copied Gemini model docs include the Gemini 3 developer guide, Vertex Gemini
  3 getting-started guide, Vertex thinking guide, and Vertex Gemini 3.1 Pro
  model reference. Use these to update `agents/models/gemini-3.1-pro-preview.md`
  before regenerating Gemini artifacts.
- Cache shape: `agents/official-docs/gemini-cli` is a Git submodule, not copied
  files. Normal bootstrap does not hydrate it. Use
  `git submodule update --init --depth 1 agents/official-docs/gemini-cli` when
  working on Gemini support.
- Current local CLI: `gemini --version` reports `0.40.1`, matching the pinned
  submodule tag.

## Implications

- A non-interactive updater can use Gemini headless mode with redirected stdin.
  Current repo runner args rely on stdin plus `--output-format text` and keep
  task prose in prompt artifacts instead of a hardcoded `--prompt` YAML string.
  Structured output is available through `--output-format json` or
  `stream-json`, with documented exit codes.
- Gemini user settings live at `~/.gemini/settings.json` and workspace settings
  at `.gemini/settings.json`, with workspace settings overriding user settings.
  The model config key is `model.name`; model precedence is `--model`,
  `GEMINI_MODEL`, `model.name`, local experimental router, then default `auto`.
- Gemini documents model aliases such as `auto`, `pro`, `flash`, and
  `flash-lite`, but they resolve dynamically. Treat those as harness-native
  aliases only if we create matching canonical artifacts or deliberately choose
  an `auto` artifact.
- Anthony's preferred Gemini configuration is managed at
  `home/.gemini/settings.json`: OAuth personal auth, `model.name` set to
  `pro`, and a custom alias for the concrete `gemini-3.1-pro-preview` model
  that extends `chat-base-3` with `thinkingLevel = HIGH`.
- Keep Gemini artifacts stamped with explicit model versions. The Gemini harness
  YAML maps the live `pro` alias to the canonical `gemini-3.1-pro-preview`
  artifact target so personal use can follow the latest Pro route without
  making artifact provenance ambiguous.
- Do not manage `~/.gemini/oauth_creds.json`, `google_accounts.json`,
  `installation_id`, `state.json`, `projects.json`, history, tmp logs, or
  `trustedFolders.json`; those are credentials, local state, or personal
  identifiers. `google_accounts.json` only stores the active and prior Google
  account emails, not auth tokens, but that still exposes PII and does not
  justify weakening the repo's security posture.
- Gemini discovers user skills from `~/.gemini/skills/` and
  `~/.agents/skills/`, and workspace skills from `.gemini/skills/` and
  `.agents/skills/`. Within the same tier, `.agents/skills/` takes precedence
  over `.gemini/skills/`, matching the interoperable path we already use for
  Codex.
- Repo harness stance: deploy Gemini-specific artifacts under `.gemini/skills`
  so the Gemini symlinker never rewrites Codex's `.agents/skills` deployment.
  On a home tree where the same skill name exists under both `.agents` and
  `.gemini`, Gemini will use the `.agents` copy. Confirm the active path with
  `/skills list` or `gemini skills list` when testing a same-named
  Gemini-specific artifact.
- Gemini skills use `SKILL.md` with `name` and `description` frontmatter. The
  CLI progressively discloses skills via an `activate_skill` tool after user
  consent, so initial metadata quality matters.
- Gemini skill activation is consented and session-scoped: after the model
  chooses a matching skill, Gemini prompts to activate it, then injects the
  `SKILL.md` body and folder structure and grants access to bundled resources.
  This makes trigger descriptions important, but the runtime body can assume the
  user has approved the skill for the active task.
- Headless mode is the artifact-production entrypoint. Redirecting stdin is
  sufficient for the current runner; use `--prompt` only if a future Gemini CLI
  change requires an explicit non-interactive flag. Prefer `--output-format json`
  or `stream-json` if updater scripts need machine-readable output. Documented
  exit codes include success `0`, general/API error `1`, input error `42`, and
  turn-limit exceeded `53`.
- Model routing is enabled by default. `--model` and `GEMINI_MODEL` outrank
  `settings.json`, and fallback may prompt the user. For artifact production,
  prefer the local configured model and record any fallback if the run does not
  actually use the target artifact model.
- Gemini 3.1 Pro Preview access is availability-gated. The docs say to use
  `/model` manual selection to confirm access; when enabled, Auto (Gemini 3)
  may route to `gemini-3.1-pro-preview`, while `gemini -m
  gemini-3.1-pro-preview` directly requests it.
- On 2026-05-03, local `gemini --model pro --output-format stream-json`
  reported final usage under `gemini-3.1-pro-preview`, confirming that Anthony's
  current `pro` route resolves to 3.1 Pro Preview.
- Gemini harness deployment intentionally uses `~/.gemini/skills` for
  product-specific clarity even though `.agents/skills` has same-tier
  precedence, so same-named Codex skills can shadow Gemini-specific user skills.
