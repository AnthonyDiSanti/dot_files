# Codex skills

- Source: `agents/skills/`, `home/.agents/skills/`,
  `agents/official-docs/codex-skills.md`, and
  `agents/official-docs/codex/.codex/skills/`
- Why it matters: Codex skill discovery is sensitive to filesystem shape, and
  the repo may eventually expose the same skill sources to multiple agent
  harnesses.
- When to consult: adding, moving, or debugging a local Codex skill.
- Key points: Canonical skill source lives as `SKILL.md` directories under
  `agents/skills/src/`, while Codex runtime artifacts live under
  `agents/skills/artifacts/<harness>/<model>/skills/<skill>/`. The source skill
  directory name is the runtime skill id and must be globally unique across the
  source tree. Codex deployment paths live under `home/.agents/skills/` as real
  symlink nodes to runtime artifact directories, so bootstrap deploys
  `~/.agents/skills/<skill>` as a symlink to the repo symlink node. A fresh
  Codex prompt discovers a two-hop symlinked skill directory and reports the
  runtime artifact `SKILL.md` path. Codex's initial skill list is budgeted;
  current docs describe a cap around 2% of context, or 8,000 characters when
  context size is unknown. Keep descriptions concise and front-loaded because
  Codex shortens descriptions before omitting skills from very large lists.
- Gotchas: Current public Codex docs describe user skills under
  `$HOME/.agents/skills` and say symlinked skill folders are supported; this was
  verified locally with `codex debug prompt-input` before migrating from the
  older repo path under `~/.codex/skills`. Codex did not discover `commit-prep`
  when bootstrap symlinked only individual files such as
  `SKILL.md`. It did discover a regular skill directory, a symlinked skill
  directory, and the two-hop layout: `~/.agents/skills/<skill>` to
  `repo/home/.agents/skills/<skill>` to
  `repo/agents/skills/artifacts/<harness>/<model>/skills/<skill>`. Restart the
  Codex session after changing installed skill metadata or deployment shape. If
  two discovered Codex skills share the same `name`, Codex can show both rather
  than merging them; this repo still rejects duplicate source skill directory
  names because artifact ids and deployment paths must be unique.
- Model-selection gotcha: the Codex CLI config uses concrete model slugs such as
  `gpt-5.5`. Current Codex docs expose recommended model slugs on the live
  Codex models page rather than a Claude-style `best` alias layer, so keep that
  page external and re-check it before changing Codex artifact targets.
- Source-reference gotcha: the optional `openai/codex` submodule is useful for
  built-in skill examples and exact source schemas, but it does not replace the
  copied public Codex skill docs. The source repo's `docs/skills.md` is a short
  link stub, while `agents/official-docs/codex-skills.md` contains the richer
  exported public docs.
- Verification: run
  `codex debug prompt-input 'test' | rg 'commit-prep|Available skills|skills/commit-prep' -C 2`
  after bootstrap or skill-shape changes.
