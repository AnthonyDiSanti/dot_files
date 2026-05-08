# Decisions

Decider format: `Anthony` for human decisions, `Codex (model: gpt-5.2-codex)` for agent decisions.
Keep newest decisions at the top (reverse chronological order).

## 2026-05-08 — Feature-detect the shared dash alias
- Decider: Codex (model: gpt-5.5)
- Decision: Define the shared `-` alias with `alias -- -='cd -'` when the
  active shell supports it, and fall back to `alias '-=cd -'` for dash.
- Rationale: `home/.config/shell/aliases.sh` is sourced by `sh`, bash, and zsh.
  Bash and zsh need the `--` option delimiter for an option-shaped alias name,
  while dash rejects `alias --` and fails shared `/bin/sh` startup.
- Consequences / follow-ups: Keep option-shaped shared aliases behind
  capability probes or move shell-specific forms into bash/zsh layers. Verify
  shared alias changes with `sh`, bash, and zsh startup checks.

## 2026-05-03 — Merge Cursor Agent CLI preferences instead of symlinking state
- Decider: Anthony
- Decision: Standardize Cursor Agent CLI config on
  `$XDG_CONFIG_HOME/cursor/cli-config.json` via `CURSOR_CONFIG_DIR`, but manage
  only a repo-owned preference patch through `settings/cursor-agent-cli.sh`.
- Rationale: Cursor's live `cli-config.json` mixes durable preferences with
  auth metadata, privacy/cache data, model picker state, and CLI-managed fields.
  Symlinking the whole file would let Cursor write local state into the repo.
- Consequences / follow-ups: `~/.cursor/cli-config.json` is legacy for this
  shell environment and should be moved aside rather than kept as a competing
  active config. The current account-compatible preference remains Auto/default,
  and `cursor-agent.yaml` maps both `auto` and `default` to
  `composer-2-fast`.

## 2026-05-03 — Keep shared agent-update policy in source files
- Decider: Anthony
- Decision: Shared artifact-production and commit-prep rules belong in the
  canonical source prompts or source skills. `model-notes/` and
  `harness-notes/` remain optional delta files, not required placeholders for
  every model or harness.
- Rationale: Repeating the same guardrails across every note file makes the
  tree noisy and increases staleness without adding target-specific value.
  Source files are the correct durable home for shared behavior, while notes
  should exist only when they intentionally affect one prompt/artifact digest.
- Consequences / follow-ups: The updater scripts already tolerate missing note
  files. When adding a new model or harness, create notes only for real deltas;
  do not add carbon-copy notes just to mirror the matrix.

## 2026-05-03 — Do not manually bootstrap agent artifacts
- Decider: Anthony
- Decision: Runtime skill artifacts, prompt artifacts, and digest stamps must be
  produced only by updater scripts invoking the selected harness, not by manual
  file creation or direct agent patches.
- Rationale: Manual bootstrapping makes generated artifacts look reviewed by a
  target harness when they were not, and manual stamp updates hide the staleness
  that should drive the next native generation run.
- Consequences / follow-ups: Missing artifacts and missing/stale stamps are
  valid pre-bootstrap state. If the current agent cannot run a required harness,
  it must leave the artifact missing/stale and give Anthony the exact updater
  command to run from a normal shell. `record-stamp` should be used only when
  Anthony explicitly asks to mark artifacts current without a native harness run.

## 2026-05-03 — Add prompt harness notes beside prompt source
- Decider: Anthony
- Decision: Add per-prompt `harness-notes/<harness>.md` files under
  `agents/prompts/src/**/<prompt>/`, mirroring the skill harness-note pattern.
- Rationale: Prompt artifacts are harness-scoped and can need runner-specific
  guidance, especially for headless/stdin behavior, sandbox/auth limitations,
  and placeholder preservation. Keeping those notes beside each source prompt
  scopes staleness to the affected prompt/harness pair instead of mixing prompt
  maintenance guidance into generic harness docs or YAML runner arguments.
- Consequences / follow-ups: `update-prompt.bash` already passes matching prompt
  harness notes into rendered maintenance prompts and includes them in prompt
  artifact digests. The `update-skill-artifact` and `update-prompt-artifact`
  source prompts now have notes for Codex, Claude Code, Cursor Agent, and
  Gemini CLI.

## 2026-05-03 — Add skill harness notes beside model notes
- Decider: Anthony
- Decision: Add per-skill `harness-notes/<harness>.md` files instead of
  replacing `model-notes/` with a generalized artifact-notes layer.
- Rationale: Harness notes and model notes align with the two stable artifact
  axes. A generalized artifact-notes directory would let agents choose relevant
  files dynamically, but including every note in every artifact digest would make
  unrelated target changes stale across the matrix. Side-by-side harness notes
  keep staleness scoped to the affected harness while still capturing
  skill-specific runtime-shape guidance.
- Consequences / follow-ups: `update-skill.bash` now passes matching
  `harness-notes/<harness>.md` into the update prompt and includes it in the
  artifact digest. `commit-prep` has initial notes for Codex, Claude Code,
  Cursor Agent, and Gemini CLI.

## 2026-05-03 — Maintain updater prompts as harness artifacts
- Decider: Anthony
- Decision: Store canonical updater prompt source under `agents/prompts/src/`,
  materialize harness-specific prompt artifacts under
  `agents/prompts/harnesses/<harness>/`, and track their freshness with
  committed digest stamps under `agents/prompts/.update-stamps/`.
- Rationale: Skill artifact generation and prompt artifact generation share the
  same source-discovery, stale-checking, native-harness, and fallback mechanics,
  but prompt artifacts are harness-scoped rather than harness/model-scoped.
  Making prompts first-class artifacts lets harness-specific runner instructions
  live in reviewable prompt text instead of opaque YAML argv strings.
- Consequences / follow-ups: `update-prompt.bash` owns prompt artifact updates;
  `update-skill.bash` consumes `agents/prompts/harnesses/<harness>/update-skill-artifact.md`
  and refreshes that prompt artifact before running a native skill update.
  `update-all.bash` defaults to skill mode but supports `--type prompt` and
  `--prompt`. Gemini's former hardcoded `--prompt` runner prose now belongs in
  the Gemini prompt artifacts, while `agents/harnesses/gemini.yaml` keeps only
  structural CLI args.

## 2026-05-03 — Deploy Gemini skills under `.gemini/skills`
- Decider: Codex (model: gpt-5.5)
- Decision: Add Gemini CLI as the `gemini` harness and deploy its
  harness-specific skill artifacts under `home/.gemini/skills/`, not
  `home/.agents/skills/`.
- Rationale: Gemini supports both `.agents/skills` and `.gemini/skills`, but
  Codex already uses `.agents/skills` for Anthony's active personal skill
  deployment. Pointing Gemini at `.agents/skills` would make `symlink-all`
  race the Codex symlink for the same skill id and whichever harness ran last
  would clobber the other. Using `.gemini/skills` keeps Gemini deployment
  product-specific and non-destructive.
- Consequences / follow-ups: Gemini documents that same-tier `.agents/skills`
  takes precedence over `.gemini/skills`, so a same-named Codex user skill can
  shadow the Gemini-specific user skill. When testing Gemini-specific artifacts,
  confirm the active path with `/skills list` or `gemini skills list`, or use a
  workspace-level Gemini skill / temporary `.agents` removal for that skill.

## 2026-05-03 — Keep Gemini account identity local
- Decider: Anthony
- Decision: Do not manage `~/.gemini/google_accounts.json` in this repo.
- Rationale: The file appears to contain only the active and historical Google
  account email addresses, not OAuth tokens, but those addresses are still
  personally identifying account data. Syncing that preference is not valuable
  enough to compromise the repo's current posture of keeping account files
  local.
- Consequences / follow-ups: Continue managing only safe Gemini settings such
  as `home/.gemini/settings.json`. Keep `oauth_creds.json`,
  `google_accounts.json`, `trustedFolders.json`, `installation_id`,
  `state.json`, `projects.json`, history, and tmp logs outside the repo.

## 2026-05-03 — Use optional source submodules for agent references
- Decider: Anthony
- Decision: Add shallow, pinned reference submodules under `agents/official-docs`
  for `openai/codex` at tag `rust-v0.128.0`, `anthropics/skills` at commit
  `5128e1865d670f5d6c9cef000e6dfc4e951fb5b9`, and `cursor/plugins` at commit
  `7dd9fea1e0e9bb88fcf059f5e77eb5a9d31bef1e`.
- Rationale: These repositories reduce manual maintenance for source-owned
  reference material: Codex schemas, source docs, built-in skills, and protocol
  details; Anthropic's official skill spec/templates/examples; and Cursor's
  plugin schemas/examples. They are optional development references, so normal
  bootstrap and verification should not require hydration.
- Consequences / follow-ups: Keep copied developers.openai.com, Claude Code,
  and Cursor docs when they are richer than the source repos; for example,
  several `openai/codex` docs files only link back to public Codex docs. Do not
  edit submodule files in place. Refresh by moving gitlinks to newer official
  tags or commits, then review derived harness/model guidance.

## 2026-05-03 — Exclude submodules from broad verification scans
- Decider: Anthony
- Decision: Repo-wide shell verification enumerators must treat paths listed in
  `.gitmodules` as vendor/reference boundaries and exclude those paths from
  syntax, ShellCheck, and shfmt scans.
- Rationale: Optional reference submodules such as
  `agents/official-docs/gemini-cli` are upstream-owned material. Hydrating them
  should not cause `test/verify.sh` to lint, format, or otherwise validate the
  upstream tree as if it were native dotfiles source.
- Consequences / follow-ups: `scripts/shell_files.bash` now owns the submodule
  exclusion for shell-file discovery, and `test/verify.sh` has a guard that
  fails if emitted shell files are inside a `.gitmodules` path. Extend the same
  boundary if future broad enumerators scan other file types.

## 2026-05-03 — Use a positional skill prefix for bulk symlink deployment
- Decider: Anthony
- Decision: `agents/scripts/symlink-all.bash` accepts one optional positional
  `skill-prefix` argument, interpreted as a path relative to
  `agents/skills/src/`. The prefix deploys all source skills below that subtree
  and is mutually exclusive with repeated `--skill` filters.
- Rationale: Source skills are expected to be organized by team or domain, such
  as `frontend/` or `services/`, and a team member should be able to deploy all
  skills in that subtree without enumerating each skill. A positional prefix is
  concise and does not currently conflict with likely future `symlink-all`
  surfaces.
