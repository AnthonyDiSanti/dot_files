# Agent reference submodules

- Source: `.gitmodules`, `agents/official-docs/README.md`, and optional
  submodules under `agents/official-docs/`.
- Why it matters: some vendor reference material is better maintained as a
  pinned upstream tree than as copied Markdown, while copied web-doc exports
  remain useful when upstream repos only link back to the public docs.
- When to consult: refreshing official agent docs, updating model/harness
  guidance, or deciding whether another vendor repo should become a submodule.
- Current submodules:
  - `agents/official-docs/codex` tracks `openai/codex` at tag
    `rust-v0.128.0`, matching local `codex-cli 0.128.0`. Use it for Codex
    source docs, config/hook schemas, built-in skills, protocol schemas, and
    source-level behavior checks. Keep copied `codex-*.md` public-doc exports
    because many source docs are short link stubs.
  - `agents/official-docs/anthropic-skills` tracks `anthropics/skills` at
    commit `5128e1865d670f5d6c9cef000e6dfc4e951fb5b9`. Use it for official
    Claude skill spec, templates, and example skills. It supplements
    `claude-skills.md`; it does not replace Claude Code docs.
  - `agents/official-docs/cursor-plugins` tracks `cursor/plugins` at commit
    `7dd9fea1e0e9bb88fcf059f5e77eb5a9d31bef1e`. Use it for Cursor plugin
    schemas, marketplace metadata, and plugin skill examples. It supplements
    Cursor CLI/rules docs.
  - `agents/official-docs/gemini-cli` tracks `google-gemini/gemini-cli` at tag
    `v0.40.1`. Use it for Gemini CLI docs and harness bring-up.
- Gotchas: optional reference submodules are not runtime dependencies. Do not
  make `bootstrap.sh` or normal dotfile use require hydration. Broad repo
  verification excludes `.gitmodules` paths so upstream files are not linted or
  formatted as native dotfiles source.
- Distilled learnings:
  - Codex built-in skills favor concrete workflow contracts: objective, inputs,
    steps, commands/scripts, guardrails, validation, and output expectations.
    Codex sidecar `agents/openai.yaml` is useful UI/default-prompt metadata, but
    the runtime `SKILL.md` remains the procedural source.
  - Anthropic skills emphasize trigger-heavy descriptions, progressive
    disclosure, supporting resources, and eval-driven iteration. Keep
    `SKILL.md` focused; move large references/scripts/assets out of the body and
    include representative examples only where they clarify behavior.
  - Cursor plugin skills show that skills remain plain `SKILL.md` files even
    inside richer plugin packages. Plugin manifests, rules, hooks, agents, and
    MCP config are separate distribution surfaces, not metadata to fold into
    ordinary skill artifacts.
  - Gemini CLI confirms the interoperable `.agents/skills` path, consented
    `activate_skill` activation, and headless `gemini -p` automation path with
    JSON/stream-json output. Model routing and preview access can change the
    actual model used, so artifact-production logs should record fallback.
- Refresh: hydrate with `git submodule update --init --depth 1 ...`, then move
  the relevant gitlink to a newer official tag or commit. Review derived files
  under `agents/models/`, `agents/harnesses/`, and skill `model-notes/`.
- Deferred candidates: `anthropics/claude-code` may become useful for deep
  Claude plugin/hooks/settings examples; `cursor/cookbook` may become useful
  for Cursor SDK/cloud-agent apps; `cursor/cursor` currently has no meaningful
  docs value for this repo.
