# Official Docs

This directory caches authoritative vendor model, prompt, migration, and harness
docs. Most sources are copied files; larger upstream documentation sets may be
tracked as pinned Git submodules when they are reference-only and not needed for
bootstrap.

Do not edit copied vendor documents by hand. If a vendor guide changes, replace
the file with a fresh copy from the official source and review downstream
derived notes in `../models/`. For submodule-backed docs, update the submodule
pointer instead of editing upstream files in place.

Files copied from rolling vendor pages include the latest model release context
that made the document relevant to this repo. Files copied from model-specific
guides use the model name directly.

## Cached

- `anthropic-skills/` — Pinned `anthropics/skills` submodule at commit
  `5128e1865d670f5d6c9cef000e6dfc4e951fb5b9`, used for official skill
  spec, templates, and examples. It supplements `claude-skills.md`; it does
  not replace the Claude Code skills docs page.
- `claude-cli-reference.md` — Claude Code CLI command and flag reference.
- `claude-keybindings.md` — Claude Code keyboard shortcut customization
  reference.
- `claude-llms.txt` — Claude Code documentation index for discovering current
  product docs.
- `claude-model-config.md` — Claude Code model aliases, model selection,
  effort, and provider mapping reference.
- `claude-opus-4-7-model-migration-guide.md` — Anthropic Claude model
  migration guide as captured for the Claude Opus 4.7 release.
- `claude-opus-4-7-extended-thinking.md` — Anthropic extended
  thinking guide as captured for the Claude Opus 4.7 release.
- `claude-opus-4-7-new-features.md` — Anthropic Claude Opus 4.7
  feature and behavior-change overview.
- `claude-opus-4-7-prompting-best-practices.md` — Anthropic Claude
  prompting best practices as captured for the Claude Opus 4.7 release.
- `claude-settings.md` — Claude Code settings scopes, files, schema, and
  managed/local configuration reference.
- `claude-skills.md` — Claude Code skill layout, frontmatter, invocation, and
  distribution reference.
- `codex-agents-md.md` — Codex `AGENTS.md` discovery and layering guide.
- `codex-best-practices.md` — Codex product and workflow best practices.
- `codex-cli-commands.md` — Codex CLI slash-command reference.
- `codex-cli-features.md` — Codex CLI interactive and scripting feature guide.
- `codex-cli-reference.md` — Codex CLI command and flag reference.
- `codex-config-advanced.md` — Codex advanced configuration guide covering
  profiles, providers, hooks, project roots, and integrations.
- `codex-config-basics.md` — Codex configuration basics and precedence.
- `codex-config-reference.md` — Codex configuration key reference.
- `codex-execplans.md` — OpenAI cookbook guide for Codex execution plans.
- `codex-feature-maturity.md` — Codex maturity-label definitions for deciding
  whether a feature is stable enough to manage.
- `codex-hooks.md` — Codex hooks configuration and lifecycle-event reference.
- `codex-mcp.md` — Codex MCP configuration guide.
- `codex-memories.md` — Codex memories behavior, storage, and configuration
  guide.
- `codex-noninteractive.md` — Codex `exec` / non-interactive mode guide.
- `codex-plugins.md` — Codex plugin overview.
- `codex-plugins-build-guide.md` — Codex plugin packaging and marketplace
  guide.
- `codex-rules.md` — Codex approval rules reference.
- `codex-sample-config.toml` — OpenAI sample Codex `config.toml` showing
  current supported keys and examples.
- `codex-sandboxing.md` — Codex sandboxing concept guide.
- `codex-skills.md` — Codex skills discovery, authoring, and metadata guide.
- `codex-subagents.md` — Codex subagents concept guide.
- `codex/` — Pinned `openai/codex` submodule at tag `rust-v0.128.0`,
  matching local `codex-cli 0.128.0`. Use it for source-owned Codex reference
  material such as CLI implementation docs, config and hook schemas, built-in
  Codex skills, app-server protocol schemas, and source-level behavior checks.
  Keep the copied `codex-*.md` web-doc exports because the source repo often
  links back to those richer pages rather than duplicating them.
- `gpt-5.5-migration-guide.md` — OpenAI GPT-5.5 migration guide.
- `gpt-5.5-prompting-guide.md` — OpenAI GPT-5.5 prompting guide.
- `cursor-agent-cli-overview.md` — Cursor CLI overview.
- `cursor-agent-cli-usage.md` — Cursor CLI usage guide.
- `cursor-agent-cli-parameters.md` — Cursor CLI parameter reference.
- `cursor-agent-cli-configuration.md` — Cursor CLI configuration reference.
- `cursor-agent-cli-mcp.md` — Cursor CLI MCP reference.
- `cursor-agent-rules.md` — Cursor rules and `AGENTS.md` reference.
- `composer-2-technical-report.pdf` — Cursor Composer 2 technical report.
- `cursor-plugins/` — Pinned `cursor/plugins` submodule at commit
  `7dd9fea1e0e9bb88fcf059f5e77eb5a9d31bef1e`, used for Cursor plugin
  schemas, examples, marketplace metadata, and official plugin/skill patterns.
  It supplements the copied Cursor CLI/rules docs; it does not replace them.