- Consequences / follow-ups: Keep `--skill` for individual source skill
  selection. If `symlink-all` later deploys non-skill surfaces, preserve the
  current positional skill-prefix behavior unless a concrete ambiguity appears.

## 2026-05-03 — Use a Gemini CLI submodule for reference docs
- Decider: Anthony
- Decision: Track `google-gemini/gemini-cli` as a shallow, pinned Git submodule
  at `agents/official-docs/gemini-cli`, currently on tag `v0.40.1`.
- Rationale: Gemini CLI docs are only needed for a niche agent-infrastructure
  development workflow, and the upstream repo already contains a coherent docs
  tree. A submodule makes versioning and refreshes explicit without bloating the
  parent repo with a copied 4MB+ docs cache or requiring normal bootstrap users
  to hydrate the reference material.
- Consequences / follow-ups: Bootstrap and normal verification must not require
  the Gemini submodule to be hydrated. Hydrate it with `git submodule update
  --init --depth 1 agents/official-docs/gemini-cli` before working on Gemini
  harness support or refreshing Gemini docs. The 2026-04-27 "avoid submodules by
  default" decision still applies to runtime dependencies; this is an
  explicitly scoped reference-doc exception.

## 2026-05-03 — Normalize harness-native model aliases in harness YAML
- Decider: Anthony
- Decision: Runtime artifact model directories remain canonical/versioned, but
  harness configs may declare `model_aliases` for native aliases exposed by that
  harness. Claude Code now maps `best` and `opus` to `claude-opus-4-7` in
  `agents/harnesses/claude.yaml`.
- Rationale: Claude Code officially allows aliases in the `model` setting, and
  `best` currently resolves through `opus` to Opus 4.7 on the Anthropic API.
  Without a narrow alias layer, a valid user config such as `"model": "best"`
  would make symlink deployment look for a non-canonical `claude/best`
  artifact.
- Consequences / follow-ups: Alias handling lives at the harness
  config/deployment boundary, not in generic Bash special cases or model guides.
  Do not map Claude `default` because it clears the model override and resolves
  through account/provider policy. Add aliases for other harnesses only when
  official docs expose stable alias semantics and corresponding artifacts exist.

## 2026-05-02 — Add first-pass force refreshes for skill artifacts
- Decider: Anthony
- Decision: `agents/scripts/update-skill.bash` and
  `agents/scripts/update-all.bash` accept `--force` to re-run selected runtime
  skill artifacts even when their input digest stamps are current.
- Rationale: Sometimes all selected artifacts need native-harness review or
  regeneration even when source inputs have not changed. A force flag keeps that
  workflow explicit without deleting stamps or hand-editing artifacts.
- Consequences / follow-ups: `--force` only affects the first fixed-point pass.
  Later passes return to normal staleness checks so follow-on changes still
  converge. For `update-skill.bash`, `--force` applies to the default
  `run-if-stale` action; use `--action run` for a one-shot unconditional run of
  selected targets.

## 2026-05-02 — Keep `update-all.bash` as a whole-surface updater
- Decider: Anthony
- Decision: `agents/scripts/update-all.bash` should accept harness/model target
  filters but no skill-specific filter or positional skill argument. Use
  `agents/scripts/update-skill.bash <skill>` for skill-specific artifact
  refreshes.
- Rationale: `update-all.bash` may later update other maintained agent surfaces,
  such as tools or plugins. Harness/model filters generalize across those
  surfaces, while a skill argument does not.
- Consequences / follow-ups: `update-all.bash --skill ...` now fails with a
  targeted error pointing users to `update-skill.bash <skill>`. Docs should
  describe `update-all.bash` as a whole-surface updater, not a filtered skill
  subset runner.

## 2026-05-02 — Deploy Codex skills through `.agents/skills`
- Decider: Anthony
- Decision: Codex runtime skills should deploy through
  `home/.agents/skills/<skill>`, matching Codex's documented user-skill path
  `$HOME/.agents/skills/<skill>/SKILL.md`. Keep Codex config, global
  instructions, rules, plugin settings, and other Codex client settings under
  `home/.codex/`.
- Rationale: Current public Codex docs list `$HOME/.agents/skills` for user
  skills, `.agents/skills` for repo-scoped skills, and symlinked skill folders
  as supported. Local smoke tests with `codex debug prompt-input` confirmed that
  the installed CLI discovers both a plain temporary `$HOME/.agents/skills`
  skill and a symlinked `commit-prep` skill pointing at this repo's runtime
  artifact. Codex docs still place user config and global `AGENTS.md` under
  `~/.codex`, so only skills move.
- Consequences / follow-ups: `agents/harnesses/codex.yaml` now uses
  `skills_dir: .agents/skills`, and `home/.agents/skills/commit-prep` points at
  the Codex/GPT-5.5 runtime artifact. After bootstrap on an existing machine,
  the old `~/.codex/skills/commit-prep` symlink should be pruned by the managed
  target state.

## 2026-05-02 — Produce runtime skill artifacts only through updater scripts
- Decider: Anthony
- Decision: Agents must not hand-edit or directly generate runtime skill
  artifact contents under `agents/skills/artifacts/`. Artifact content changes
  must flow through `agents/scripts/update-skill.bash` or
  `agents/scripts/update-all.bash`, using the selected native harness whenever
  possible.
- Rationale: The updater scripts preserve the common prompt, harness adapter,
  validation checks, content-digest stamps, and native-harness authorship. Manual
  patches make artifacts look current without the target harness actually
  reviewing or producing them.
- Consequences / follow-ups: If auth, sandboxing, account limits, or missing
  executables prevent the selected harness from running in the current agent
  environment, leave the artifact stale and give Anthony the exact updater
  command to run from a normal shell.

## 2026-05-02 — Use imperative mood for commit message proposals
- Decider: Anthony
- Decision: Commit-message guidance should prefer imperative mood titles and
  bullets (`Add`, `Fix`, `Keep`) instead of third-person present tense (`Adds`,
  `Fixes`, `Keeps`). Repo-specific instructions still win when a repository
  deliberately chooses a different format.
- Rationale: Imperative mood matches the long-standing Git/Linux-kernel style:
  describe what applying the commit does. The previous third-person style was a
  repo-local preference, not the broader conventional default.
- Consequences / follow-ups: `home/.codex/AGENTS.md`, project `AGENTS.md`, and
  the canonical `commit-prep` source now encode the imperative default. Runtime
  `commit-prep` artifacts should be refreshed by their native harnesses through
  the updater scripts; do not hand-edit generated artifacts just to sync wording.

## 2026-05-02 — Add Cursor Agent through skills only
- Decider: Anthony
- Decision: Add Cursor Agent as the `cursor-agent` harness with Composer 2 Fast
  as the first model target, deploy `commit-prep` through
  `home/.cursor/skills/commit-prep`, and leave the full Cursor CLI config local
  for now.
- Rationale: Cursor's CLI config contains model picker state, permissions,
  auth/cache/privacy/server data, and other local state. Official docs default
  to `~/.cursor/cli-config.json`, but this repo sets `XDG_CONFIG_HOME`, so the
  live macOS path is `~/.config/cursor/cli-config.json`. Managing the whole file
  as a dotfile would risk overwriting state; skill symlink nodes are the stable
  deployment surface.
- Consequences / follow-ups: `cursor-agent.yaml` uses
  `home_config: .config/cursor/cli-config.json` and `model_config_key: modelId`
  so live config discovery can read Cursor's configured model. Use explicit
  `--harness cursor-agent --model composer-2-fast` when regenerating repo-home
  symlinks because repo `home/` intentionally does not include a Cursor config
  file.

## 2026-05-02 — Use harness-native model ids for artifacts
- Decider: Anthony
- Decision: Use the model ids exposed by harness config files as this repo's
  model artifact ids. Claude Code artifacts, model guides, model notes, stamps,
  and symlink targets now use `claude-opus-4-6` and `claude-opus-4-7` rather
  than repo-local dotted ids.
- Rationale: Keeping a separate repo spelling such as `claude-opus-4.6` created
  a normalization layer with no real benefit. Matching external model ids makes
  home-config discovery direct and removes `model_aliases` from harness configs.
- Consequences / follow-ups: Future model artifacts should prefer the canonical
  id used by the harness/API config unless there is a concrete reason to add an
  explicit mapping layer.

## 2026-05-02 — Prefer implicit Codex skill invocation when safe
- Decider: Anthony
- Decision: Codex skill artifacts should generally set
  `policy.allow_implicit_invocation: true` when the skill can be safely invoked
  from its description. Use `false` only when implicit use would be unsafe or
  likely to surprise the user.
- Rationale: Anthony prefers skills to be available ergonomically without
  explicit invocation by default, while still preserving a safety escape hatch
  for high-risk or ambiguous behaviors.
- Consequences / follow-ups: `agents/harnesses/codex.md` now frames implicit
  invocation as the normal default posture for Codex `agents/openai.yaml`
  artifacts.

## 2026-05-02 — Add skill artifact symlink runners
- Decider: Anthony
- Decision: Add `agents/scripts/symlink-skill.bash` and
  `agents/scripts/symlink-all.bash` to deploy maintained runtime skill artifacts
  into harness skill directories under a selected home tree. Harness YAML now
  records `home_config` and `skills_dir` so this deployment stays data-driven.
- Rationale: Runtime artifact generation and home-tree deployment are separate
  steps. The repo should be able to regenerate symlink nodes from harness/model
  artifacts, discover the active model from managed or live harness config when
  possible, and still bootstrap explicit harness/model targets before a config
  exists.
- Consequences / follow-ups: Without explicit `--harness --model`, symlink
  runners inspect each harness's `home_config` under the selected `--home` tree,
  derive the model, and symlink only matching artifacts. Runtime artifact model
  directory names should match the ids exposed by harness config files, such as
  Claude Code's `claude-opus-4-6`, to avoid a separate alias layer.

## 2026-05-02 — Allow nested skill source folders
- Decider: Anthony
- Decision: Treat any directory below `agents/skills/src/` containing a
  `SKILL.md` file as a source skill directory.
  `agents/scripts/update-skill.bash` accepts either a globally unique skill
  directory name or a path relative to `agents/skills/src/`; runtime artifacts
  and stamps still use the skill directory name as the skill id.
- Rationale: Teams should be able to organize canonical skill sources into
  domain or ownership subdirectories without changing deployed harness shapes.
  Runtime harnesses still expect flat `skills/<skill>/` deployment paths, so the
  skill directory name remains the stable skill id.
