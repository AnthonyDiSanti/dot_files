# Harness Adapters

This directory documents how generic skill sources become runtime files for
specific agent harnesses and models.

## Layout

- `<harness>.yaml` — machine-readable runtime output paths and runner arguments.
  The filename stem is the harness id and must match the executable name.
- `claude.md` — Claude Code skill discovery, runtime files, and updater
  constraints for the `claude` executable.
- `codex.md` — Codex skill discovery, runtime files, and updater constraints.
- `cursor-agent.md` — Cursor Agent skill discovery, runtime files, and updater
  constraints for the `cursor-agent` executable.
- `gemini.md` — Gemini CLI skill discovery, runtime files, and updater
  constraints for the `gemini` executable.
- `harness.schema.json` — repo-local editor schema for harness YAML configs.

Prompt sources and harness-specific prompt artifacts live under
`agents/prompts/`, not in this harness adapter directory.

## Config Format

Harness configs are intentionally small YAML files with top-level scalar, map,
and list keys:

```yaml
home_config: .claude/settings.json
model_config_key: model
skills_dir: .claude/skills

model_aliases:
  best: claude-opus-4-7

outputs:
  - SKILL.md

runner_args: [--permission-mode, acceptEdits, -p]
```

`home_config` is the harness user config path relative to the selected home
tree. `model_config_key` is required and must name the scalar config key that
stores the active model id in that file, such as `model` for Claude/Codex,
`modelId` for Cursor Agent, or `model.name` for Gemini's nested JSON settings.
`skills_dir` is the harness skill install directory relative to that same home
tree.

`model_aliases` is optional and maps harness-native model aliases to canonical
runtime artifact model ids. Use it only for aliases documented by the harness,
such as Claude Code's `best`/`opus` aliases. Keep artifact directory names
canonical and versioned, and put alias resolution at this deployment/target
selection boundary instead of spreading harness-specific model logic through
scripts.

`outputs` are paths relative to the runtime artifact directory. `runner_args`
are structural CLI arguments passed to the executable named by the harness id,
and the rendered update prompt is sent on stdin. They are usually written as an
inline YAML array for scanability, but block-list form is also supported. The
updater supports `{{repo_root}}` in runner args for commands that need the
checkout path. Keep task prose and harness-specific authoring instructions in
`agents/prompts/`, not in `runner_args`.

## Pipeline

Runtime skill artifacts are maintained files, not disposable generated files. The
updater reads canonical skill source, model guidance, harness guidance,
model-specific notes, and the existing runtime artifact, then asks the selected
harness to update the artifact in place.

Maintain runtime artifacts through `agents/scripts/update-skill.bash`,
`agents/scripts/update-prompt.bash`, or `agents/scripts/update-all.bash`, not by
invoking a harness directly. Those scripts provide prompt artifacts, input
digest stamps, output validation, and native-harness selection. A fallback
harness is an explicit bring-up/debug escape hatch for missing native CLIs;
record it when used because the target harness did not author that artifact.

Do not hand-edit or directly generate runtime artifact contents as a shortcut.
If the selected native harness cannot run from the current environment because
of auth, sandboxing, account limits, or a missing executable, leave the artifact
stale and give the user the exact updater command to run in a normal shell.

Production runs invoke each harness with the local user's configured model. Do
not pass target model versions as CLI overrides just because the runtime artifact
targets that model. The target model still controls the artifact directory,
frontmatter, model guidance, and model notes.

For the first vertical slice:

```text
agents/scripts/update-skill.bash --harness codex --model gpt-5.5 --action check commit-prep
agents/scripts/update-skill.bash --harness codex --model gpt-5.5 --action status commit-prep
agents/scripts/update-skill.bash --harness codex --model gpt-5.5 --action print-prompt commit-prep
agents/scripts/update-skill.bash --harness codex --model gpt-5.5 --action run commit-prep
agents/scripts/update-skill.bash commit-prep
agents/scripts/update-skill.bash --force commit-prep
agents/scripts/update-skill.bash --harness codex --model gpt-5.5 commit-prep
agents/scripts/update-prompt.bash --harness codex --action status update-skill-artifact
agents/scripts/update-prompt.bash --harness codex update-skill-artifact
agents/scripts/update-all.bash
agents/scripts/update-all.bash --force
agents/scripts/update-all.bash --harness codex
agents/scripts/update-all.bash --model gpt-5.5
agents/scripts/update-all.bash --harness codex --model gpt-5.5
agents/scripts/update-all.bash --type prompt
agents/scripts/update-all.bash --prompt update-skill-artifact
agents/scripts/symlink-skill.bash commit-prep
agents/scripts/symlink-all.bash
agents/scripts/symlink-all.bash --harness codex --model gpt-5.5 --skill commit-prep
agents/scripts/symlink-all.bash --harness codex --model gpt-5.5 frontend
agents/scripts/symlink-all.bash --harness cursor-agent --model composer-2-fast --skill commit-prep
agents/scripts/symlink-all.bash --harness gemini --model gemini-3.1-pro-preview --skill commit-prep
```

`run` invokes the artifact's native harness executable when it is installed, or
the selected fallback harness when fallback mode is enabled.
`update-skill.bash` discovers existing harness/model artifact directories under
`agents/skills/artifacts/`, updates the named source skill for each selected
target, and accepts either a unique source skill directory name or a path
relative to `agents/skills/src/`. It skips up-to-date artifacts using committed
input-digest stamps under
`agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/`, and iterates
until it reaches a fixed point. `--harness` alone or `--model` alone filters
existing artifacts on that axis. Passing both `--harness` and `--model` is an
explicit target and creates the harness/model artifact if it does not already
exist. If a harness declares `model_aliases`, explicit harness/model targets are
normalized before artifact selection or creation. Pass `--force` to re-run
selected targets on the first pass even when their digest stamps are current;
subsequent passes use normal staleness checks to confirm convergence.
Before invoking a skill harness, `update-skill.bash` refreshes that harness's
`update-skill-artifact` prompt artifact when it is stale, then includes that
prompt artifact in the skill input digest.
`update-prompt.bash` updates one source prompt across selected harness prompt
artifacts under `agents/prompts/harnesses/<harness>/`. With no `--harness`, it
walks existing harness prompt directories; with `--harness`, it creates that
explicit prompt artifact if missing.
`update-all.bash` defaults to skill mode, uses the same harness/model targeting
semantics while walking all source skills, and repeats matrix passes if any
source, artifact, stamp, harness guide, model guide, or prompt input changed
during the prior pass. `--type prompt` switches to prompt artifacts, and
`--prompt <name>` is shorthand for prompt mode for one source prompt. It
intentionally has no skill filter; use `update-skill.bash <skill>` for
skill-specific updates. Use `print-prompt` first when reviewing prompt inputs or
debugging the pipeline.
`symlink-skill.bash` and `symlink-all.bash` deploy maintained runtime artifacts
into harness skill directories. Without an explicit `--harness --model` target,
they inspect each harness's `home_config` under the selected `--home` tree,
derive the configured model using `model_config_key`, and symlink only the
matching artifact after applying that harness's `model_aliases` map. Passing
both `--harness` and `--model` bypasses home-config model discovery and is the
correct path when bootstrapping a harness before its user config exists or when
the repo intentionally does not manage that harness's stateful config file.
`symlink-all.bash [skill-prefix]` narrows bulk deployment to all source skills
below a `skills/src/` subtree, for example every skill owned by a frontend or
services team. Use `--skill` instead when selecting individual skills by name or
path.