- `gemini-3-developer-guide.md` — Google AI Gemini 3 developer guide,
  including Gemini 3.1 Pro model positioning, thinking levels, media
  resolution, temperature guidance, tool behavior, migration guidance, and
  prompting best practices.
- `gemini-3-getting-started.md` — Vertex AI Gemini 3 getting-started guide,
  including high-thinking coding examples, feature links, Vertex setup, and
  Gemini 3 API migration notes.
- `gemini-3-thinking.md` — Vertex AI thinking guide, including Gemini 3
  `thinking_level` behavior, supported levels, token accounting, and thought
  signature context.
- `gemini-3.1-pro.md` — Vertex AI Gemini 3.1 Pro Preview model reference,
  including model id, context/output limits, thinking-level notes, and the
  custom-tools endpoint.
- `gemini-cli/` — Pinned `google-gemini/gemini-cli` submodule at `v0.40.1`,
  used as the authoritative Gemini CLI docs/reference tree. It is optional for
  bootstrap and normal dotfile use; hydrate it only when working on Gemini
  harness support or refreshing Gemini docs.

## Cached Source URLs

These live URLs correspond to documents already cached above. Use them only when
refreshing the local authoritative copy.

- OpenAI GPT-5.5 prompt guidance:
  <https://developers.openai.com/api/docs/guides/prompt-guidance?model=gpt-5.5>
- OpenAI GPT-5.5 migration guide:
  <https://developers.openai.com/api/docs/guides/upgrading-to-gpt-5p5>
- Codex `AGENTS.md` discovery:
  <https://developers.openai.com/codex/guides/agents-md>
- Codex best practices:
  <https://developers.openai.com/codex/learn/best-practices>
- Codex CLI features:
  <https://developers.openai.com/codex/cli/features>
- Codex CLI slash commands:
  <https://developers.openai.com/codex/cli/slash-commands>
- Codex CLI reference:
  <https://developers.openai.com/codex/cli/reference>
- Codex advanced config:
  <https://developers.openai.com/codex/config-advanced>
- Codex config basics:
  <https://developers.openai.com/codex/config-basic>
- Codex config reference:
  <https://developers.openai.com/codex/config-reference>
- Codex sample config:
  <https://developers.openai.com/codex/config-sample>
- Codex execution plans:
  <https://developers.openai.com/cookbook/articles/codex_exec_plans>
- Codex feature maturity:
  <https://developers.openai.com/codex/feature-maturity>
- Codex hooks:
  <https://developers.openai.com/codex/hooks>
- Codex MCP:
  <https://developers.openai.com/codex/mcp>
- Codex memories:
  <https://developers.openai.com/codex/memories>
- Codex non-interactive mode:
  <https://developers.openai.com/codex/noninteractive>
- Codex plugins:
  <https://developers.openai.com/codex/plugins>
- Codex plugin build guide:
  <https://developers.openai.com/codex/plugins/build>
- Codex rules:
  <https://developers.openai.com/codex/rules>
- Codex sandboxing:
  <https://developers.openai.com/codex/concepts/sandboxing>
- Codex skills:
  <https://developers.openai.com/codex/skills>
- Codex subagents:
  <https://developers.openai.com/codex/concepts/subagents>
- Codex source snapshot:
  <https://github.com/openai/codex/tree/rust-v0.128.0>
- Codex source docs tree:
  <https://github.com/openai/codex/tree/rust-v0.128.0/docs>
- Anthropic skills reference repo:
  <https://github.com/anthropics/skills/tree/5128e1865d670f5d6c9cef000e6dfc4e951fb5b9>
- Claude Code CLI reference:
  <https://code.claude.com/docs/en/cli-reference>
- Claude Code keybindings:
  <https://code.claude.com/docs/en/keybindings>
- Claude Code docs index:
  <https://code.claude.com/docs/llms.txt>
- Claude Code model configuration:
  <https://code.claude.com/docs/en/model-config>
- Claude Code settings:
  <https://code.claude.com/docs/en/settings>
- Claude Code skills:
  <https://code.claude.com/docs/en/skills>
- Claude prompting best practices:
  <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>
- Claude extended thinking:
  <https://platform.claude.com/docs/en/build-with-claude/extended-thinking>
- Claude model migration guide:
  <https://platform.claude.com/docs/en/about-claude/models/migration-guide>