- Consequences / follow-ups: Source skill directory names must be unique across
  the full `src/` tree and use the existing safe id characters. If duplicate
  names are needed later, revisit artifact/stamp path design before allowing
  them.

## 2026-05-02 — Use SKILL frontmatter as canonical skill metadata
- Decider: Anthony
- Decision: Remove separate source `metadata.yaml` files and use canonical
  `SKILL.md` frontmatter as the source of skill identity.
- Rationale: The source `metadata.yaml` duplicated `SKILL.md` frontmatter
  (`name` and `description`) and created a second source of truth. Harness
  reification can derive runtime metadata such as Codex `agents/openai.yaml`
  from the source skill frontmatter and body.
- Consequences / follow-ups: The updater prompt no longer includes neutral
  metadata as a separate input, artifact digest stamps no longer hash
  `metadata.yaml`, and the skill-metadata schema was removed. Reintroduce a
  separate source metadata file only if the repo needs cross-harness metadata
  that does not belong in `SKILL.md` frontmatter.

## 2026-05-02 — Drive harness behavior from harness YAML files
- Decider: Anthony
- Decision: Discover supported agent harnesses from
  `agents/harnesses/<harness>.yaml`, with `<harness>` matching the executable
  name. Keep agent-facing guidance in `agents/harnesses/<harness>.md`.
- Rationale: Harness behavior should be driven by CLI inputs, filesystem
  conventions, and small config files rather than Bash mappings. Adding a new
  harness should primarily mean adding the harness config/doc, model guidance,
  and artifacts.
- Consequences / follow-ups: Harness YAML records runtime artifact `outputs` and
  `runner_args`; the updater sends the rendered prompt to the harness executable
  on stdin and expands `{{repo_root}}` in args. Bash still owns generic matrix,
  freshness, prompting, and fallback control flow, but no longer maps harness
  ids to display labels, executable names, runner args, or output paths.

## 2026-05-02 — Align harness ids with executable names
- Decider: Anthony
- Decision: Use the actual executable name as the stable harness id. Claude
  Code's harness id is `claude`, not `claude-code`; docs may still refer to the
  product as Claude Code where that is the clearer human-facing name.
- Rationale: A separate harness-to-command mapping adds avoidable indirection
  now that target model/provider inference has been removed. The updater only
  needs to know whether a harness is supported and whether a runner is
  configured; command invocation should be obvious from the target id.
- Consequences / follow-ups: Runtime artifacts, stamps, and harness adapters use
  `agents/skills/artifacts/claude/...`,
  `agents/skills/.update-stamps/claude/...`, and `agents/harnesses/claude.md`.
  Future harness ids should match their command names unless there is a concrete
  collision or portability issue.

## 2026-05-02 — Resolve model guides directly by model id
- Decider: Anthony
- Decision: Treat harness and model as independent explicit target axes. Store
  model guidance at `agents/models/<model>.md`, harness adapters at
  `agents/harnesses/<harness>.md`, and runtime artifacts/stamps under
  `<harness>/<model>/` paths.
- Rationale: The updater never needs to infer an appropriate harness from a
  model. A harness names the runtime shape being produced, while a model names
  the guidance used to tune that artifact. Provider-prefix mappings in Bash add
  false coupling and break down for harnesses that can target multiple providers.
- Consequences / follow-ups: `agent-harnesses.bash` should not map harnesses to
  model-guide provider prefixes. To add a new model, add
  `agents/models/<model>.md`; to add a new harness, add
  `agents/harnesses/<harness>.md` and the real harness runtime/runner behavior.

## 2026-05-02 — Use axis-based skill artifact runners
- Decider: Anthony
- Decision: Rename the artifact production entrypoints to
  `agents/scripts/update-skill.bash` and `agents/scripts/update-all.bash`.
  Both runners accept `--harness` and `--model` as axis filters; passing both is
  an explicit harness/model target and creates it if missing.
- Rationale: The core workflows are updating one skill across targets, updating
  every maintained artifact cell, or refreshing a filtered harness/model
  subset. Putting full `--harness` / `--model` support on both public scripts is
  easier to reason about than maintaining separate harness-axis and model-axis
  wrapper scripts.
- Consequences / follow-ups: `--harness` alone and `--model` alone select only
  existing artifact directories on that axis. To bootstrap a new target, pass
  both `--harness <harness>` and `--model <model>`; the runner then validates the
  harness adapter and model guide before invoking the native or fallback harness.

## 2026-05-02 — Add a matrix runner for existing skill artifacts
- Decider: Anthony
- Decision: Use `agents/scripts/update-all.bash` as the matrix runner
  for refreshing every maintained skill artifact across selected harness/model
  targets.
- Rationale: The common "refresh everything already represented in artifacts"
  workflow should not require manually looping over harness/model directories,
  but the existing skill runner should remain the
  source of truth for actual artifact updates.
- Consequences / follow-ups: The all-artifacts runner discovers existing
  harness/model directories by default, supports `--harness` and `--model`
  filters, intentionally has no skill filter, and repeats matrix passes until the
  source/artifact/stamp input digest is stable.

## 2026-05-02 — Mirror skill artifact paths in stamp paths
- Decider: Anthony
- Decision: Store each skill artifact's input digest stamp at
  `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/inputs.sha256`.
- Rationale: The freshness unit is the concrete harness/model skill artifact, not
  a whole harness/model run or a skill-wide batch. Mirroring the runtime artifact
  path makes the tracked cell explicit and leaves room for future per-artifact
  metadata beside the input digest.
- Consequences / follow-ups: `update-skill.bash --action run` and
  `record-stamp` update this file for one artifact. Aggregate runners only update
  stamps indirectly by invoking that skill runner.

## 2026-05-02 — Keep agent runner entrypoints explicitly Bash-suffixed
- Decider: Anthony
- Decision: Agent infrastructure runner scripts under `agents/scripts/` should
  use `.bash` suffixes, such as `update-skill.bash`,
  and `update-all.bash`.
- Rationale: These are repo-local developer scripts rather than installed PATH
  commands. The suffix makes their shell dialect visible in editors, linting, and
  documentation while the shebang still supports direct execution.
- Consequences / follow-ups: Keep shared libraries suffixed as `.bash` too. If a
  runner later needs to be exposed as a stable extensionless command, add an
  intentional shim rather than dropping the source-file suffix.

## 2026-05-02 — Name runtime artifacts by harness and model
- Decider: Anthony
- Decision: Keep runtime skill artifacts under
  `agents/skills/artifacts/<harness>/<model>/` and use harness/model artifact paths
  such as `codex/gpt-5.5` and `claude/claude-opus-4-6`.
- Rationale: The artifact ultimately has to satisfy a specific harness's runtime
  shape and a specific target model's prompting needs. Naming the top-level
  artifact by both pieces keeps those concerns visible while still allowing the
  updater to use whatever local harness configuration the user has selected as
  the authoring model.
- Consequences / follow-ups: Do not maintain a separate default-target mapping
  file. The home symlinks are the deployment mapping. `update-skill.bash`
  updates one skill across selected harness/model artifact directories, and
  `update-all.bash` bootstraps or refreshes all maintained skill artifacts for
  selected harness/model targets.

## 2026-05-02 — Use local harness configuration to author skill artifacts
- Decider: Anthony
- Decision: For skill artifact production, use each local harness configuration
  as the authoring model instead of manually invoking a particular target model
  version inside that harness.
- Rationale: Exact self-authoring by every model version is overkill and becomes
  messy across harnesses. The important boundary is the runtime artifact:
  the generated skill still carries target-specific frontmatter and
  model-guided instruction adjustments, while the native provider harness owns
  the authoring workflow.
- Consequences / follow-ups: `agents/scripts/update-skill.bash` must not pass
  target-model CLI overrides such as Codex `--model` or Claude Code `--model`.
  `commit-prep` has Claude Code artifacts for Opus 4.6 and Opus 4.7, but the
  managed home symlink remains pointed at Opus 4.6 until Anthony opts into 4.7.

## 2026-05-01 — Pin Claude Code skill work to Opus 4.6
- Decider: Anthony
- Decision: Manage Claude Code user-scope settings through `home/.claude/settings.json`, pin Claude Code to `claude-opus-4-6` for now, and expose the `commit-prep` Claude Opus 4.6 artifact through a directory symlink at `home/.claude/skills/commit-prep`.
- Rationale: The repo wants real harness-specific artifacts to validate the multi-harness pipeline, but Anthony explicitly prefers Claude Code on Opus 4.6 rather than the latest Opus 4.7. Claude Code's documented personal skill path is `~/.claude/skills/<skill>/SKILL.md`, matching the directory-symlink deployment pattern already selected for Codex.
- Consequences / follow-ups: `claude/claude-opus-4-6` remains the deployed
  Claude Code artifact for now. Keep the Opus 4.7 artifact available for evaluation
  or future opt-in.

## 2026-05-01 — Use content-digest stamps for skill artifact freshness
- Decider: Anthony
- Decision: Selective skill artifact updates should use committed content-digest stamps under `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/`, not filesystem mtimes, Make-style timestamp checks, or files inside runtime artifact directories. `agents/scripts/update-skill.bash` should run selected artifacts until it reaches a fixed point.
- Rationale: These generated/runtime artifacts are committed to Git, and Git checkouts can make mtime-based freshness unreliable or misleading. A digest over the canonical source, harness guide/config, model guide, optional model notes, updater prompt, and eval fixtures makes staleness explicit and copy-paste friendly. Keeping stamps outside `artifacts/` keeps deployed runtime skill directories free of build metadata.
- Consequences / follow-ups: Each artifact records `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/inputs.sha256`. `update-skill.bash --action status|is-stale|run-if-stale|record-stamp` handles selected artifacts for one skill, while `update-all.bash` provides the higher-level fixed-point loop for all maintained skill artifacts across selected harness/model targets. Future updater-instruction artifacts should use the same digest/fixed-point pattern without requiring those instructions to be installed as a runtime skill.

## 2026-05-01 — Maintain model-specific skill artifacts in place
- Decider: Anthony
- Decision: Keep canonical skill source under `agents/skills/src/` as
  directories containing `SKILL.md`, runtime artifacts under
  `agents/skills/artifacts/<harness>/<model>/skills/<skill>/`, and
  skill-specific model notes beside the source skill under `model-notes/`.
  Maintain existing written artifacts in place with
  `agents/scripts/update-skill.bash` rather than wiping and regenerating them.
