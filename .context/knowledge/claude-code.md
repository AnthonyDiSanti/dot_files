# Claude Code

- Source: `agents/official-docs/claude-cli-reference.md`,
  `agents/official-docs/claude-keybindings.md`,
  `agents/official-docs/claude-skills.md`,
  `agents/official-docs/claude-settings.md`,
  `agents/official-docs/claude-model-config.md`, and
  `agents/official-docs/claude-llms.txt`; official skill spec/examples are in
  the optional `agents/official-docs/anthropic-skills` submodule.
- Why it matters: this repo deploys personal Claude Code settings and skills through the same symlink-backed `home/` mirror used for other agent harnesses.
- When to consult: changing `home/.claude/`, adding Claude Code skill artifacts, debugging Claude skill discovery, or changing the default Claude model.

## Current Shape

- Personal skills live at `~/.claude/skills/<skill>/SKILL.md`.
- This repo manages `home/.claude/skills/<skill>` as a directory symlink to a runtime artifact under `agents/skills/artifacts/<harness>/<model>/skills/<skill>/`.
- `commit-prep` currently deploys to Claude Code as:
  `home/.claude/skills/commit-prep -> ../../../agents/skills/artifacts/claude/claude-opus-4-6/skills/commit-prep`.
- Claude Code does not use a YAML sidecar such as Codex's `agents/openai.yaml`;
  Claude Code runtime artifacts should not contain an empty `agents/` directory.
- Claude Code skills use `SKILL.md` frontmatter for invocation behavior. Keep
  `name` and `description` explicit; use `disable-model-invocation: true` only
  for explicit-only workflows, and avoid broad `allowed-tools` grants in
  generated artifacts.
- Claude Code is pinned to Opus 4.6 in two places:
  - `home/.claude/settings.json` sets `"model": "claude-opus-4-6"`.
  - the Claude runtime artifact frontmatter sets `model: claude-opus-4-6`.
- The repo may still keep non-deployed Claude Code artifacts for newer models,
  such as `claude/claude-opus-4-7`, for evaluation or future opt-in.
- Claude Code supports model aliases in the `model` setting. The cached
  model-config docs say `best` currently resolves to `opus`, and on the
  Anthropic API `opus` resolves to Opus 4.7. `agents/harnesses/claude.yaml`
  maps `best` and `opus` to the canonical `claude-opus-4-7` artifact for
  deployment and explicit harness/model target selection.
- Do not map Claude Code `default`: it clears the override and resolves through
  account/provider policy. Only add other aliases when corresponding runtime
  artifacts and a deployment decision exist.

## Notes

- The existing local `~/.claude.json` is Claude Code state/cache and is not managed by this repo.
- `~/.claude/CLAUDE.md` was already symlinked to `home/.claude/CLAUDE.md`; `settings.json` and `skills/commit-prep` now follow the same bootstrap-managed home-tree pattern.
- Native Claude artifact production should still go through
  `agents/scripts/update-skill.bash`, but `claude` invocations launched from
  another agent's sandbox may fail with auth/API errors even when a normal shell
  login works. In that case, provide Anthony the exact updater command to run
  outside the agent sandbox; do not treat the auth failure as evidence that the
  skill artifact is wrong.
- Claude Code print mode uses `claude -p`. The cached CLI reference documents
  output formats, turn/budget limits, setting-source filters, `--bare`, and
  explicit `--model`, but this repo's artifact runner deliberately relies on the
  local user's configured model rather than passing target-model overrides.
- `claude-settings.md` is the source for settings scope/precedence and
  `claude-skills.md` is the source for skill frontmatter, invocation control,
  subagent execution, and supporting files. Use `claude-llms.txt` to discover
  docs before adding new managed Claude Code surfaces.
- Hydrate `agents/official-docs/anthropic-skills` when the official skill spec,
  template, or example skills would help evaluate cross-harness skill shape.
  That submodule supplements the Claude Code skills docs; it does not replace
  them.
- Keyboard shortcuts can be customized through Claude Code keybinding config,
  but this repo has not started managing those dotfiles.