- What's new in Claude Opus 4.7:
  <https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-7>
- Cursor CLI overview:
  <https://docs.cursor.com/cli/overview>
- Cursor CLI usage:
  <https://docs.cursor.com/cli/using>
- Cursor CLI parameter reference:
  <https://docs.cursor.com/cli/reference/parameters>
- Cursor CLI configuration reference:
  <https://docs.cursor.com/cli/reference/configuration>
- Cursor CLI MCP reference:
  <https://docs.cursor.com/cli/mcp>
- Cursor rules:
  <https://docs.cursor.com/context/rules-for-ai>
- Composer 2 technical report:
  <https://cursor.com/blog/composer-2-technical-report>
- Cursor plugins reference repo:
  <https://github.com/cursor/plugins/tree/7dd9fea1e0e9bb88fcf059f5e77eb5a9d31bef1e>
- Gemini 3 developer guide:
  <https://ai.google.dev/gemini-api/docs/gemini-3>
- Vertex AI Gemini 3 getting started:
  <https://docs.cloud.google.com/vertex-ai/generative-ai/docs/start/get-started-with-gemini-3>
- Vertex AI thinking:
  <https://docs.cloud.google.com/vertex-ai/generative-ai/docs/thinking>
- Vertex AI Gemini 3.1 Pro:
  <https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-1-pro>
- Gemini CLI docs tree:
  <https://github.com/google-gemini/gemini-cli/tree/v0.40.1/docs>
- Gemini CLI captured tag:
  <https://github.com/google-gemini/gemini-cli/tree/v0.40.1>

## Uncached External References

These live references are cited by model or harness notes but are not currently
cached as local source documents.

### Model And Product References

- OpenAI latest-model guide:
  <https://developers.openai.com/api/docs/guides/latest-model>
- OpenAI models reference: <https://developers.openai.com/api/docs/models>
- Introducing Claude Opus 4.7:
  <https://www.anthropic.com/news/claude-opus-4-7>
- Claude release notes:
  <https://support.claude.com/en/articles/12138966-release-notes>
- Cursor models: <https://docs.cursor.com/models>
- Composer 2 announcement: <https://cursor.com/blog/composer-2>
- Google AI Gemini models:
  <https://ai.google.dev/gemini-api/docs/models>
- Gemini 3.1 Pro announcement:
  <https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-1-pro/>

### Codex Harness References

Core Codex harness references are now cached as copied web-doc exports, and the
`openai/codex` source snapshot is available as an optional submodule. Do not
delete the copied `codex-*.md` docs just because the source snapshot is
hydrated: several source files are intentionally short stubs that link back to
developers.openai.com, while the copied exports contain the richer public docs.
Keep this timely model-selection page external by design:

- Codex model selection / CLI model behavior:
  <https://developers.openai.com/codex/models>

### Claude Code Harness References

Core Claude Code harness references are now cached. Use `claude-llms.txt` to
discover additional pages before adding new Claude-managed surfaces such as
hooks, subagents, MCP servers, plugins, or managed settings. Hydrate
`anthropic-skills/` when official skill examples, templates, or the skill spec
would help tune cross-harness skill source.

### Cursor Harness References

The installed Cursor built-in `create-skill` skill is useful reference material
for personal/project skill layout, but it is local product content rather than a
public docs page. Hydrate `cursor-plugins/` when adding Cursor plugin support or
checking Cursor's official plugin schemas, marketplace metadata, or plugin skill
examples.

### Gemini Harness References

Core Gemini CLI harness references are available through the pinned
`google-gemini/gemini-cli` submodule under `gemini-cli/docs/`. Hydrate with:

```sh
git submodule update --init --depth 1 agents/official-docs/gemini-cli
```

Refresh by moving the submodule to a newer official tag or commit, then review
`../models/gemini-3.1-pro-preview.md` and `.context/knowledge/gemini-cli.md`.

## Optional Reference Submodules

Hydrate all optional reference submodules when doing a broad agent-doc refresh:

```sh
git submodule update --init --depth 1 \
  agents/official-docs/codex \
  agents/official-docs/anthropic-skills \
  agents/official-docs/cursor-plugins \
  agents/official-docs/gemini-cli
```

Refresh submodules by moving their gitlinks to a newer official tag or commit.
Do not edit upstream files in place. Current non-added repo candidates:

- `anthropics/claude-code` — useful if this repo later manages Claude Code
  plugins, hooks, or example settings in depth, but it does not replace the
  cached Claude Code docs pages.
- `cursor/cookbook` — useful for Cursor SDK/cloud-agent app examples, but not
  directly needed for current CLI, skill, or plugin deployment docs.
- `cursor/cursor` — no current reference value beyond a small README/security
  repo, so it should stay external unless that repository grows real docs.