- Rationale: Different models and harnesses need meaningfully different prompting and metadata, but each runtime skill should remain reviewable and hand-tunable. Updating existing artifacts preserves hard-won phrasing while still letting a harness/model-specific agent apply targeted retuning from the canonical source, model guide, harness adapter, and model notes.
- Consequences / follow-ups: `commit-prep` now has a Codex/GPT-5.5 runtime artifact at `agents/skills/artifacts/codex/gpt-5.5/skills/commit-prep/`, and `home/.agents/skills/commit-prep` points at that artifact. Use `agents/scripts/update-skill.bash --harness codex --model gpt-5.5 --action check|print-prompt|run commit-prep` for the vertical slice. Future harnesses should add adapters and artifacts rather than changing the Codex runtime directly.

## 2026-04-29 — Commit prep drafts for the full dirty tree by default
- Decider: Anthony
- Decision: The `commit-prep` skill should inspect and draft against the full dirty working tree by default, including staged, unstaged, and untracked files. Staged files are user-owned review state, not a signal to limit commit scope.
- Rationale: Anthony stages files incrementally while reviewing agent work. At any moment, the index may contain an arbitrary reviewed subset, while unstaged files may be reminders or the result of a later correction prompt. A staged-first commit message would routinely omit relevant work.
- Consequences / follow-ups: Preserve the index exactly, but do not infer scope from it. Draft for staged-only, path-limited, or otherwise narrowed scope only when explicitly requested, and then list dirty files excluded from that requested scope.

## 2026-04-28 — Separate official agent docs from model guidance
- Decider: Anthony
- Decision: Keep authoritative copied vendor docs under `agents/official-docs/` and repo-authored model interpretations under `agents/models/`, starting with GPT-5.5, Claude Opus 4.7, and Claude Opus 4.6. Tune the `commit-prep` skill for GPT-5.5 first.
- Rationale: Prompt behavior differs materially by model version. The official docs are source material and should not be corrupted with repo-local edits. Derived guidance belongs next to them but separate, so skills can use local interpretations and examples without modifying the authoritative cache.
- Consequences / follow-ups: Re-check official vendor docs before retuning a skill for a named model. `commit-prep` now follows GPT-5.5-style outcome-first structure with explicit invariants, success criteria, verification, and final-output shape.

## 2026-04-28 — Manage shared agent skills outside the home mirror
- Decider: Anthony
- Decision: Keep repo-managed agent skills outside the literal `home/` mirror
  and expose deployed runtime artifacts to Codex through symlink nodes in the
  mirror, such as `home/.agents/skills/<skill> -> ../../../agents/skills/artifacts/<harness>/<model>/skills/<skill>`.
- Rationale: Agent skills may need to be deployed to multiple harness-specific locations over time, while sharing the same canonical source. Keeping the deployment path as a symlink node under `home/` preserves the readable `$HOME` mirror and lets bootstrap use its general symlink-to-symlink behavior instead of hardcoding Codex-specific directory logic.
- Consequences / follow-ups: Codex discovers the two-hop layout
  `~/.agents/skills/<skill> -> repo/home/.agents/skills/<skill> -> repo/agents/skills/artifacts/<harness>/<model>/skills/<skill>`,
  but did not discover the skill when only individual files such as `SKILL.md` were
  symlinked. Restart Codex sessions after changing skill metadata.

## 2026-04-28 — Manage iTerm2 Solarized Dark through a dynamic profile
- Decider: Anthony
- Decision: Add a repo-managed iTerm2 dynamic profile at `home/Library/Application Support/iTerm2/DynamicProfiles/solarized-dark.json`, instead of managing iTerm2's entire preferences plist. Add `settings/iterm2.sh` to set iTerm2's `Default Bookmark Guid` to the managed profile when applying machine settings.
- Rationale: iTerm2 watches the DynamicProfiles folder and reloads valid profile property lists, so a single symlink-backed profile keeps terminal chrome/palette settings under dotfiles control without taking ownership of unrelated local iTerm preferences. The profile inlines canonical Solarized Dark colors, disables bright-bold color substitution, and leaves minimum contrast at zero so iTerm2 does not shift Solarized colors. iTerm2 imports dynamic profiles into the normal profile list with a `Dynamic` tag; `Dynamic Profile Parent Name` only controls inherited settings. Dynamic profiles cannot reliably make themselves the default, so default selection is handled as an explicit macOS preference write rather than through an AutoLaunch Python script.
- Consequences / follow-ups: Bootstrap now needs tab-separated manifest/state records because `Library/Application Support` contains spaces. After bootstrap, run `settings/iterm2.sh` once to point new iTerm2 windows at `Solarized Dark (dotfiles)`.

## 2026-04-28 — Use Microsoft-native WSL clipboard bridge
- Decider: Anthony
- Decision: Implement WSL clipboard support through Microsoft-provided `clip.exe` for copy and PowerShell `Get-Clipboard` for paste, rather than through `win32yank.exe`.
- Rationale: The direct system integration is simple enough to be the preferred design, not just a fallback. Copy is a straightforward `clip.exe` pipe, paste is one PowerShell `Get-Clipboard -Raw` call, and the repo wrapper owns newline normalization. `win32yank` is small and convenient, but it adds a third-party binary/dependency chain without enough benefit to justify it.
- Consequences / follow-ups: `dotfiles-clipboard` owns the quoting/newline normalization so zsh and tmux do not need WSL-specific logic. Copy uses `clip.exe`; paste uses PowerShell `Get-Clipboard -Raw` and strips carriage returns. Treat `win32yank` as rejected for this repo by default, not merely deferred, unless the Microsoft-native path proves insufficient in real WSL testing.

## 2026-04-28 — Treat tmux line-selection switching as an upstream bug
- Decider: Anthony
- Decision: Keep the current `home/.tmux.conf` Vim-style selection bindings as the correct local configuration, with fresh `V` using `select-line` as a workaround and mid-selection switches to `V` still using `rectangle-off ; selection-mode line`. Save the detailed upstream bug draft for later work against tmux itself.
- Rationale: `selection-mode line` is the correct tmux command for switching an active selection into line mode, but tmux 3.6a and master lazily apply it and clobber the anchor row to the top of the visible viewport. `select-line` works only for fresh line-selection entry because it collapses to the current row, so it cannot preserve an existing multi-line range.
- Consequences / follow-ups: Full draft lives at `.context/scratch/20260428-tmux-selection-mode-line-bug/report.md`. File or fix this upstream only at the very end of the project, after Neovim evaluation and tmux plugin evaluation. When tmux is fixed, the mid-selection path should work without config changes; fresh `V` may optionally migrate back to `begin-selection ; rectangle-off ; selection-mode line` for symmetry.

## 2026-04-28 — Defer TPM until after Neovim
- Decider: Anthony
- Decision: Treat the current tmux configuration pass as complete without adding TPM or tmux plugins. Revisit TPM and likely candidates such as `tmux-resurrect` and `tmux-continuum` only after Neovim has been considered.
- Rationale: The current work is focused on tmux configuration and clipboard behavior, while plugin-managed session persistence is a larger workflow decision. Deferring keeps this pass bounded and avoids introducing a plugin manager before the editor direction is settled.
- Consequences / follow-ups: Do not add TPM in the clipboard/tmux branch. Track tmux plugin evaluation as a future workstream after Neovim.

## 2026-04-27 — Clipboard integrations must degrade quietly
- Decider: Anthony
- Decision: Wire zsh and tmux clipboard behavior through `dotfiles-clipboard` opportunistically, without breaking native app-local buffers or printing provider errors on unsupported systems. Zsh paste-time clipboard refresh requires all vi-mode CUTBUFFER producers to sync too, including delete/change/substitute widgets, otherwise native delete-then-put workflows degrade.
- Rationale: Clipboard unification should improve macOS and WSL workflows, but dotfiles still need to stay usable on hosts without a supported platform clipboard.
- Consequences / follow-ups: zsh caches unsupported clipboard status as a no-op for the shell session, keeps native `CUTBUFFER` behavior when copy/paste sync fails, and suppresses provider stderr. Wrapped zsh widgets now include yanks, deletes, changes, substitutes, single-character deletes, and visual selection paste. tmux copy-mode still copies selections into the tmux paste buffer and drains stdin even when no system clipboard provider is available. WSL support should be added by implementing the wrapper provider, not by adding WSL-specific logic to zsh or tmux config.

## 2026-04-27 — Keep bootstrap independent of Git runtime
- Decider: Anthony
- Decision: Remove the remaining Git runtime dependency from `bootstrap.sh`; derive managed-home paths from the checked-out `home/` filesystem tree instead of `git ls-files`.
- Rationale: After removing submodule hydration, bootstrap no longer needs Git to apply an already-present checkout or source archive. Requiring Git just to symlink local files is unnecessary.
- Consequences / follow-ups: `scripts/home_tree_manifest.sh` uses `git check-ignore` opportunistically when bootstrap runs inside a Git checkout, so `.gitignore` stays the source of truth for generated repo-local files such as `home/.vim/autoload/plug.vim.old`. If Git is unavailable or the files come from a source archive, bootstrap falls back to the checked-out `home/` filesystem tree. Local plugin clones under `~/.vim/plugged/` are outside the repo and do not need manifest pruning. `test/verify.sh` still requires Git for developer tooling that discovers tracked shell files, but it does not assert specific runtime dependencies are absent from bootstrap.

## 2026-04-27 — Scope clipboard v1 to macOS and WSL
- Decider: Anthony
- Decision: Build clipboard unification around a small repo-owned text wrapper targeting macOS and WSL/Windows first. Defer Linux desktop providers and OSC 52 until there is a local test environment or a concrete v2 need.
- Rationale: Clipboard behavior is platform- and terminal-sensitive. macOS and Ubuntu under WSL are the environments Anthony can test directly, so they are safer targets than blind support for X11, Wayland, or terminal escape-sequence clipboard paths.
- Consequences / follow-ups: `dotfiles-clipboard copy|paste|status` is the shared integration point. macOS uses `pbcopy` / `pbpaste`; WSL uses Microsoft-native `clip.exe` plus PowerShell clipboard commands. OSC 52 remains a copy-only v2 idea, especially for SSH/tmux workflows.

