# Cursor Agent

- Source: Cursor CLI docs, Cursor rules docs, Composer 2 technical report, the
  optional `agents/official-docs/cursor-plugins` submodule, and the installed
  Cursor built-in `create-skill` / `update-cli-config` skills.
- Why it matters: this repo now deploys Cursor Agent skills through the same
  symlink-backed `home/` mirror used for Codex and Claude Code, while Cursor's
  CLI config remains mostly local state.
- When to consult: changing `home/.cursor/`, adding Cursor Agent skill
  artifacts, debugging Cursor skill discovery, changing Cursor model targets, or
  deciding whether to manage more Cursor config.

## Current Shape

- Cursor docs commonly show the CLI as `agent`, and this machine has both
  `agent` and `cursor-agent` aliases. The repo intentionally uses
  `cursor-agent` as the harness id because it is unambiguous in artifact paths
  and matches `agents/harnesses/cursor-agent.yaml`.
- Personal skills live at `~/.cursor/skills/<skill>/SKILL.md`.
- Built-in Cursor skills live at `~/.cursor/skills-cursor/`; do not deploy
  repo-managed skills there.
- This repo manages `home/.cursor/skills/<skill>` as a directory symlink to a
  runtime artifact under
  `agents/skills/artifacts/cursor-agent/<model>/skills/<skill>/`.
- `commit-prep` currently deploys to Cursor Agent as:
  `home/.cursor/skills/commit-prep -> ../../../agents/skills/artifacts/cursor-agent/composer-2-fast/skills/commit-prep`.
- Cursor Agent runtime artifacts currently contain only `SKILL.md`.

## Config Boundary

- Cursor CLI config is stateful and contains local model picker state,
  permissions, privacy/cache data, auth metadata, and server config. Official
  docs default to `~/.cursor/cli-config.json`, but this repo exports
  `CURSOR_CONFIG_DIR=$XDG_CONFIG_HOME/cursor`, so the live macOS path is
  `~/.config/cursor/cli-config.json`. Do not manage the whole file as a normal
  dotfile.
- Repo-managed Cursor CLI preferences live in `settings/cursor-agent-cli.json`
  and are applied by `settings/cursor-agent-cli.sh`, which merges preferences
  into the live file while preserving Cursor-owned auth/cache/state keys. The
  managed JSON is self-contained enough to create a valid first-time config, but
  it remains a preference patch rather than the full tracked config file.
- Harness discovery reads `modelId` from the configured home file when present.
  Repo `home/` intentionally does not include a Cursor config; use explicit
  `--harness cursor-agent --model composer-2-fast` when regenerating repo-home
  symlinks.
- Cursor documents `/model auto`, and Free-plan non-interactive runs can reject
  named models. The harness maps both `auto` and Cursor's self-repaired
  `default` model id to the canonical `composer-2-fast` artifact target because
  this machine reports Composer 2 Fast as the current default Auto-backed model.
  Treat that as live product/account state; re-check
  `cursor-agent --list-models` / `cursor-agent about` and the official Cursor
  models page before adding aliases or retargeting artifacts.

## Useful Commands

```sh
cursor-agent --list-models
settings/cursor-agent-cli.sh --dry-run
agents/scripts/symlink-all.bash --home home --harness cursor-agent --model composer-2-fast --skill commit-prep
agents/scripts/update-skill.bash --harness cursor-agent --model composer-2-fast --action check commit-prep
agents/scripts/update-skill.bash --harness cursor-agent --model composer-2-fast --action run commit-prep
```

## Sandbox Mode

Cursor Agent rejected `--sandbox enabled` on this macOS machine because its
sandbox was unavailable. Anthony explicitly approved using `--sandbox disabled`
for repo skill artifact production so native Cursor Agent can still perform the
target-harness pass through `agents/scripts/update-skill.bash`.

Free-plan native Cursor runs rejected named model use with a message that Free
plans can only use Auto. Set the live local Cursor config to `auto`; the harness
alias maps that back to the `composer-2-fast` artifact target for deployment.
Headless print mode still rejected named/default model selection after the live
config was set to Auto, so the runner passes `--model auto` explicitly as an
account-compatibility override. Do not replace that with the target artifact id.

## Cached Docs

The Markdown-exportable Cursor CLI/rules docs and the public Composer 2
technical-report PDF are now cached under `agents/official-docs/`. Derived
guidance lives in `agents/models/composer-2-fast.md` and
`agents/harnesses/cursor-agent.md`.

The optional `agents/official-docs/cursor-plugins` submodule provides Cursor's
official plugin schemas, marketplace metadata examples, and plugin skill
patterns. Hydrate it when adding plugin support or checking whether Cursor's
plugin conventions should influence repo skill or agent packaging.

Cursor model availability, pricing, and account gating remain live product
state. Re-check `cursor-agent --list-models` and official Cursor model docs
before changing model ids or deployment targets.
