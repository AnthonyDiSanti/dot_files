# Codex Approval Rules

## When to consult
- Before tracking files under `home/private_dot_codex/rules/`.
- Before broadening command approval behavior to reduce prompts.
- When debugging why Codex prompted for, allowed, or rejected a command.

## Notes
- Source: <https://developers.openai.com/codex/rules>
- Codex scans `.rules` files under `rules/` at startup, including the user-layer `~/.codex/rules/` location.
- Codex writes TUI-accepted and generated approval rules to `~/.codex/rules/default.rules`; keep that file unmanaged so local prompt decisions can churn safely.
- Curated portable rules should live in a separate managed file, planned as `home/private_dot_codex/rules/global.rules`, which maps to `~/.codex/rules/global.rules`.
- Restart Codex after changing rule files.
- Multiple matching rules combine by the most restrictive decision: `forbidden` beats `prompt`, and `prompt` beats `allow`.

## Testing
Use `codex execpolicy check` with explicit `--rules` flags:

```sh
codex execpolicy check --pretty \
  --rules ~/.codex/rules/global.rules \
  --rules ~/.codex/rules/default.rules \
  -- git status --short
```