## 2026-04-27 — Avoid git submodules by default
- Decider: Anthony
- Decision: Keep the repo free of git submodules unless a future dependency has a clear, explicit reason to reintroduce them.
- Rationale: The remaining submodules were either obsolete (`make-chrome-app`) or better represented by a small tracked artifact (`vim-plug`). Removing submodules simplifies clone/bootstrap behavior and avoids stale pointer management.
- Consequences / follow-ups: Prefer app-native integrations, system-installed tools, small tracked snapshots, or simple repo-owned scripts before considering a submodule. The clipboard follow-up should preserve this bias and avoid submodule-backed dependencies.

## 2026-04-27 — Track vim-plug as a single loader snapshot
- Decider: Anthony
- Decision: Remove the `lib/vim-plug` submodule and track `home/.vim/autoload/plug.vim` as a normal repo file.
- Rationale: The repo needs vim-plug as a plugin manager, but not as a submodule. A single tracked loader file keeps bootstrap deterministic and simple, and `:PlugUpgrade` can update that file in place through the managed symlink so upgrades flow naturally into the repo.
- Consequences / follow-ups: The repo no longer has git submodules, and `bootstrap.sh` no longer hydrates submodules. `:PlugInstall` / `:PlugUpdate` still manage plugin clones under local `~/.vim/plugged/`; `:PlugUpgrade` may leave `plug.vim.old`, which is ignored.

## 2026-04-27 — Reify the local Vim directory
- Decider: Anthony
- Decision: Stop exposing the whole Vim runtime directory as a repo-managed symlink. Keep `~/.vim` as a real local directory and symlink only repo-owned files inside it, starting with `~/.vim/autoload/plug.vim`.
- Rationale: Plugin clones under `~/.vim/plugged/` are generated state owned by vim-plug, not dotfile source. Managing the whole `.vim` directory forced the otherwise-unused `managed/` layer and placed local plugin clones under the repo checkout.
- Consequences / follow-ups: Existing plugin clones should be moved from the old ignored `managed/vim/plugged/` location into local `~/.vim/plugged/` during the live bootstrap transition.

## 2026-04-27 — Remove make-chrome-app completely
- Decider: Anthony
- Decision: Remove the `lib/make-chrome-app` submodule and the managed `~/.local/bin/make-chrome-app` command.
- Rationale: The command had not been used in years, the upstream gist/submodule has been stale since 2015, and Chrome now has built-in desktop web-app/PWA install and management flows for the normal wrapper use case. The live command had already diverged into a tiny local fork, so the submodule no longer provided meaningful update value.
- Consequences / follow-ups: `tiff2icns` is no longer a dotfiles dependency, startup verification should not expect `make-chrome-app`, and the next submodule discussion is specifically about keeping vim-plug functionality while deciding whether `lib/vim-plug` should remain a submodule.

## 2026-04-27 — Split clipboard/register unification from core vi mode
- Decider: Anthony
- Decision: Treat the non-clipboard Bash/zsh vi-mode work as complete on `feature/vimode`, and handle clipboard/register unification on a follow-up branch.
- Rationale: Core vi mode now covers editor handoff, zsh cursor feedback, menu `hjkl`, text objects, whole-buffer `ae`, surround, and fzf keymap conflict handling. Clipboard behavior has different risk because deletes, yanks, Vim's anonymous register, zsh's `CUTBUFFER`, and the system clipboard can surprise users if synchronized too broadly.
- Consequences / follow-ups: The clipboard branch should first design the desired register model across Vim and zsh prompt yanks. Prefer linking explicit yanks to the anonymous/system clipboard path if feasible, and avoid automatically copying every delete/change unless Anthony explicitly opts in.

## 2026-04-27 — Keep fzf Alt-C out of zsh vi keymaps
- Decider: Codex (model: gpt-5.2-codex)
- Decision: After loading `fzf --zsh`, remove its `Alt-C` (`Esc-c`) binding from zsh `viins` and `vicmd` keymaps while leaving the emacs binding intact.
- Rationale: In zsh vi mode, `Esc` followed by `c` is the normal path into change operators such as `caw` and `cae`. fzf encodes `Alt-C` as the same `Esc-c` sequence, which can steal those operator flows.
- Consequences / follow-ups: `Ctrl-R` and fzf file selection remain available. Revisit a different vi-mode-safe binding for `fzf-cd-widget` only if the directory picker becomes important.

## 2026-04-27 — Extend zsh vi mode with native ZLE helpers
- Decider: Anthony
- Decision: Keep Bash vi mode conservative, and invest deeper vi-mode behavior in zsh using native ZLE helpers: cursor shape hooks for insert vs command/visual/operator-pending modes, `hjkl` in `zsh/complist` menu selection, quote/bracket text objects through `select-quoted` and `select-bracketed`, an `ae` text object for the entire edit buffer, and zsh's shipped `surround` helper with `cs`/`ds`/`ys`/visual `S` bindings.
- Rationale: zsh ships a richer ZLE widget ecosystem than Bash/Readline and can support Vim-like editing without adopting a large plugin framework. Cursor indication and menu `hjkl` improve daily feedback/navigation, while quote/bracket objects and surround align with familiar Vim operator workflows.
- Consequences / follow-ups: Clipboard integration stays a separate decision because automatic system clipboard synchronization can be surprising. `select-word-match` remains unbound for now because zsh already provides default `aw`/`iw`/`aW`/`iW`/`aa`/`ia` text objects; revisit only if custom word-style text objects become useful.

## 2026-04-26 — Use Ctrl-E for command-line editor handoff
- Decider: Anthony
- Decision: Bind `Ctrl-E` in Bash and zsh vi insert/command keymaps to open the current command line in `$EDITOR` (`edit-and-execute-command` / `vi-edit-and-execute-command` in Bash, `edit-command-line` in zsh).
- Rationale: zsh's default `Esc` then `v` enters visual mode and should remain intact; a dedicated `Ctrl-E` chord gives both shells a consistent editor handoff without overriding zsh visual mode.
- Consequences / follow-ups: Bash's native command editor runs the edited command after the editor exits. zsh's `edit-command-line` keeps zsh's native behavior. Revisit only if `Ctrl-E` becomes important for a different vi-mode workflow.

## 2026-04-26 — Preserve legacy Ctrl-[ behavior in Ghostty
- Decider: Anthony
- Decision: Configure Ghostty so `Ctrl-[` sends a literal Escape byte (`0x1b`) instead of Ghostty's CSI-u/fixterms-style modified-key sequence. Keep this in the managed Ghostty config with `keybind = ctrl+bracket_left=text:\x1b`.
- Rationale: `Ctrl-[` as Escape is core vi/readline muscle memory. Ghostty's richer modified-key encoding is useful for programs that opt into it, but zsh/ZLE treats byte sequences directly and does not provide a general CSI-u/fixterms compatibility layer. Terminal-side legacy behavior is simpler and applies consistently to shells and TUIs.
- Consequences / follow-ups: Reload or restart Ghostty after pulling this change. If a future Ghostty version adds an easy global legacy-compatibility option, prefer that over individual key remaps.

## 2026-04-26 — Timestamp shell history and keep Bash window size current
- Decider: Anthony
- Decision: Set Bash `HISTTIMEFORMAT='%F %T '` so `history` shows `YYYY-MM-DD HH:MM:SS` timestamps and newly written Bash history entries preserve timestamps. Enable zsh `EXTENDED_HISTORY` so zsh history stores timestamps and elapsed command duration, and wrap zsh `history` around `fc -l -D -t '%F %T'` so plain `history` displays the timestamp plus elapsed duration. Since zsh stores whole seconds, show `0` seconds as `<1s`, `1`-`9` seconds as `Ns`, and keep zsh's native `M:SS` display for 10 seconds and above. Also set Bash `checkwinsize` so Readline gets fresh terminal dimensions after resizes. Keep `HISTCONTROL` unset, including no `ignoredups`.
- Rationale: Timestamped history is useful for recall and auditing, and the chosen Bash display format is readable without being noisy. Zsh needs `EXTENDED_HISTORY` for durable timestamp storage rather than a Bash-style display variable. `checkwinsize` is a low-risk Bash ergonomics fix for terminal resizing, while `HISTCONTROL` changes what gets saved and should remain explicit rather than surprising.
- Consequences / follow-ups: Existing history entries without timestamps will not gain accurate old timestamps. Zsh history display uses `fc` output under the hood, so unusual `history` flags should be checked against zsh `fc` behavior. Do not add prompt-time, immediate-write, or cross-session history sync (`history -n`/`history -a`, `INC_APPEND_HISTORY`, `INC_APPEND_HISTORY_TIME`, or `SHARE_HISTORY`) because Anthony relies on stable prompt history event numbers for the `!num` workflow. Do not add secret-suppression filters as part of this policy.

## 2026-04-26 — Hide the working-memory directory
- Decider: Anthony
- Decision: Rename the committed working-memory directory from `context/` to `.context/` in the live repo and from `code_template/context/` to `code_template/.context/` in the repo template. Update AGENTS, README, settings, and template references to point at the hidden path.
- Rationale: `.context` better communicates that the directory is supporting agent/project memory rather than part of the normal user-facing source tree, while keeping it committed and discoverable to agents that know the project contract.
- Consequences / follow-ups: Future references should use `/.context/...` for repo-root paths and `.context/...` for relative paths. Continue treating `.context` as committed working memory, not as canonical product documentation.

## 2026-04-26 — Prefer system completion sources across Bash and zsh
- Decider: Anthony
- Decision: Keep command completions system-first instead of vendoring Oh My Bash completion files. Bash treats an already-loaded `bash-completion` as authoritative, otherwise tries Homebrew formula prefixes, optional `pkg-config` metadata, and common system framework paths; it does not broadly source snippets without a framework. Active-Git completion is a fallback only when `complete -p git` reports no existing Git completion. Zsh prepends Homebrew zsh site-functions before `compinit`, adds active-Git completion only when no `_git` is already visible in `fpath`, and uses command-generated zsh completions only when no native command completion is registered.
- Rationale: Completion scripts need to match the installed command version, but many Bash snippets in Homebrew's `etc/bash_completion.d` assume framework helpers such as `_get_comp_words_by_ref` or `_filedir`. The framework owns broad snippet loading; direct fallback sourcing would be brittle. Runtime capability checks protect external integration points without reintroducing stale file-level `DOTFILES_*_LOADED` guards.
- Consequences / follow-ups: Keep Git's prompt helper discovery separate because Bash prompt support needs `__git_ps1`, which `bash-completion` does not provide. `gh` and `kubectl` have explicit command-generated fallbacks for non-package-manager installs. Add future completions by extending the system/package-manager loader or narrow generated-completion list, guarded by shell-observed capability checks such as `complete -p command` or zsh `_comps[command]`.

