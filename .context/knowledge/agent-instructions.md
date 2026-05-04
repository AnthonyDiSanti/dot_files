# Agent instructions

- Source: `agents/skills/`, `agents/prompts/`, `agents/harnesses/`,
  `agents/scripts/update-skill.bash`, `agents/scripts/update-prompt.bash`,
  `agents/scripts/update-all.bash`, `agents/scripts/symlink-skill.bash`,
  `agents/scripts/symlink-all.bash`, `agents/official-docs/`,
  `agents/models/`, `home/.agents/skills/`, `home/.claude/skills/`,
  `home/.cursor/skills/`
- Why it matters: repo-managed skills and prompt guidance shape future agent behavior across Codex and other harnesses.
- When to consult: creating or tuning skills, updating AGENTS instructions, comparing model-specific prompt guidance, or debugging why an agent behaves differently after a model upgrade.
- Key points:
  - Skill packages keep canonical source as directories containing `SKILL.md`
    anywhere under `agents/skills/src/`, runtime artifacts under
    `agents/skills/artifacts/<harness>/<model>/`, and maintenance stamps under
    `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/`.
  - Each skill source contains `SKILL.md` plus optional `model-notes/`,
    optional `harness-notes/`, and optional `evals/`. `SKILL.md` frontmatter is
    the canonical source of skill identity. The skill directory name is the
    runtime skill id and must be globally unique across the source tree.
  - Source skill frontmatter stays harness-neutral and limited to canonical
    identity such as `name` and `description`; runtime interface metadata such
    as Codex `agents/openai.yaml` belongs in artifacts.
  - Harness deployment paths live under `home/` as symlink nodes pointing at
    runtime artifacts shaped as
    `agents/skills/artifacts/<harness>/<model>/skills/<skill>/`. Codex deploys
    `home/.agents/skills/<skill>`, Claude Code deploys
    `home/.claude/skills/<skill>`, and Cursor Agent deploys
    `home/.cursor/skills/<skill>`.
  - Claude Code is currently pinned to Opus 4.6 for the deployed home symlink,
    while Opus 4.7 remains available as a non-deployed runtime artifact.
  - Cursor Agent currently deploys the Composer 2 Fast artifact and leaves the
    full stateful Cursor CLI config local. This repo sets `XDG_CONFIG_HOME`, so
    the live macOS config path is `~/.config/cursor/cli-config.json`; official
    docs otherwise default to `~/.cursor/cli-config.json`.
  - Authoritative cached vendor docs live under `agents/official-docs/` and
    should not be hand-edited. Larger official source/example trees live there
    as optional pinned submodules for Codex source, Anthropic skills, Cursor
    plugins, and Gemini CLI. Repo-authored generic model guidance lives under
    `agents/models/` and should cite official docs while preserving concrete
    adapted examples that apply across skills. The vendor cache is protected by
    its own `.markdownlint.json` with all rules disabled so lint fixes do not
    corrupt copied docs.
  - Skill-specific model notes live beside the source skill under
    `model-notes/<model>.md`. Create them only for skill/model deltas that are
    not already covered by the source skill and generic model guide.
  - Skill-specific harness notes live beside the source skill under
    `harness-notes/<harness>.md`. Use them for per-skill adaptations to a
    harness's runtime shape, metadata, or activation behavior; keep global
    harness discovery/config/runner facts in `agents/harnesses/<harness>.md`.
    Omit harness notes when there is no real per-skill harness delta.
  - Updater prompt source lives as directories containing `PROMPT.md` anywhere
    under `agents/prompts/src/`; prompt artifacts live at
    `agents/prompts/harnesses/<harness>/<prompt>.md`, with stamps under
    `agents/prompts/.update-stamps/<harness>/<prompt>/inputs.sha256`.
    Harness-specific runner prose belongs in prompt artifacts or
    `harness-notes/<harness>.md`, not in harness YAML `runner_args`. Prompt
    harness notes are optional and should exist only for real prompt/harness
    deltas.
    `update-prompt.bash` includes matching prompt harness notes in rendered
    maintenance prompts and prompt artifact digests.
  - The harness config schema lives beside harness configs at
    `agents/harnesses/harness.schema.json`.
  - `agents/scripts/update-skill.bash` renders or runs a harness update prompt
    for one source skill across selected harness/model artifacts. The skill
    argument can be a globally unique skill directory name or a path relative to
    `agents/skills/src/`. The runner records
    `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/inputs.sha256`.
    Before running a skill update, it refreshes that harness's
    `update-skill-artifact` prompt artifact if stale and includes that prompt
    artifact plus any matching `harness-notes/<harness>.md` in the skill digest.
  - `agents/scripts/update-prompt.bash` renders or runs a harness prompt-update
    prompt for one source prompt across selected harness prompt artifacts. The
    prompt argument can be a globally unique prompt directory name or a path
    relative to `agents/prompts/src/`.
  - Model guides resolve directly as `agents/models/<model>.md`; the scripts do
    not infer providers or map harnesses to model-guide prefixes. Harness-native
    model aliases, when needed, belong in `agents/harnesses/<harness>.yaml` as
    `model_aliases` and normalize to canonical artifact model ids.
  - Axis filters have creation semantics: `--harness` alone or `--model` alone
    selects existing artifacts on that axis, while passing both `--harness` and
    `--model` creates that explicit harness/model target if missing.
  - `agents/scripts/update-all.bash` defaults to skill mode and discovers
    existing harness/model artifact directories for selected harness/model
    targets. `--type prompt` switches to prompt artifacts, and `--prompt <name>`
    is shorthand for prompt mode for one source prompt. It accepts `--harness`
    and `--model` target filters where they apply, but intentionally has no
    skill filter; use `update-skill.bash <skill>` for skill-specific updates.
  - Pass `--force` to `update-skill.bash`, `update-prompt.bash`, or
    `update-all.bash` to re-run selected targets on the first fixed-point pass
    even when digest stamps are current. Later passes use normal staleness
    checks. For single-surface updaters, `--force` is only valid with the
    default `run-if-stale`; use `--action run` for a one-shot unconditional run.
  - Production update runs discover supported harnesses from
    `agents/harnesses/<harness>.yaml`. Harness ids intentionally match
    executable names; the YAML config records home config paths, skill install
    paths, explicit model config keys, artifact output paths, and structural
    runner args, while `<harness>.md` records agent-facing guidance. Harness
    config list fields support block lists and compact inline arrays; runner
    args still execute as one argv entry per parsed item.
  - Maintain runtime artifacts through `agents/scripts/update-skill.bash`,
    `agents/scripts/update-prompt.bash`, or `agents/scripts/update-all.bash`,
    not direct manual harness invocations, so the target harness adapter, prompt
    artifacts, output checks, and digest stamps are all used. If a fallback
    harness authors an artifact, record that as an exception.
  - Do not hand-edit or directly generate runtime artifact contents under
    `agents/skills/artifacts/` or prompt artifact contents under
    `agents/prompts/harnesses/`. Do not manually bootstrap missing artifacts. If
    the selected native harness cannot run from the current agent environment
    because of auth, sandboxing, account limits, or a missing executable, leave
    the artifact missing/stale and give Anthony the exact updater command to run
    in a normal shell.
  - Do not run `record-stamp` or manually update digest stamps unless Anthony
    explicitly asks to mark artifacts current without a native harness run.
  - Keep shared artifact-production policy in canonical source prompts and
    source skills. Do not duplicate the same boilerplate across every
    harness/model note just to make it visible to the updater.
  - Missing native target executables are handled per selected artifact. The
    runner prompts to skip those targets or choose an installed fallback harness.
  - Production update runs normally use each local harness configuration as the
    authoring model and do not pass target artifact model ids as CLI overrides.
    Narrow harness/account compatibility overrides such as Cursor Agent's
    `--model auto` are allowed when they do not name the target artifact model.
  - `agents/scripts/symlink-skill.bash` and `symlink-all.bash` deploy runtime
    artifacts into selected home trees. Without explicit `--harness --model`,
    they inspect harness `home_config` files under the selected `--home` tree,
    derive the configured model using each harness's explicit
    `model_config_key`, and link the matching artifact. Runtime artifact model
    ids stay canonical and versioned; configured aliases such as Claude Code's
    `best`/`opus` are normalized through the harness YAML before selecting the
    artifact. `symlink-all.bash [skill-prefix]` limits bulk linking to source
    skills below a `skills/src/` subtree; use `--skill` for individual skills.
  - The first guidance set covers GPT-5.5, Claude Opus 4.7, Claude Opus 4.6,
    and Cursor Composer 2 Fast. The `commit-prep` Codex/GPT-5.5, Claude
    Code/Opus 4.6/4.7, and Cursor Agent/Composer 2 Fast artifacts preserve index
    ownership, full-dirty-tree scope by default, and compact context updates.
- Gotchas: Current model prompt guidance is versioned and changes over time. Re-check official docs before retuning a skill for a named model. Restart Codex after changing installed skill metadata or deployment shape.
- Verification: `codex debug prompt-input 'test' | rg 'commit-prep|Available skills|skills/commit-prep' -C 2` confirms fresh Codex prompt discovery; use markdown lint/format checks when adding prompt-guide docs.