## 2026-04-26 — Centralize dev-tool shell discovery separately from deployment
- Decider: Anthony
- Decision: Keep deployment discovery in the POSIX `scripts/home_tree_manifest.sh`, and centralize repo-local shell tooling discovery/dialect classification in the Bash-only `scripts/shell_files.bash`. Use that helper from verify, ShellCheck, and shfmt wrappers.
- Rationale: Bootstrap needs a small POSIX manifest helper because deployment runs under `sh`; developer tooling already depends on Bash and needs richer shell dialect classification across `sh`, Bash, and zsh files. Sharing only the dev-tool discovery layer removes duplication without coupling bootstrap to Bash.
- Consequences / follow-ups: `scripts/shfmt-dotfiles.bash` uses `shfmt -i 2 -ci -bn` and is part of the `test/verify.sh` full gate through `--all --check`. Keep tool-specific policy such as ShellCheck suppressions and zsh skips in the wrappers.

## 2026-04-26 — Require ShellCheck in verification
- Decider: Anthony
- Decision: Treat ShellCheck as a required development dependency for `test/verify.sh`. Keep `bootstrap.sh` free of the ShellCheck dependency, and route static analysis through `scripts/shellcheck-dotfiles.bash --all` so editor and full-suite linting share one repo-aware shell dialect policy.
- Rationale: ShellCheck is a useful static analyzer for real shell bugs, especially in a repo that intentionally mixes POSIX `sh`, Bash, and zsh. Making it part of the full gate catches quoting, portability, arithmetic, and dialect mistakes before runtime tests.
- Consequences / follow-ups: `scripts/shellcheck-dotfiles.bash` owns path-specific suppressions for sourced fragments and zsh skips. Add real fixes when ShellCheck finds genuine issues; keep false-positive policy centralized rather than adding inline editor hints to managed shell files.

## 2026-04-25 — Prefer explicit shell data flow
- Decider: Anthony
- Decision: In shell startup code, prefer explicit call-site data flow over passing string-encoded function names. When a helper consumes generated candidate lines, make the helper read stdin and feed it with process substitution or redirection at the call site when the current shell supports it.
- Rationale: Bash and zsh allow indirect function calls, but passing function names as strings obscures where values are produced and consumed. Explicit redirection keeps the stream visible at the call site and avoids unnecessary dispatch branches.
- Consequences / follow-ups: Use process substitution only in shell-specific files that support it (`bash`, `zsh`). Keep shared POSIX files portable and document any exception where shell semantics force a different shape.

## 2026-04-25 — Keep tests under `test/`
- Decider: Anthony
- Decision: Move the verification entrypoint from `scripts/verify.sh` to `test/verify.sh`, with multi-line shell fixtures under `test/fixtures/verify/`. Keep `scripts/` for bootstrap-support helpers and small non-test utilities.
- Rationale: Verification had grown into a fixture-based test harness and was starting to dominate `scripts/`, making the directory name misleading. A top-level `test/` tree is a more idiomatic place for the harness and fixtures while preserving `scripts/` for runtime/support utilities.
- Consequences / follow-ups: Use `test/verify.sh` as the full gate. `scripts/home_tree_manifest.sh` remains under `scripts/` because bootstrap uses it directly, not only tests.

## 2026-04-25 — Remove the vendored Git helper submodule
- Decider: Anthony
- Decision: Drop the `lib/git` submodule and the managed Git helper symlinks under `home/.config/{bash,zsh}/`. Git prompt helper discovery lives in shared POSIX functions, while Git bash-completion candidate discovery lives under `home/.config/bash/` and is explicitly consumed by zsh because Git's upstream zsh wrapper depends on a matching bash completion script.
- Rationale: Git completions and prompt helpers should match the selected `git` binary on PATH. Keeping a separate pinned Git checkout made completion behavior drift from the installed command and added a large submodule for files that macOS/Homebrew Git already ship.
- Consequences / follow-ups: Zsh prefers any native `_git` already visible in `fpath`; only when that capability is missing does it create an XDG-cache `_git` symlink to the active system file and point that fallback wrapper at the bash-owned completion candidate. Machines without packaged Git completion helpers will get reduced Git completion/prompt behavior until Git's helpers are installed. Continue the broader submodule/CLI audit separately.

## 2026-04-24 — Append Bash history without live cross-session merging
- Decider: Anthony
- Decision: Enable `shopt -s histappend cmdhist lithist` in the Bash interactive layer. Do not add automatic `history -n` / `history -a` prompt syncing as part of this change.
- Rationale: `histappend` prevents concurrent Bash sessions from clobbering each other's history files at shell exit, while avoiding live cross-session history imports that would move event numbers under a prompt-number workflow. `cmdhist` and `lithist` keep multiline commands grouped and readable in history.
- Consequences / follow-ups: Bash history is still session-local until shell exit or manual `history` operations; future history work can separately consider `HISTTIMEFORMAT`, `histverify`, conservative `HISTCONTROL`, or explicit history sync tradeoffs.

## 2026-04-24 — Replace chezmoi with a repo-native home tree
- Decider: Anthony
- Decision: Remove chezmoi entirely. Keep `home/` as a literal `$HOME` mirror, use the `home/` tree itself as the deployment manifest, and let `bootstrap.sh` compute managed directories/leaves via `scripts/home_tree_manifest.sh`. Use real symlink nodes in the repo where needed.
- Rationale: The repo already wanted live-update symlink semantics, and chezmoi’s source-state encoding (`dot_`, `private_`, `symlink_*.tmpl`, `.chezmoiroot`) had become more indirection than value. A literal home tree is easier to read, easier to reason about, and keeps the repo layout aligned with the deployed filesystem shape.
- Consequences / follow-ups: `bootstrap.sh` keeps a managed-path state file under `~/.local/state/dotfiles/managed-paths`, and uses that to clean up stale targets after deployment-shape changes. As of 2026-04-27, bootstrap no longer requires Git at runtime. `test/verify.sh` validates the repo-native managed-path list instead of chezmoi state. Prefer real symlink nodes over reintroducing template-based target indirection unless a concrete new need appears.

## 2026-04-23 — Default shell internals to XDG config/state paths
- Decider: Anthony
- Decision: Keep the standard shell entrypoints in `$HOME` (`.profile`, `.shrc`, `.bashrc`, `.zshrc`, etc.) for compatibility, but default the internal shell/runtime config to `XDG_CONFIG_HOME` and shell history/state to `XDG_STATE_HOME`. Concretely, `home/.config/shell/paths.sh` now exports default XDG base-dir variables and derives unexported internal `dotfiles_*` path variables, managed bash/zsh config is sourced through that internal path layer, and bash/zsh history files live under `~/.local/state/{bash,zsh}/history` unless overridden.
- Rationale: The home-directory entrypoints are still the right compatibility boundary for login and interactive shells, but the internals behind them do not need to keep hardcoding `~/.config` or state files like shell history in `$HOME`. Separating exported `XDG_*` vars from the shell's internal resolved `dotfiles_*` layer keeps path policy centralized and gives future flexibility without leaking extra globals to child processes.
- Consequences / follow-ups: Continue treating `$HOME` shell wrappers as compatibility shims into the real managed config under `XDG_CONFIG_HOME`. Prefer `XDG_CACHE_HOME` / `XDG_STATE_HOME` for shell-generated runtime artifacts such as completion caches and history files, but route shell-internal path lookups through `dotfiles_*` vars rather than sprinkling raw XDG fallback logic everywhere. `test/verify.sh` now asserts the default XDG env vars, internal path vars, and history locations in both bash and zsh startups.

## 2026-04-23 — Keep interactive shell internals native to bash vs zsh
- Decider: Anthony
- Decision: Share portable shell policy and helpers through `home/.config/shell/`, but keep prompt/completion/hook internals native to each interactive shell. Concretely, continue to share PATH/editor/pager defaults, aliases, and portable helper functions across shells, while keeping `PROMPT_COMMAND`/`__git_ps1` logic in bash and `precmd`/`compinit`/native prompt escapes in zsh.
- Rationale: The useful overlap between bash and zsh is at the policy/helper level, not at the prompt/completion mechanism level. Forcing a shared abstraction over shell-specific hooks and prompt semantics would add indirection without buying much reuse, and would make the zsh setup feel more like “bash compatibility mode” than a first-class zsh configuration.
- Consequences / follow-ups: Treat the current shared `shell/` layer as the portability boundary. Prefer zsh-native solutions for future interactive work rather than trying to route new features through shared bash/zsh helper shims. Bash can remain stable/legacy unless a change clearly benefits both shells.

## 2026-04-22 — Split shell language roles by use case
- Decider: Anthony
- Decision: Use POSIX `sh` for deployment-critical bootstrap paths, `bash` for repo-local dev automation, and `zsh` as the interactive shell that receives ongoing UX investment. Concretely, keep `bootstrap.sh` POSIX `sh`, keep `test/verify.sh` in bash, and continue the prompt/completion migration work in zsh.
- Rationale: The three use cases have different priorities. Deployment should optimize for portability, dev automation should optimize for boring/predictable command orchestration, and interactive shell config should optimize for completion, prompt, and daily ergonomics. Treating zsh as a universal scripting upgrade would not buy much for `verify.sh`, which is mostly assertions and subprocess calls.
- Consequences / follow-ups: Shared runtime shell files under `home/.config/shell/` should stay POSIX-compatible unless there is a strong reason otherwise. New repo-local automation can default to bash unless portability pressure suggests `sh` or complexity suggests a higher-level language. Continue the next shell work in zsh without feeling pressure to port `verify.sh`.

## 2026-04-22 — Preserve live-update semantics for deployed dotfiles
- Decider: Anthony
- Decision: Treat bootstrap as initial deployment/hydration, not as the normal update path. `git pull` on the repo should live-update deployed config unless the deployment shape itself changes (new targets, removed targets, target type changes, etc.).
- Rationale: This repo is intended to behave like a classic symlink-managed dotfiles checkout: the repo remains the obvious source of truth, and routine config updates should flow through by virtue of the filesystem links rather than requiring a separate apply step.
- Consequences / follow-ups: Prefer symlinks into the repo, including real symlink nodes in `home/` or `managed/` for vendored assets and whole-directory targets, over copied/rendered runtime files. The shell layout refactor was updated to follow this rule; keep applying it as more zsh work lands.

## 2026-04-22 — Split shell startup into POSIX baseline plus bash/zsh layers
- Decider: Anthony
- Decision: Replace the old bash-only repo-root shell bootstrap with a home-managed startup stack: `.profile` / `.shrc` as the POSIX baseline, `.bash_profile` / `.bashrc` for bash, and `.zprofile` / `.zshrc` for zsh. Move shared runtime logic under `home/.config/shell/`, bash-specific logic under `home/.config/bash/`, zsh-specific logic under `home/.config/zsh/`, and install user CLI tools from `home/.local/bin/` to `~/.local/bin/`.
- Rationale: The repo should stay usable over SSH on arbitrary machines, including cases where only a subset of files are manually symlinked and chezmoi is not installed. A POSIX baseline keeps common behavior portable across `sh`, `bash`, and `zsh`, while shell-specific layers allow the zsh migration to move forward without breaking bash.
- Consequences / follow-ups: Runtime shell startup should no longer depend on resolving the repo root dynamically inside the shell. The deployed shell stack is symlink-backed, and vendored Git prompt/completion helpers are exposed through real symlink nodes into `lib/git/`, so `git pull` and submodule updates propagate immediately. Manual symlink setups still degrade gracefully to system helpers or a minimal branch-only prompt. Next work is the actual zsh prompt/completion port on top of this shared layout.

## 2026-04-21 — Manage Ghostty Solarized Dark in the managed home tree
- Decider: Anthony
- Decision: Ship **`home/.config/ghostty/config`** so bootstrap symlinks **`~/.config/ghostty/config`**. Use canonical Solarized Dark hex (upstream Xresources ANSI mapping), **`alpha-blending = native`** (Display P3 compositing on macOS per Ghostty docs), **`palette-generate = true`** so indices 16–255 derive from the base-16 Solarized palette, and **`macos-titlebar-style = transparent`** so title chrome matches base03. Extend **`test/verify.sh`** with managed paths and a temp-home symlink assertion for Ghostty.
- Rationale: No need to restore the **altercation/solarized** submodule for terminal chrome; Ghostty’s own options cover wide-gamut blending and a cohesive 256-color ramp. Document **`linear-corrected`** in-config as an optional tweak if fringe artifacts appear.
- Consequences / follow-ups: Reload Ghostty after apply (**Cmd+Shift+,**). Linux gets **`native`** as sRGB per Ghostty (still explicit and consistent).

## 2026-04-21 — Remove unused `settings/solarized` submodule
- Decider: Anthony
- Decision: Delete the **`settings/solarized`** git submodule (full **altercation/solarized** checkout). Replace with documentation: **`settings/README.md`** and **`.context/knowledge/solarized.md`** pointing to upstream for Terminal/iTerm/Ghostty/Xresources needs. **Vim** remains **`lifepillar/vim-solarized8`** via vim-plug; **tmux** styling stays in **`home/.tmux.conf`**.
- Rationale: Nothing in bootstrap or scripts referenced the submodule (~19MB, 600+ files). It duplicated the old Vim bundle under `vim-colors-solarized/` and confused “vendored Solarized” vs the active vim-plug theme. Clone upstream on demand when configuring non-Vim apps.
- Consequences / follow-ups: `git clone --recurse-submodules` no longer pulls Solarized; **AGENTS.md** and `.context/` updated.

## 2026-04-21 — Use Solarized 8 for true-color terminal Vim
- Decider: Anthony
- Decision: Replace **altercation/vim-colors-solarized** with **lifepillar/vim-solarized8**; load **`colorscheme solarized8`**. Enable **`termguicolors`** when `has('termguicolors')`, and set **`t_8f` / `t_8b`** per `:help xterm-true-color`. Remove the old **`g:solarized_termcolors`** hack and the **`ColorColumn`** `ctermfg=Red` override (the scheme styles `ColorColumn`). In **tmux**, set **`terminal-features ',*:RGB'`** so nested Vim receives true color.
- Rationale: Original Solarized does not define `guifg`/`guibg` for terminal Vim, so **`termguicolors`** cannot apply canonical hex colors; Solarized 8 is maintained for true-color and 256/16 fallbacks.
- Consequences / follow-ups: Run **`:PlugInstall`** to swap plugins; **reload tmux** after pulling `dot_tmux.conf`. On hosts where true color fails, **`set notermguicolors`** then **`:colorscheme solarized8`** (documented in README and `.context/knowledge/vim.md`).

## 2026-04-21 — Use vim-plug with tracked submodule loader
- Decider: Anthony
- Decision: Manage plugins with **vim-plug**: add `lib/vim-plug` as a **git submodule**, symlink `managed/vim/autoload/plug.vim` → `../../../lib/vim-plug/plug.vim`, and use `call plug#begin('~/.vim/plugged')` in `home/.vimrc`. Ignore `~/.vim/plugged/` in git. Remove the **Vundle** submodule (`managed/vim/bundle/vundle`). Apply the previously chosen **upgraded GitHub repos** (ctrlpvim, easymotion, vim-mundo, preservim NERD*) and **Mundo** mappings (`g:mundo_*`, `:MundoToggle`).
- Rationale: Bare `pack/` + manual or submodule-per-plugin was heavier than wanted; vim-plug stays maintained, keeps SSH story to “submodules + bootstrap + `:PlugInstall`,” and avoids curling `plug.vim` on each machine when the submodule is present.
- Alternatives considered: Only native packages; minpac—see prior discussion; deferred in favor of vim-plug ergonomics.
- Consequences / follow-ups: Old ignored clones under `~/.vim/bundle/` can be deleted locally; `test/verify.sh` and README must reference `PlugInstall` not `BundleInstall`. **Recorded 2026-04-21:** `test/verify.sh` run clean post-migration; README step documents `rm -rf ~/.vim/bundle` for leftover Vundle-era trees.

## 2026-04-20 — Abandon Vundle for Vim native packages; trim and upgrade plugins
- Decider: Anthony
- Decision:
  - **Drop Vundle** entirely (no migration to VundleVim). **Update 2026-04-21:** adopt **vim-plug** for layout instead of bare native `pack/` (see newer decision).
  - **Remove** all language-specific bundles: Haml, LESS, CoffeeScript (+ coffee-check), Clojure (fireplace + vim-clojure-static), and **vim-capslock**. Drop **matchit.zip** if stock Vim’s matching is sufficient after testing.
  - **Carry forward** (non-exhaustive): Solarized, vim-git, tpope plugins except capslock, textobj user/entire, fugitive, tabular, etc., declared in `plug#begin`/`plug#end`.
  - **Upgrades**: fuzzy finder → **ctrlpvim/ctrlp.vim** (not fzf.vim for now—fuller in-editor UX, no fzf binary); motion → **easymotion/vim-easymotion**; undo tree → **simnalamburt/vim-mundo**; file tree + comments → **preservim/nerdtree** and **preservim/nerdcommenter** (same plugins, current home org—not a different product).
  - **Config hygiene**: After removing plugins, delete or rewrite every `.vimrc` mapping, `autocmd`, `g:` variable, and statusline segment that referenced a removed plugin (including Less compile maps if LESS plugin goes).
- Rationale: Native packages avoid another manager abstraction; ctrlpvim matches CtrlP muscle memory and stays pure VimScript for SSH; fzf remains a great CLI tool but vim integration is intentionally thin; preservim forks are the maintained NERD* line; vim-mundo is the maintained Gundo descendant (last upstream activity newer than sjl/gundo.vim).
- Alternatives considered: **fzf.vim**—defer; **vim-plug**—optional later if native layout feels too manual; **dirvish/oil**—different UX than NERDTree; keep NERDTree via preservim.
- Consequences / follow-ups: **Done 2026-04-21** via vim-plug (`.context/decisions.md` entry); remove legacy `bundle/` dirs locally if present.

## 2026-04-20 — Prefer vanilla Vim for portable dotfiles; defer Neovim
- Decider: Anthony
- Decision: Treat **Vim** (not Neovim) as the supported editor in this repo for now, so a minimal setup over SSH—clone or unpack dotfiles, run bootstrap, open `vim`—works without extra runtime dependencies. Consider **Neovim** as a deliberate next step later, not part of the current migration.
- Rationale: Remote servers often have Vim or can install it easily; Neovim adds another version matrix and plugin/runtime expectations. Aligning the Vundle replacement and plugin refresh with stock Vim keeps the “ssh in and be productive” story simple.
- Alternatives considered: Standardize on Neovim now for better LSP and plugin ecosystem; deferred until local/SSH workflows are stable on Vim.
- Consequences / follow-ups: Plugin manager and plugin choices should stay compatible with Vim 8+ where possible; document any optional Neovim path in `/.context` when revisited.

## 2026-04-20 — Use broad managed Codex allow rules for git and npm
- Decider: Anthony
- Decision: Keep the managed `~/.codex/rules/global.rules` baseline intentionally broad with `prefix_rule(pattern=["git"], decision="allow")` and `prefix_rule(pattern=["npm"], decision="allow")`, while leaving the local generated `default.rules` empty until new machine-local approvals are learned.
- Rationale: Git and npm are comfortable global allow surfaces for this workflow, and the broad prefixes are simpler to maintain than curating many tool-specific subcommands.
- Alternatives considered: Keep the seeded list of specific command approvals; rejected because it was noisier and offered no practical benefit once broad `git` and `npm` access were deemed acceptable.
- Consequences / follow-ups: Restart Codex after the rule-file change and add any future non-portable approvals back to the local `default.rules` only if they should stay machine-specific.

## 2026-04-20 — Prefer live repo state over stale `/.context` snapshots
- Decider: Anthony
- Decision: When `/.context` conflicts with live repo evidence such as `git status`, current files, recent commits, or the working tree, agents should trust the live state and reconcile `/.context` before answering status or next-step questions.
- Rationale: `/.context` is durable working memory, but it can naturally lag behind the actual repository state and should not override direct evidence.
- Alternatives considered: Treat `/.context` as authoritative until manually updated; rejected because it can leave agents one step behind after commits or other state changes.
- Consequences / follow-ups: Mirror the guidance in both the live repo and `code_template` `AGENTS.md` files so future repos inherit the same precedence rule.

## 2026-04-20 — Keep generated Codex rules separate from curated rules
- Decider: Anthony
- Decision: Do not git-manage `~/.codex/rules/default.rules`; instead, plan to add a curated managed rules file such as `home/.codex/rules/global.rules`.
- Rationale: Codex writes accepted/generated approval rules to `default.rules`, so that file should remain local and mutable. Portable rules that should apply across machines belong in a separate stable `.rules` file.
- Alternatives considered: Track `default.rules` directly; rejected because Codex naturally mutates it. Add a merge script immediately; deferred because Codex natively scans multiple `.rules` files under `rules/`.
- Consequences / follow-ups: Restart Codex after rule-file changes and test important commands with `codex execpolicy check --pretty --rules ... -- <command>`.

## 2026-04-20 — Use chezmoi symlink mode for dotfiles (superseded 2026-04-24)
- Decider: Anthony
- Decision: Replace the Puppet bootstrap with chezmoi, keep `home/` as the source-state root via `.chezmoiroot`, and use `mode = "symlink"` so managed `$HOME` files point back into the git checkout.
- Rationale: The repo should keep dotfiles as live tracked files so drift is visible in git instead of hidden in copied snapshots.
- Alternatives considered: Use copied-file chezmoi mode; rejected because it would allow `$HOME` files to diverge from the source checkout unless changes are explicitly re-added.
- Consequences / follow-ups: Keep selective macOS settings as explicit scripts unless a setting is deliberately moved to a platform-gated `run_once_`/`run_onchange_` script; Vim plugin management is **vim-plug** (2026-04-21); still revisit non-portable color configuration when ready.

## 2026-04-13 — Strengthen global notebook and commit-message rules
- Decider: Anthony
- Decision: Update `home/.codex/AGENTS.md` to require notebook/status updates after every substantial turn, generalize the knowledge lookup trigger, and require a proposed commit message for the full current uncommitted diff at the end of every turn.
- Rationale: These behaviors are important across projects and should not rely only on repo-local instructions.
- Alternatives considered: Keep the rules project-specific; rejected because the desired behavior is cross-project and should be enforced globally.
- Consequences / follow-ups: Agents should keep project notebooks current proactively and always propose a commit message that covers the full dirty tree unless explicitly scoped narrower.

## 2026-04-13 — Lighten `code_template/docs` scaffolding
- Decider: Anthony
- Decision: Remove the seeded `/code_template/docs` topic files and keep only a lightweight landing page plus flexible guidance that lets agents shape the docs structure per repo.
- Rationale: The fixed scaffold was over-prescriptive and pushed agents toward artificial categories instead of documenting the repo in the most effective retrieval shape.
- Alternatives considered: Keep the starter topic set and ask agents to replace it; rejected because the scaffold itself was adding noise and biasing structure too early.
- Consequences / follow-ups: Template adopters should create only the topic files their repo needs and keep `/docs/README.md` as a lightweight routing map.

## 2026-04-13 — Fold repo `.context/reference` into `.context/knowledge`
- Decider: Anthony
- Decision: Remove the live repo `.context/reference/` split and keep reusable repo, vendor, and workflow notes in `.context/knowledge/` instead.
- Rationale: A single retrieval path is easier for agents to follow and matches the streamlined context model used elsewhere in the repo.
- Alternatives considered: Keep a separate `reference/` library; rejected because the split added indirection without enough value in practice.
- Consequences / follow-ups: Update AGENTS and `.context` guidance to route future reusable notes into `knowledge/` topic files and remove the placeholder `reference/` files.

## 2026-04-13 — Merge repo `user_shared` into `scratch`
- Decider: Anthony
- Decision: Removed `.context/user_shared/` and redefined `.context/scratch/` as the single git-tracked staging area for collaborative drafts, experiments, pre-repo code, and other content that does not yet have a stable home in the repo.
- Rationale: One staging area is easier for agents to use consistently than trying to distinguish between collaborative drafts and scratch artifacts.
- Alternatives considered: Keep `user_shared` and `scratch` separate; rejected because the distinction was not driving useful behavior.
- Consequences / follow-ups: Namespace `scratch/` by task or work thread and promote or delete contents once they have a proper home.

## 2026-04-13 — Keep decision logs in reverse chronological order
- Decider: Anthony
- Decision: Keep `.context/decisions.md` and `code_template/.context/decisions.md` ordered newest first.
- Rationale: Reverse chronological order optimizes retrieval by putting the most relevant, recent decisions at the top.
- Alternatives considered: Keep oldest-first ordering; rejected because it makes current policy harder to find quickly.
- Consequences / follow-ups: Add new decisions at the top of the file and update templates to reinforce the convention.

## 2026-04-13 — Merge template `user_shared` into `scratch`
- Decider: Anthony
- Decision: Removed `code_template/.context/user_shared/` and redefined `code_template/.context/scratch/` as the single git-tracked staging area for collaborative drafts, experiments, and other content that does not yet have a stable home in the repo.
- Rationale: The separate folders were not pulling their weight, while one shared staging area is easier for agents to understand and use consistently.
- Alternatives considered: Keep `user_shared` and `scratch` separate; rejected because the distinction was not producing useful agent behavior.
- Consequences / follow-ups: Template adopters should namespace `scratch/` by task or work thread and promote or delete contents once they have a proper home.

## 2026-04-13 — Make documentation upkeep mandatory and restore template `.context/knowledge`
- Decider: Anthony
- Decision: Updated `code_template/AGENTS.md` to require proactive documentation updates after every substantial turn, and restored `code_template/.context/knowledge/` as a place for agent-oriented supplemental knowledge that does not belong in canonical repo docs.
- Rationale: Agents were not maintaining docs reliably enough, and some reusable agent knowledge needs a home outside `/docs/`.
- Alternatives considered: Keep all durable writing in `/docs/` only; rejected because agent workflows, sandbox notes, and certain third-party learnings are useful but not appropriate as main repo docs.
- Consequences / follow-ups: Template adopters should treat `/docs/` as canonical repo truth and `/.context/knowledge/` as supplemental agent knowledge.

## 2026-04-13 — Recenter `code_template` around `/docs` as canonical documentation
- Decider: Anthony
- Decision: Reworked `code_template` so `AGENTS.md` is a routing layer, `/docs` is the canonical documentation system, and `/.context` is limited to live state, drafts, and scratch artifacts.
- Rationale: Optimize retrieval for agents and avoid splitting durable documentation across `knowledge/`, `reference/`, and context files.
- Alternatives considered: Keep the old `knowledge/` and `reference/` split; rejected because it added indirection without improving retrieval.
- Consequences / follow-ups: Template adopters should maintain `/docs/README.md` plus topic files and keep `/.context` focused on working memory.

## 2026-02-04 — Add no-tech-debt rule to global AGENTS
- Decider: Anthony
- Decision: Added a global rule to avoid long-lived compatibility shims; if temporary artifacts are required, record removal and remove them in the next deploy.
- Rationale: Keep changes clean and prevent temporary workarounds from becoming permanent debt.
- Alternatives considered: Keep guidance implicit; rejected to make the expectation explicit.
- Consequences / follow-ups: None.

## 2026-01-20 — Migrate knowledge to `/.context/knowledge/` with index
- Decider: Anthony
- Decision: Replace `.context/knowledge.md` with a `.context/knowledge/` directory and an `index.md` that links to topic files.
- Rationale: Keep the knowledge base scalable without bloating a single file or the context window.
- Alternatives considered: Keep a single `knowledge.md` and rely on `/.context/reference/`; rejected due to size and discoverability concerns.
- Consequences / follow-ups: Update references from `knowledge.md` to `knowledge/index.md` and keep topic files concise.

## 2026-01-20 — Add `/.context/scratch` for transient session artifacts
- Decider: Anthony
- Decision: Create `/.context/scratch` for short-lived debugging artifacts, namespaced by task ID and cleaned up aggressively.
- Rationale: Preserve temporary work without polluting durable knowledge or source code.
- Alternatives considered: Use `/tmp` only; rejected because it hides useful session context that may need short-term retention.
- Consequences / follow-ups: Document the scratch workflow in AGENTS and `/.context` README.

## 2026-01-20 — Add `/.context/user_shared` for collaborative drafts and pre-repo code
- Decider: Anthony
- Decision: Create `/.context/user_shared` with guidance for shared docs and early code not yet ready for the repo.
- Rationale: Provide a structured place for collaboration separate from production code and context summaries.
- Alternatives considered: Use `/.context/knowledge/` only; rejected because drafts/prototypes can overwhelm curated notes.
- Consequences / follow-ups: Ensure AGENTS and `.context` docs reference the folder and keep it organized.

## 2026-01-20 — Use ULIDs for task IDs in `tasks.md`
- Decider: Anthony
- Decision: Task entries use ULID identifiers paired with short human-readable titles.
- Rationale: Reduce ID collisions in agent-managed task lists while keeping entries scannable.
- Alternatives considered: Sequential IDs; rejected due to merge conflict risk in multi-agent edits.
- Consequences / follow-ups: Update task templates and existing task entries to the ULID format.

## 2026-01-20 — Recommend commit messages at logical stopping points
- Decider: Anthony
- Decision: Added a workflow rule to pause and propose a git commit with a present-tense title, blank line, and bullet list of changes, per user request.
- Rationale: User preference for consistent, high-quality commit message recommendations.
- Alternatives considered: Keep commit guidance implicit; rejected to make the behavior explicit and repeatable.
- Consequences / follow-ups: Apply this recommendation flow after coherent units of work.

## 2026-01-18 — Populate repo AGENTS.md and /.context with repo-specific details
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Replaced placeholders in root `AGENTS.md` and `/.context` with dot_files-specific guidance and current state; removed the unused reference template.
- Rationale: Move docs from scaffold to production-grade, actionable guidance.
- Alternatives considered: Leave templates for future manual fill-in; rejected to avoid stale placeholders.
- Consequences / follow-ups: Update entries as the repo evolves.

## 2026-01-18 — Treat template /.context files as baseline in `code_template/AGENTS.md`
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Use "seeded structure" wording in the template to reflect that `/.context` files are already present.
- Rationale: The template ships with a prebuilt `/.context`, so it should be treated as the default baseline.
- Alternatives considered: Keep "recommended" wording; rejected because it implies the structure is optional.
- Consequences / follow-ups: None.

## 2026-01-18 — Remove template/seeding phrasing from /.context base section
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Updated `code_template/AGENTS.md` to describe `/.context` files as the day-1 base state without referencing templates or seeding.
- Rationale: The document should stand alone as a living guide and describe the current baseline, not its origin.
- Alternatives considered: Keep "seeded structure" wording; rejected to avoid provenance language in day-1 guidance.
- Consequences / follow-ups: None.
