# Handoff

## Current State
- What works: repo-native bootstrap (`bootstrap.sh`) installs the checked-out `home/` tree into `$HOME` without chezmoi or a Git runtime dependency, and it does not require optional reference submodules to be hydrated; shell startup now uses a POSIX baseline (`.profile` / `.shrc`) plus bash and zsh wrappers backed by `XDG_CONFIG_HOME` / `~/.config`; `home/.config/shell/paths.sh` exports default XDG base-dir variables and derives the shell's internal `dotfiles_*` path layer, bash/zsh history lives under `XDG_STATE_HOME` / `~/.local/state` with timestamp storage enabled, Bash/zsh line editors support prefix history search plus case-/hyphen-insensitive completion matching, zsh uses colored grouped/described completion presentation plus `zsh/complist` menu selection for ambiguous matches, zsh vi mode has cursor feedback, editor handoff, whole-buffer `ae`, quote/bracket text objects, and surround bindings, and bash/zsh tool support now prefers Homebrew/system completion frameworks while using active-Git and selected command-generated helpers only when their generators succeed; Vim plugins use **vim-plug** with a tracked `home/.vim/autoload/plug.vim` loader snapshot and local `~/.vim/plugged/` plugin clones after `:PlugInstall`; terminal Solarized Dark is managed for Ghostty and iTerm2; skill source lives as directories containing `SKILL.md` anywhere under `agents/skills/src/`, runtime artifacts live under `agents/skills/artifacts/<harness>/<model>/skills/`, updater prompt source/artifacts live under `agents/prompts/`, and Codex/Claude/Cursor/Gemini skills deploy through symlink nodes in `home/`; official vendor docs live under `agents/official-docs/`, with optional pinned reference submodules for Codex source, Anthropic skills, Cursor plugins, and Gemini CLI; model guidance lives under `agents/models/`; harness adapters live under `agents/harnesses/`.
- Editor direction: **Vanilla Vim** is the target for dotfiles (Vim 8+ compatible plugins, no Neovim requirement) so SSH sessions can stay simple: get dotfiles on the machine, bootstrap, use `vim`. **Neovim** is explicitly a possible next step—see `.context/decisions.md`—not part of the current plugin migration.
- What’s in progress: Agent instruction infrastructure is active on `feature/multi-model-skill` and ready for commit. `commit-prep` has canonical source, optional model/harness notes for real target deltas, and an eval fixture; both updater prompts have canonical source, with prompt-specific harness notes only where a real harness delta remains. `SKILL.md` frontmatter is the canonical skill identity source; separate source `metadata.yaml` files were removed. Source skills and prompts may be nested anywhere below their `src/` roots; directory names remain runtime ids and must be globally unique. Runtime skill artifacts, prompt artifacts, and digest stamps are present for the current Codex, Claude, Cursor Agent, and Gemini targets after native updater-script regeneration; do not manually create, patch, or stamp them. `agents/scripts/update-skill.bash` refreshes harness-specific prompt artifacts before invoking native skill artifact production and passes matching skill `harness-notes/<harness>.md` and `model-notes/<model>.md` into both prompts and digests when those optional files exist; `agents/scripts/update-prompt.bash` maintains source prompts under `agents/prompts/src/` into harness artifacts under `agents/prompts/harnesses/` and passes matching prompt `harness-notes/<harness>.md` into both maintenance prompts and digests when present; `agents/scripts/update-all.bash` defaults to skill mode and supports `--type prompt` / `--prompt` for prompt updates. `agents/scripts/symlink-skill.bash` and `agents/scripts/symlink-all.bash` deploy runtime artifacts into selected home trees, discovering configured harness/model targets from harness home config files unless `--harness --model` is explicit; `symlink-all.bash [skill-prefix]` narrows bulk deployment to all source skills under a `skills/src/` subtree. Model guides resolve directly from `agents/models/<model>.md`; there is no provider-prefix mapping, while harness-native model aliases such as Claude Code's `best`/`opus` live in harness YAML and normalize to canonical artifact ids. Supported harnesses are discovered from `agents/harnesses/<harness>.yaml`, and the harness id must match the executable name. Clipboard/register unification remains an active paused workstream on `feature/clipboard`; real WSL smoke testing still remains before considering clipboard v1 complete.
- What’s broken / flaky: Claude Code artifact production can fail when another
  agent invokes `claude` from inside its own sandbox; hand Anthony the exact
  updater command for a normal shell run. Cursor Agent sandbox mode is disabled
  in the harness runner because `--sandbox enabled` is unavailable on this macOS
  machine. Cursor Free plans can require `auto` instead of named models for
  native production; `cursor-agent.yaml` maps `auto` and Cursor's self-repaired
  `default` model id to the canonical `composer-2-fast` artifact target and
  passes `--model auto` for headless print-mode compatibility. Cursor CLI
  preferences are managed by merge through `settings/cursor-agent-cli.sh`; do
  not symlink the full stateful `cli-config.json`. Gemini CLI can refresh
  local OAuth only outside this sandbox, and native Gemini artifact runs can hit
  `MODEL_CAPACITY_EXHAUSTED` for `gemini-3.1-pro-preview`.

## Next Steps (ordered)
1. Commit the multi-model skill changes after review.
2. After the agent-instruction branch is done, return to the Windows/WSL clipboard and Windows Terminal Solarized work described below.
3. Treat the OMB/OMZ inspiration pass as mostly complete; remaining shell items should be explicit standalone workstreams such as small directory helpers.
4. After Neovim evaluation, revisit tmux TPM/plugins as a separate workstream, especially `tmux-resurrect` and `tmux-continuum`.
5. At the very end after tmux plugin evaluation, address the upstream tmux `selection-mode line` bug using the saved issue draft in `.context/scratch/20260428-tmux-selection-mode-line-bug/report.md`.

Reminder: if another already-bootstrapped machine has host-local rc overrides named `.sh_local`, `.bash_local`, or `.zsh_local`, rename them to `.shrc_local`, `.bashrc_local`, or `.zshrc_local` after pulling this commit.

## Active Tasks
- `01KQ6VIMODECLIPBOARD2026` — clipboard/register unification is active on `feature/clipboard`; macOS wrapper support, WSL wrapper support, broad zsh CUTBUFFER wiring, and tmux copy/import/paste integration are implemented for v1. Real WSL smoke testing remains.
- `01KQ9AGENTINSTRUCTIONS2026` — agent instruction infrastructure is active on `feature/multi-model-skill` and ready for commit; `commit-prep` source is backed by optional model notes, optional harness notes, evals, harness configs/docs, source updater prompts, updater scripts, runtime artifacts, and digest stamps. The two updater prompts have optional prompt-specific harness notes only where a harness delta exists.
- `01KQ9AGENTHARNESSVARIANTS2026` — add full artifact production support for all harnesses. Codex, Claude Code, Cursor Agent, and Gemini CLI now have harness YAML/docs and `commit-prep` artifact targets. Gemini deploys through `.gemini/skills` to avoid clobbering Codex's `.agents/skills`, with a documented same-name shadowing caveat. Current artifacts and stamps are present after updater-script regeneration.
- `01KPNZ3YBAKB9N4ZJEXW4P2EHP` — zsh migration remains active; non-clipboard vi mode is merged, and clipboard/register unification is now active as a focused follow-up.

## Working Tree
- Current branch: `main`; rebased onto fetched `origin/main` on 2026-05-08.
  Local `main` is ahead by one commit (`0670b2c Add settings/windows-wsl/resolv.conf`).
  Remaining uncommitted edits are `home/.codex/config.toml` (pre-existing
  personal Codex config changes reapplied after autostash) and
  `home/.config/shell/aliases.sh` (POSIX `-` alias portability fix found during
  verification). `./bootstrap.sh` was applied to converge the live home after
  upstream added agent skill/config symlink targets.
- Last successful full verification: `PATH=/tmp/codex-shfmt:$PATH test/verify.sh`
  passed on 2026-05-08 in 26.0s after downloading temporary `shfmt` v3.13.0
  because this environment does not have a system `shfmt`.

## Windows Terminal Solarized Plan
- Work will continue on a Windows/WSL machine in a fresh session on `feature/clipboard`, then return to macOS for final verification.
- Use the default open-source Windows Terminal, not a third-party terminal. First inspect the actual settings location/version on that machine; likely candidates include the Store package path under `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`, the Preview package path, or an unpackaged `settings.json`.
- Do not blindly replace the whole Windows Terminal `settings.json`. It commonly contains local profiles, generated GUIDs, WSL distro entries, launch behavior, keybindings, and machine-local state. Prefer the narrowest durable approach after inspection.
- Preferred first design: add a Solarized Dark color scheme to the `schemes` array and set `profiles.defaults.colorScheme` to that scheme. Only override individual profiles if existing profile-specific choices require it.
- If the live `settings.json` is clean and stable enough to track as a full dotfile, document why before doing so. Otherwise, implement a small merge/apply helper or documented manual fragment instead of owning the entire file.
- Use canonical Solarized Dark values consistent with Ghostty/iTerm2 already in this repo. Avoid reintroducing the old `settings/solarized` submodule.
- Coordinate this with the active WSL clipboard work: Windows changes may include larger fixes to `dotfiles-clipboard` provider behavior. After the Windows pass, return to macOS and confirm macOS wrapper behavior and terminal colors still work.

## WSL Clipboard Smoke Plan
- Run `dotfiles-clipboard status`; expected output is `wsl`.
- Run `printf 'dotfiles-copy-test' | dotfiles-clipboard copy`, then paste in a Windows app or run `powershell.exe -NoLogo -NoProfile -Command 'Get-Clipboard -Raw'`.
- Run ``powershell.exe -NoLogo -NoProfile -Command 'Set-Clipboard -Value "alpha`r`nbeta"'``, then `dotfiles-clipboard paste | od -An -t x1`; expected bytes include `0a` between lines and no `0d`.
- In zsh vi mode, yank/delete/change text at the prompt and confirm Windows paste receives the same text; then copy in Windows and confirm zsh `p`/`P` uses that clipboard text.
- In tmux under WSL, use copy-mode `y`/`Enter`, prefix `]`, and prefix `C-y` to confirm copy/import/paste still work through the wrapper.

## Quick Verify
- Fast checks: `bash -n` on edited Bash scripts, `sh -n` for POSIX scripts, `scripts/shellcheck-dotfiles.bash path/to/file`, and `scripts/shfmt-dotfiles.bash --check path/to/file` for modified shell files; `./bootstrap.sh --dry-run --verbose` for dotfile target-state review.
- Full gate: `test/verify.sh`; it requires `shellcheck` and `shfmt`, then reports checks under static-analysis, linting, and functionality suite headers with parenthesized elapsed time on each completed check line. It runs `scripts/shfmt-dotfiles.bash --all --check` and `scripts/shellcheck-dotfiles.bash --all` before managed-target and startup checks. Multi-line startup probes live under `test/fixtures/verify/`. Add manual smoke tests for touched interactive tools such as Vim when behavior changes.

## Recent Updates (keep last ~15; prune older)
- 2026-05-08 — **Main rebased and shell alias portability fixed:** `main` was
  rebased onto fetched `origin/main`; conflict resolution kept upstream Codex
  plugin entries, replayed the local WSL `resolv.conf` commit, and preserved the
  pre-existing personal Codex config edit after autostash. Live home was
  re-bootstrapped for upstream's new agent symlink targets. `aliases.sh` now
  feature-detects the `alias --` form for the shared `-` alias so dash `/bin/sh`
  startup stays quiet while bash/zsh keep their required option delimiter.
  Full verification passed with temporary `shfmt` v3.13.0 on `PATH`.
- 2026-05-04 — **ShellCheck suppressions localized:** file-specific
  ShellCheck suppressions now live as inline directives in the owning source
  files rather than as a path-specific manifest in `scripts/shellcheck-dotfiles.bash`.
  The wrapper remains responsible for repo scanning, dialect inference, zsh
  skipping, submodule exclusion, and VS Code-compatible argument handling.
- 2026-05-04 — **Agent artifacts regenerated:** prompt artifacts, skill
  artifacts, and digest stamps are present for the current Codex, Claude,
  Cursor Agent, and Gemini `commit-prep` targets after updater-script
  regeneration. The branch is staged and ready for commit after
  `test/verify.sh` passed in 37.0s.
- 2026-05-03 — **Cursor CLI config reconciled:** Cursor Agent CLI config is now
  standardized on `$XDG_CONFIG_HOME/cursor/cli-config.json` through exported
  `CURSOR_CONFIG_DIR`; the repo manages only stable preferences via
  `settings/cursor-agent-cli.sh` plus one self-contained JSON preference patch,
  preserving live auth/cache/state. `cursor-agent.yaml` now maps both `auto` and Cursor's
  self-repaired `default` model id to `composer-2-fast`.
- 2026-05-03 — **Agent script output tightened:** `update-skill.bash`,
  `update-prompt.bash`, and `update-all.bash` now default to concise bracketed
  statuses plus fixed-point summaries, capture successful native harness
  transcripts, and replay those transcripts only on failure or `--verbose`.
  `symlink-skill.bash` and `symlink-all.bash` now print clearer user-facing
  link summaries for the common deployment path.
- 2026-05-03 — **Agent notes pruned to deltas:** shared artifact-production
  and commit-prep rules now live in canonical source prompts/source skills.
  Model notes, skill harness notes, and prompt harness notes are optional and
  should exist only when they add target-specific guidance that should affect a
  prompt or artifact digest.
- 2026-05-03 — **Cursor Auto mapped:** Cursor Agent Free-plan runs can reject
  named models and require `auto`. The harness YAML now maps `auto` to the
  canonical `composer-2-fast` artifact target and discovers the live config at
  `~/.config/cursor/cli-config.json` because this repo sets `XDG_CONFIG_HOME`.
  Headless print mode still requires the runner to pass `--model auto`
  explicitly. Keep the full Cursor config local because it contains
  account/state fields.
- 2026-05-03 — **Manual artifact bootstrap prohibited:** runtime skill
  artifacts, prompt artifacts, and digest stamps must not be manually created,
  patched, or stamped. Missing artifacts are valid pre-bootstrap state; Anthony
  will run the updater scripts from a normal shell so each selected native
  harness authors its own artifacts.
- 2026-05-03 — **Prompt harness notes added then pruned:** both source updater
  prompts support optional prompt-specific `harness-notes/` files.
  `update-prompt.bash` includes a matching note in rendered maintenance prompts
  and prompt artifact input digests when present. After moving shared rules into
  canonical prompt source, only Gemini currently keeps prompt harness notes.
- 2026-05-03 — **Skill harness notes added:** `commit-prep` now has
  skill-specific notes under `agents/skills/src/commit-prep/harness-notes/` for
  Codex, Claude Code, Cursor Agent, and Gemini CLI. `update-skill.bash` includes
  the matching harness note in rendered update prompts and artifact input
  digests, alongside existing model notes and eval fixtures.
- 2026-05-03 — **Prompt artifact infrastructure added:** updater prompts now
  have canonical source under `agents/prompts/src/`, intended harness-specific
  artifacts under `agents/prompts/harnesses/`, and digest stamps under
  `agents/prompts/.update-stamps/`. `update-prompt.bash` maintains prompt
  artifacts, `update-skill.bash` consumes harness prompt artifacts and refreshes
  `update-skill-artifact` when needed, and `update-all.bash` now supports
  `--type prompt` plus `--prompt`. Runtime prompt artifacts and stamps were
  later removed so native harnesses can regenerate them cleanly.
- 2026-05-03 — **Commit-prep model notes refreshed:** Gemini 3.1 Pro Preview
  notes now emphasize direct/outcome-first prompting, high-thinking local
  config, target provenance, and concise final response expectations. Cursor
  Composer 2 Fast notes and canonical `commit-prep` source now keep
  commit-message guidance portable: follow the active repo's documented or
  clearly established convention, falling back to imperative mood when no
  convention is apparent.
  `code_template/AGENTS.md` now uses the same imperative default.
- 2026-05-03 — **Gemini model guidance expanded:** Anthony cached the Gemini 3
  developer guide, Vertex Gemini 3 getting-started guide, and Vertex thinking
  guide alongside the existing Gemini 3.1 Pro model reference. The official-docs
  index now lists these sources, and `agents/models/gemini-3.1-pro-preview.md`
  now captures stronger model guidance for thinking levels, temperature,
  customtools, long context, multimodal/token behavior, and artifact provenance.
- 2026-05-03 — **Gemini harness onboarded:** added `gemini` harness
  YAML/docs, Gemini 3.1 Pro Preview commit-prep model notes, nested
  `model.name` config discovery for symlink deployment, and a
  `home/.gemini/skills/commit-prep` symlink target path. Gemini uses
  `.gemini/skills` rather than `.agents/skills` so it cannot rewrite Codex's
  active `.agents` deployment; same-named `.agents` skills still shadow
  `.gemini` skills in Gemini's documented precedence. Native Gemini generation
  was rerun through the updater-script flow before the branch was prepared for
  commit.
- 2026-05-03 — **Reference-submodule learnings distilled:** inspected the
  pinned Codex, Anthropic skills, Cursor plugins, and Gemini CLI submodules and
  recorded their reusable skill-design lessons in the relevant harness guides,
  model README, skill model-notes, and
  `.context/knowledge/agent-reference-submodules.md`. The distilled guidance is
  ready to inform the next full skill regeneration pass.
- 2026-05-03 — **Agent reference submodules expanded:** `openai/codex` is now
  an optional pinned source snapshot at `agents/official-docs/codex`, checked
  out at tag `rust-v0.128.0` to match local `codex-cli 0.128.0`. Optional
  reference submodules were also added for `anthropics/skills` and
  `cursor/plugins` to provide official skill specs/templates/examples and
  Cursor plugin schemas/examples. The copied Codex web-doc exports remain in
  place because the source repo often contains short link stubs rather than the
  full public docs.
- 2026-05-03 — **Gemini CLI docs moved to submodule:** the copied Gemini docs
  cache was replaced with a shallow, pinned `google-gemini/gemini-cli`
  submodule at `agents/official-docs/gemini-cli`, currently on tag `v0.40.1`
  to match the locally installed `gemini` CLI. Bootstrap and normal verify must
  not require it to be hydrated; hydrate with `git submodule update --init
  --depth 1 agents/official-docs/gemini-cli` when working on Gemini support.
  `home/.gemini/settings.json` now imports the safe local auth setting and pins
  `gemini-3.1-pro-preview` with high thinking for coding work.
- 2026-05-03 — **Submodules excluded from broad shell scans:** `scripts/shell_files.bash` now reads `.gitmodules` paths and excludes them from repo-wide shell syntax, ShellCheck, and shfmt enumeration. `test/verify.sh` has a dedicated guard to catch regressions.
- 2026-05-03 — **Skill-prefix symlink deployment added:** `agents/scripts/symlink-all.bash [skill-prefix]` deploys all runtime skills whose source path is below the given `agents/skills/src/` subtree. The prefix is mutually exclusive with `--skill`, which remains the explicit individual-skill selector.
- 2026-05-03 — **Per-harness config docs de-duplicated:** `claude.md`,
  `codex.md`, and `cursor-agent.md` now point at their adjacent YAML files for
  exact config values instead of mirroring YAML or runner argument snippets.
  `agents/harnesses/README.md` keeps the generic schema example.
- 2026-05-03 — **Harness docs and model aliases reconciled:** newly cached
  Codex docs for advanced/sample config, hooks, memories, slash commands, and
  feature maturity plus Claude Code docs for skills, settings, model config, and
  the docs index are now listed in `agents/official-docs/README.md` and
  reflected in harness guidance. Claude Code's documented `best` and `opus`
  aliases now normalize through `agents/harnesses/claude.yaml` to the canonical
  `claude-opus-4-7` artifact; Codex, Cursor, and Gemini do not currently have
  repo-backed semantic model aliases.
- 2026-05-02 — **Official-doc cache reconciled:** the newly cached Codex
  harness docs, Claude Code CLI/keybinding docs, and Gemini CLI commands doc are
  now listed in `agents/official-docs/README.md`. Codex is no longer recorded
  as uncached for core harness surfaces. Remaining Gemini bring-up docs are
  configuration, `GEMINI.md` context behavior, headless/non-interactive usage,
  CLI reference, skills, and extensions.
- 2026-05-02 — **Skill update runners gained force mode:**
  `agents/scripts/update-skill.bash --force <skill>` and
  `agents/scripts/update-all.bash --force` re-run selected targets on the first
  fixed-point pass even when digest stamps are current, then return to normal
  staleness checks on later passes. `update-skill.bash --force` applies only to
  the default `run-if-stale` action; use `--action run` for a one-shot
  unconditional run.
- 2026-05-02 — **Codex/Claude harness docs expanded:** `agents/harnesses/codex.md`
  now documents Codex skill discovery, progressive disclosure, directory-symlink
  deployment, `agents/openai.yaml`, config precedence, `codex exec`, sandbox
  defaults, and cached core Codex harness docs. `agents/harnesses/claude.md`
  now documents Claude Code skill/frontmatter behavior, settings boundaries,
  print-mode runner behavior, and remaining Claude Code docs to cache.
  Codex skill deployment moved from the older `home/.codex/skills/` path to the
  documented `home/.agents/skills/` path after `codex debug prompt-input`
  verified both plain and symlinked `$HOME/.agents/skills` discovery.
- 2026-05-02 — **Cursor/Composer guidance expanded:** cached Cursor docs are
  now listed as captured in `agents/official-docs/README.md`. Composer 2 Fast
  guidance now incorporates the Composer 2 technical report, Cursor CLI
  automation behavior, Cursor rules/`AGENTS.md` behavior, MCP considerations,
  artifact-production policy, prompt blocks, failure modes, and evaluation
  checks at a depth comparable to the GPT/Claude model guides. Cursor exposes
  both `agent` and `cursor-agent` aliases locally; the repo intentionally uses
  `cursor-agent` as the unambiguous harness id. Runtime artifacts remain stale
  until regenerated through the updater scripts.
- 2026-05-02 — **Runtime artifact editing rule hardened:** project agent
  instructions and agent docs now explicitly forbid hand-editing or directly
  generating runtime skill artifact contents. Artifact changes must flow through
  `agents/scripts/update-skill.bash` or `update-all.bash`; if the selected
  harness cannot run in the current agent environment, leave the artifact stale
  and hand Anthony the exact command to run. This rule is intentionally
  repo-level, not global-agent guidance.
- 2026-05-02 — **Commit-message style clarified:** managed personal Codex
  instructions, project `AGENTS.md`, and canonical `commit-prep` source align
  on using the active repo's documented or clearly established commit-message
  convention first and imperative mood as the default fallback. Runtime
  artifacts are intentionally left for native harness refreshes through the
  updater scripts.
- 2026-05-02 — **Official-doc filenames shortened:** `agents/official-docs/`
  dropped redundant `anthropic-` and `openai-` filename prefixes. The directory
  itself provides the vendor-doc context, while filenames now start with the
  model/product name.
- 2026-05-02 — **Harness runner args use inline arrays:** harness YAML now keeps
  `runner_args` as compact inline YAML arrays while the Bash parser preserves
  one argv entry per item, including quoted spaces/commas. Verification now has
  an explicit harness-config parser check. Because harness configs participate
  in artifact input digests, all current `commit-prep` artifact stamps report
  stale until their native harnesses sign off again.
- 2026-05-02 — **Native harness policy documented:** runtime skill artifacts
  should be maintained through `agents/scripts/update-skill.bash` or
  `update-all.bash` so the target harness adapter, common prompt, output checks,
  and digest stamps are used. Cursor Agent native production uses
  `--sandbox disabled` after Anthony explicitly approved relaxing Cursor's
  unavailable sandbox mode on this machine. Future native Cursor regeneration
  may still be blocked if the active account only permits Auto.
- 2026-05-02 — **Harness model config keys made explicit:** `claude.yaml`,
  `codex.yaml`, and `cursor-agent.yaml` all declare `model_config_key`.
  `symlink-skill.bash` and verify no longer rely on a default `model` key.
- 2026-05-02 — **Official docs disable markdownlint locally:**
  `agents/official-docs/.markdownlint.json` disables all markdownlint rules
  inside the cached vendor-docs tree so copied docs remain authoritative without
  repo lint rewrites. The root `.markdownlintignore` attempt was removed because
  it did not suppress VS Code diagnostics for opened files.
- 2026-05-02 — **Claude signoff blocked by auth:** after updating the Claude
  model guidance, a forced `claude` artifact update was attempted for
  `commit-prep` but Claude Code returned an API 401 authentication error. The
  Claude digest stamps were left stale so the next successful Claude run still
  has to review the Opus 4.6 and 4.7 artifacts.
- 2026-05-02 — **Harness schema moved beside harness configs:** the only
  repo-local JSON schema now lives at `agents/harnesses/harness.schema.json`.
  The separate `agents/schemas/` directory was removed; VS Code YAML schema
  mapping and agent docs now point at the colocated schema.
- 2026-05-02 — **Claude Opus 4.7 docs incorporated:** the cached Anthropic
  extended-thinking and new-features docs now feed the Claude Opus 4.6 and 4.7
  model guides. Both guides prefer adaptive thinking over manual budgets, note
  thinking display defaults/cost tradeoffs, and require preserving thinking /
  redacted-thinking blocks unchanged when continuing tool-use conversations; the
  4.7 guide also records launch specifics for 1M context, 128k output,
  high-resolution images, tokenizer changes, and task-budget semantics.
- 2026-05-02 — **Cursor Agent Composer target added:** `cursor-agent` is now a
  harness backed by `agents/harnesses/cursor-agent.yaml` and
  `cursor-agent.md`. `commit-prep` has a Cursor Agent/Composer 2 Fast runtime
  artifact, stamp, model notes, and deployment symlink under
  `home/.cursor/skills/commit-prep`. Cursor's full `cli-config.json` remains
  local state; repo-home deployment uses explicit `--harness cursor-agent
  --model composer-2-fast`.
- 2026-05-02 — **Claude model ids use harness-native names:** Claude Code
  artifacts, model guides, model notes, stamps, and symlink targets now use
  `claude-opus-4-6` / `claude-opus-4-7`, matching the model ids exposed by
  Claude settings and Anthropic docs. The previous dotted repo-local ids were
  removed; a later narrow `model_aliases` layer handles documented
  harness-native aliases without changing canonical artifact ids.
- 2026-05-02 — **Agent artifact runners are axis-based:** public runner entrypoints are now `agents/scripts/update-skill.bash` and `update-all.bash`, and both support `--harness` and `--model`. `--harness` alone or `--model` alone filters existing artifact directories; passing both creates that explicit harness/model target if missing. Runtime artifacts and stamps now use nested `<harness>/<model>/` paths, and model guides resolve directly from `agents/models/<model>.md` with no provider-prefix mapping. Separate `update-harness.bash` and `update-model.bash` wrappers were dropped to keep the interface small.
- 2026-05-02 — **Harness ids match executables:** the Claude Code harness id is now `claude`, matching the `claude` executable. Claude runtime artifacts, stamps, and the harness adapter moved from `claude-code/...` to `claude/...`; docs still use "Claude Code" when referring to the product.
- 2026-05-02 — **Harness behavior moved to YAML configs:** supported harnesses are now discovered from `agents/harnesses/<harness>.yaml`, with `<harness>` matching the executable name. The YAML config owns runtime output paths and runner args; `<harness>.md` remains the agent-facing guidance file. Missing harness prompts are now scoped to selected artifacts instead of a static global harness list.
- 2026-05-02 — **Skill symlink runners added:** `agents/scripts/symlink-skill.bash` and `symlink-all.bash` deploy runtime artifacts into selected home trees. Harness YAML now records `home_config`, `skills_dir`, and explicit `model_config_key`; without explicit `--harness --model`, symlink runners inspect the selected home tree to discover the configured target model.
- 2026-05-02 — **Nested skill source directories supported:** source skills are discovered as any directory below `agents/skills/src/` that contains `SKILL.md`. `update-skill.bash` accepts either a globally unique skill directory name or a `src`-relative path, while runtime artifacts/stamps still use the skill directory name as `<skill>` and reject duplicate names.
- 2026-05-02 — **Source metadata file removed:** source `SKILL.md` frontmatter is now the canonical source of skill identity. The separate source `metadata.yaml` and its schema were removed, and Codex `agents/openai.yaml` reification should derive UI fields from the source skill frontmatter/body.
- 2026-05-02 — **Skill-row updater creates missing artifacts:** `agents/scripts/update-skill.bash <skill>` now discovers existing harness/model artifact directories under `agents/skills/artifacts/` instead of only directories that already contain that skill. This makes the new-skill workflow fan out to all existing targets by default.
- 2026-05-02 — **Official docs renamed with model context:** cached vendor docs under `agents/official-docs/` now include the relevant model-release context in their filenames. Anthropic rolling guides are tagged with Claude Opus 4.7 because that was the latest model release at capture time; OpenAI GPT-5.5 guides keep direct model-specific names. The document bodies were not edited; only filenames and index docs changed.
- 2026-05-02 — **All-artifacts matrix runner added:** `agents/scripts/update-all.bash` discovers existing harness/model artifact directories, supports `--harness` and `--model`, intentionally omits skill filters so the command can remain a whole-surface updater, and repeats matrix passes until the source/artifact/stamp input digest is stable.
- 2026-05-02 — **Artifact parser errors clarified:** `update-skill.bash` now separates unsupported harness/model paths, missing model segments, and unsupported models. Unknown models fail against the missing model guide and list supported models discovered from `agents/models/`.
- 2026-05-02 — **Skill artifact stamps mirror artifact paths:** input digest stamps moved from the earlier flat artifact stamp shape to `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/inputs.sha256`. The skill runner still owns stamp writes; aggregate runners update stamps only by invoking that path.
- 2026-05-02 — **Agent runners use Bash suffixes:** repo-local agent runner entrypoints use `.bash` suffixes, currently `agents/scripts/update-skill.bash` and `update-all.bash`. Diagnostics derive from the invoked script name.
- 2026-05-02 — **Native harness production uses local configuration:** after installing `claude`, `commit-prep`'s Claude Opus 4.6 artifact was reviewed by Claude Code with no content edits needed, and Claude Code generated `agents/skills/artifacts/claude/claude-opus-4-7/skills/commit-prep/SKILL.md`. The updater invokes native harnesses without target-model CLI overrides; Claude Code uses `--permission-mode acceptEdits -p`, while Codex uses local configuration through `codex exec --ephemeral --cd ... --sandbox workspace-write`. This is a general policy for all harnesses, not a Claude-specific rule.
- 2026-05-01 — **Multi-model skill vertical slice validated:** `commit-prep` now has canonical source, model notes, an eval fixture, and a Codex/GPT-5.5 runtime artifact. The active Codex deployment now points from `home/.agents/skills/commit-prep` to `agents/skills/artifacts/codex/gpt-5.5/skills/commit-prep`. `agents/scripts/update-skill.bash` updates selected artifacts for one skill and records digests under `.update-stamps/`. Full `test/verify.sh` passed in 22.0s.
- 2026-05-01 — **Claude Code sidecar shape corrected:** Claude Code skill artifacts intentionally contain only `SKILL.md`; Codex's `agents/openai.yaml` is not portable metadata. The artifact updater now creates output directories from each harness adapter's configured output files, so `print-prompt` no longer recreates an empty `agents/` directory under Claude artifacts. Digest stamps were refreshed after verifying runtime outputs did not need content changes.
- 2026-05-01 — **Claude Code skill artifact added:** `commit-prep` now has `agents/skills/artifacts/claude/claude-opus-4-6/skills/commit-prep/SKILL.md`, deployed through `home/.claude/skills/commit-prep`. `home/.claude/settings.json` pins Claude Code's initial model to `claude-opus-4-6`, and the Claude skill frontmatter also sets `model: claude-opus-4-6`. This machine does not have `claude` on PATH, so real Claude Code discovery of the symlinked directory still needs smoke testing elsewhere.
- 2026-05-01 — **Artifact digest stamps moved out of runtime skills:** `.update-inputs.sha256` files were replaced by `agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/inputs.sha256`, keeping deployed runtime artifact directories free of build/maintenance artifacts while preserving self-contained skill packages.
- 2026-05-01 — **Agent harness preflight added:** production update runs prompt to skip selected targets requiring missing native harnesses or select an installed runner-capable fallback harness; non-interactive runs default to skip so verification does not hang. A planned task tracks adding full production support for additional harness artifacts.
- 2026-04-29 — **Commit-prep reload validation passed:** after restarting the session, the current `commit-prep` skill metadata/body was available and used for this commit-prep pass. The full dirty tree is staged, with no unstaged or untracked files at the time of prep.
- 2026-04-29 — **Skill-specific model notes split out:** `agents/models/` is kept generic by model, while per-skill model notes now live beside each source skill under `model-notes/`. `commit-prep` has GPT-5.5 notes plus future Claude Opus 4.7/4.6 notes without retuning the runtime skill for Claude yet.
- 2026-04-29 — **Commit-prep scope corrected:** `commit-prep` now treats the full dirty tree as default scope regardless of staged state. Staging remains user-owned review state and must be preserved exactly; staged-only/path-limited commit messages are only for explicit user-narrowed scope.
- 2026-04-29 — **Model guidance refreshed against cached docs:** GPT-5.5 guidance now records source-backed versus creative drafting boundaries and image/detail implications for UI work. Claude Opus 4.7 and 4.6 guidance now better capture Anthropic's agentic-system advice around continuation state, file-grounded codebase claims, temporary scaffolding, subagent/tool restraint, and computer-use image fidelity. Official docs under `agents/official-docs/` were not edited.
- 2026-04-29 — **Anthropic official docs cached:** `agents/official-docs/` now includes Anthropic prompting and Opus 4.7 migration docs alongside OpenAI GPT-5.5 migration/prompting. `agents/models/` remains the place for repo-authored interpretations and examples.
- 2026-04-28 — **Agent docs split established:** `agents/official-docs/` is the authoritative cache for copied vendor docs, while `agents/models/` holds repo-authored interpretations and examples. `commit-prep` was retuned for GPT-5.5 around outcome-first instructions, explicit git-index invariants, success criteria, verification, and final response shape.
- 2026-04-28 — **Codex skill source layout established:** repo-managed agent skills live outside `home/`, with per-harness deployment paths represented as symlink nodes under `home/` such as `home/.agents/skills/commit-prep`. Codex did not discover a skill when only individual files such as `SKILL.md` were symlinked, but a fresh prompt does discover the two-hop directory symlink layout. The current target of that symlink is the Codex/GPT-5.5 runtime artifact.
- 2026-04-28 — **Kubeconfig stays local:** do not manage `home/.kube/config`; kubeconfigs are state/config hybrids and commonly gain credentials, cluster entries, exec auth config, and current-context changes. If tools such as the VS Code Kubernetes extension need `~/.kube/config` to exist, create a local empty placeholder outside the repo and merge real configs with `KUBECONFIG`.
- 2026-04-28 — **iTerm2 Solarized Dark profile added:** bootstrap now symlinks `home/Library/Application Support/iTerm2/DynamicProfiles/solarized-dark.json` into iTerm2's watched dynamic-profile directory. The managed profile is named `Solarized Dark (dotfiles)`, inlines canonical Solarized colors, disables bright-bold color substitution, and sets minimum contrast to zero. Dynamic profiles cannot reliably mark themselves as default, so `settings/iterm2.sh` writes iTerm2's `Default Bookmark Guid` to the managed profile GUID. Because this path contains `Application Support`, bootstrap manifests/state now use tab-separated records so managed paths with spaces round-trip correctly.
- 2026-04-28 — **iTerm2 tmux profile inheritance configured:** `settings/iterm2.sh` also writes `TmuxUsesDedicatedProfile=false`, matching iTerm2's documented behavior where control-mode tmux sessions inherit the profile of the session that ran `tmux -CC` instead of using iTerm2's special `tmux` profile. The local `tmux` profile was inspected and is effectively a copy of `Default` with no functional tmux-specific differences beyond `Has Hotkey=false`; Anthony confirmed this fixes `tmux -CC` Solarized colors.
- 2026-04-28 — **iTerm2 verification kept lightweight:** removed the shallow iTerm2 dynamic-profile parser check from `test/verify.sh`; bootstrap convergence still verifies the managed file is linked into iTerm2's watched directory, and iTerm itself remains the meaningful profile loader/validator.
- 2026-04-28 — **WSL clipboard provider added:** `dotfiles-clipboard` now detects WSL through standard environment/proc markers, uses `clip.exe` for copy, and uses PowerShell `Get-Clipboard -Raw` for paste with carriage-return stripping. Fake WSL clipboard fixtures verify provider detection, copy fidelity, and CRLF-to-LF paste normalization. `win32yank` was rejected as the default WSL provider because the Microsoft-native bridge is simple, first-party, and directly testable.
- 2026-04-28 — **tmux control-mode options made conditional:** normal tmux startup keeps `focus-events` and `aggressive-resize` on, while the shell `tmux` wrapper marks `tmux -CC` with `DOTFILES_TMUX_CONTROL_MODE=1` and pre-disables both settings for existing servers before iTerm2 attaches. `home/.tmux.conf` and `dotfiles-tmux-control-mode-options` then keep both settings off while any control-mode client is attached and restore them when only normal clients remain. Verification covers normal startup, marked control-mode startup, and both helper branches.
- 2026-04-28 — **iTerm2 tmux control-mode guard investigated:** `aggressive-resize` must be managed with `setw -g` because it is a window option, and iTerm2 control-mode focus bells come from `focus-events`, not tmux's normal bell settings. Keep `bell-action any` and `monitor-bell on`; broad bell suppression did not solve the focus bell and would remove useful real bell behavior.
- 2026-04-28 — **tmux upstream bug draft saved:** `.context/scratch/20260428-tmux-selection-mode-line-bug/report.md` captures the full upstream issue draft for tmux `selection-mode line` lazily applying and clobbering the selection anchor row. Current config is considered correct: fresh `V` uses `select-line` as a workaround, while mid-selection switches to `V` remain blocked on upstream tmux behavior. The upstream bug task is deferred until after tmux plugin evaluation; `.context/knowledge/tmux.md` records the repo migration plan for when tmux is fixed.
- 2026-04-28 — **tmux config paused:** tmux configuration is considered done for now. Anthony is interested in eventually evaluating TPM and plugins such as resurrect/continuum, but only at the very end after Neovim has been considered; no tmux plugin manager is being introduced in this pass.
- 2026-04-28 — **Verify runtime reduced:** startup smoke tests now batch unsupported fzf, unsupported generated-completion, and tmux wrapper edge cases into one bootstrapped temp home and one shell launch per shell. The zsh vi-mode pty operator fixture lowers test-only `KEYTIMEOUT` and uses short ZLE settle waits instead of fixed 0.1s/0.5s sleeps. On the current machine, full verify dropped to about 20s, with startup smoke around 6.75s and zsh operator smoke around 8.64s.
- 2026-04-28 — **tmux line-mode workaround backed out:** removed the `other-end` endpoint-bounce repaint attempt from copy-mode selection switching after it broke `V` / line selection flows. Keep the simpler selection-mode plus `refresh-client` approach unless a tmux-native repaint mechanism is found.
- 2026-04-28 — **Verify timing added:** `test/verify.sh` now wraps each suite check with Bash `time`, prints each check name as it starts, then appends parenthesized elapsed time on the same line after completion. Passing check output is suppressed to keep the short view clean; failed check output is replayed after the failed timing line. Durations render as milliseconds under one second and seconds for longer checks.
- 2026-04-27 — **tmux ergonomics extended:** tmux now explicitly sets vi prompt keys, focus events, cwd-preserving new-window/split bindings, prefix `R` config reload, noted custom bindings for prefix `?`, and Vim-like copy-mode selection toggles plus half-page keys. New panes prefer interactive login zsh, then interactive login Bash, then tmux's default login-shell behavior. Interactive shells wrap plain `tmux` as `tmux new-session -A -s default` while preserving all argument-bearing tmux subcommands. Top/bottom splits moved to prefix `-` so prefix `s` remains tmux's session chooser. VS Code now recommends the tmux, Bash IDE, markdownlint, and ShellCheck extensions for this repo.
- 2026-04-27 — **tmux clipboard integration complete for v1:** tmux copy-mode and prefix clipboard paths now route through `dotfiles-clipboard-tmux`, which keeps `.tmux.conf` readable, requires `tmux` for functional subcommands, shares import logic between `import` and `paste`, and preserves native tmux buffers when no platform clipboard provider is available.
- 2026-04-27 — **zsh Backspace clipboard regression fixed:** zsh no longer globally replaces `vi-delete-char` / `vi-backward-delete-char`; insert-mode Backspace stays native and does not copy one-character edits to the platform clipboard. Vicmd `x` / `X` are bound to private clipboard-aware wrappers instead.
- 2026-04-27 — **zsh mid-command Backspace/Delete fixed:** vi insert-mode Backspace now uses `backward-delete-char` for both `^?` and `^H`, while Delete uses `delete-char` via `^[[3~`; after `Esc`, motion, and `i`, both directions edit normally without touching the platform clipboard.
- 2026-04-27 — **zsh paste highlight disabled:** zsh now sets `zle_highlight` with `paste:none` so bracketed paste text does not appear with temporary selected/standout styling at the prompt.
- 2026-04-27 — **Bash paste highlight disabled:** Bash now sets Readline `enable-active-region off`, keeping bracketed paste enabled while preventing pasted prompt text from appearing temporarily selected.
- 2026-04-27 — **Bash/zsh cursor policy aligned:** Bash now uses Readline vi mode strings for the same cursor policy as zsh: steady beam in insert/default mode and steady block in command mode. The previous WSL-only startup block cursor override was removed.
- 2026-04-27 — **VS Code ShellCheck zsh noise suppressed:** VS Code now ignores zsh globs for ShellCheck because ShellCheck does not support zsh; repo verification still runs `zsh -n` for zsh syntax and keeps wrapper-level zsh skips.
- 2026-04-27 — **tmux clipboard bindings completed for v1:** copy-mode `y` and `Enter` now copy selections to both tmux's automatic paste buffer and `dotfiles-clipboard copy`; prefix `]` imports `dotfiles-clipboard paste` into a new automatic tmux buffer before native bracketed paste, falling back to native tmux paste when unsupported; prefix `C-y` imports clipboard text into the latest automatic tmux buffer without pasting. Prefix `p` remains `previous-window`.
- 2026-04-27 — **tmux clipboard helper added:** `dotfiles-clipboard-tmux copy|import|paste` now owns tmux-specific provider checks, unsupported-provider fallbacks, and temporary-file buffer imports so `.tmux.conf` can keep clipboard integration as readable bindings.
- 2026-04-27 — **tmux config cleaned:** tmux config reloads cleanly on tmux 3.6a; it now advertises `tmux-256color`, uses modern `status-style`, sets window options through `setw`, renumbers 1-based windows, lowers `escape-time` for Vim/vi-mode responsiveness, and intentionally keeps prefix `C-b` mapped to `last-window` instead of `send-prefix`. Nested tmux is not a supported workflow. `set-clipboard`/OSC 52 remains deferred so clipboard integration has one path through `dotfiles-clipboard`.
- 2026-04-27 — **zsh CUTBUFFER sync widened:** zsh now wraps delete/change/substitute CUTBUFFER-producing widgets (`d`, `c`, `C`, `D`, `S`, `s`, `x`, `X`) in addition to yanks, so paste-time clipboard refresh does not replace just-deleted text with stale system clipboard content. Visual `put-replace-selection` also refreshes from the wrapper before replacing the prompt selection.
- 2026-04-27 — **zsh/tmux clipboard wiring added:** zsh wraps explicit vi yanks to copy `CUTBUFFER` through `dotfiles-clipboard`, refreshes `CUTBUFFER` from the wrapper before vi paste widgets, and caches unsupported providers as quiet no-ops. tmux copy-mode `y` now uses `copy-pipe-and-cancel` so selections still land in tmux's paste buffer while supported providers receive the system clipboard copy. Verification uses fake supported/unsupported clipboard fixtures.
- 2026-04-27 — **macOS clipboard wrapper added:** `home/.local/bin/dotfiles-clipboard` now provides `copy`, `paste`, and `status` with a tested macOS `pbcopy` / `pbpaste` backend. WSL/Windows support is next; Linux desktop providers and OSC 52 are deferred.
- 2026-04-27 — **Command lookup helpers added:** shared shell config now exposes `dotfiles_have_command` for output-suppressed command availability checks and `dotfiles_command_succeeds` for quiet command capability probes. Repo dev tooling uses its own `dotfiles_have_command` helper, leaving raw `command -v` for cases that need the resolved path.
- 2026-04-27 — **Bootstrap Git dependency removed:** `bootstrap.sh` now derives managed home paths from the checked-out `home/` filesystem tree instead of `git ls-files`. Verification covers normal temp-home bootstrap apply without asserting that specific external commands are absent.
- 2026-04-27 — **vim-plug submodule removed:** `home/.vim/autoload/plug.vim` is now a tracked loader snapshot, `lib/vim-plug` and `.gitmodules` are removed, and bootstrap no longer has submodule hydration logic.
- 2026-04-27 — **Vim directory reified:** `home/.vim` is now a real tracked directory containing only the `autoload/plug.vim` snapshot; bootstrap will create a real local `~/.vim` and link managed files inside it, leaving plugin clones local under `~/.vim/plugged/`.
- 2026-04-27 — **make-chrome-app removed:** the stale `lib/make-chrome-app` submodule, managed `~/.local/bin/make-chrome-app` command, and root-level `bin/make-chrome-app` symlink were removed. Chrome's current web-app/PWA install flow covers the normal use case; `vim-plug` remains for separate discussion.
- 2026-04-27 — **Zsh `ae` operators fixed:** the custom whole-buffer text object now follows zsh's text-object endpoint pattern so `dae`, `yae`, `cae`, and `vae` work, and fzf's `Alt-C` binding is removed from zsh vi keymaps so `Esc` then `c...` operators are not stolen. Verification now includes a pty-backed zsh vi operator fixture.
- 2026-04-27 — **Clipboard plan captured:** Vim anonymous-register behavior appears good. Future clipboard work should start with zsh explicit yanks syncing `CUTBUFFER` to clipboard, zsh paste-time clipboard refresh into `CUTBUFFER`, and tmux copy-mode `y` copying to both tmux buffer and system clipboard. Smaller zsh delete/change sync can be considered only after that works.
- 2026-04-27 — **Core vi mode wrapped:** Anthony confirmed the non-clipboard vi-mode behavior works well. Clipboard/register unification is intentionally split to the next branch so Vim anonymous-register behavior and zsh `CUTBUFFER`/yank behavior can be designed together.
- 2026-04-27 — **Zsh vi-mode helpers extended:** zsh now uses cursor-shape hooks for mode feedback, `hjkl` inside `zsh/complist` menu selection, whole-buffer `ae`, quote/bracket text objects via `select-quoted` / `select-bracketed`, and zsh's shipped `surround` helper with `cs`/`ds`/`ys`/visual `S`.
- 2026-04-26 — **Ctrl-E editor handoff added:** Bash vi insert/command maps now bind `Ctrl-E` to Readline's command editor, and zsh vi insert/command maps bind `Ctrl-E` to `edit-command-line`, leaving zsh `Esc` then `v` visual mode intact.
- 2026-04-26 — **Ghostty Ctrl-[ legacy behavior restored:** managed Ghostty config now maps `Ctrl-[` / `ctrl+bracket_left` to raw Escape (`text:\x1b`) so vi/readline shell workflows do not receive Ghostty's CSI-u/fixterms sequence.
- 2026-04-26 — **ShellCheck wrapper cwd independence fixed:** dev-tool wrappers now derive the repo root from their own script path instead of the caller cwd/git context, and `test/verify.sh` checks `shellcheck-dotfiles.bash -V` from `/` to cover VS Code's version probe.
- 2026-04-26 — **Index ownership clarified:** managed global Codex instructions now say not to unstage files unless explicitly asked, because Anthony may stage files while reviewing agent work.
- 2026-04-26 — **Zsh named widgets exposed:** zsh now autoloads and registers selected shipped ZLE helper functions (`edit-command-line` and `history-beginning-search-menu`) so `execute-named-cmd` can find them without stealing default vi-mode bindings.
- 2026-04-26 — **Fzf generator compatibility guarded:** Bash and zsh now run `fzf --bash` / `fzf --zsh` only as capability-checked generators. Older fzf builds, including WSL/distro packages that print `unknown option: --zsh` or `unknown option: --bash`, are skipped quietly; verification now covers this with a fake unsupported fzf on PATH.
- 2026-04-26 — **Generated completion guards generalized:** Bash and zsh command-generated completion helpers now require the generator command to succeed and emit non-empty output before `eval`. Startup fixtures only require generated completions for installed tools when the matching generator subcommand is supported; verification covers this with a fake unsupported `docker` on PATH.
- 2026-04-26 — **Zsh Ctrl-R fallback fixed:** zsh now binds `Ctrl-R` in insert mode to native `history-incremental-search-backward` before tool support loads. Supported fzf can still override it with `fzf-history-widget`, but unsupported fzf no longer leaves `Ctrl-R` as zsh vi mode's default `redisplay`.
- 2026-04-26 — **Zsh completion presentation trial added:** zsh now loads `zsh/complist`, keeps completion lists colored/verbose/grouped/described, colors group/message/warning headings, lists directories first, and starts menu selection only for ambiguous matches via `zstyle ':completion:*' menu select=2`. Startup verification asserts the presentation styles and complist module.
- 2026-04-26 — **History timestamp policy selected:** Bash now uses `HISTTIMEFORMAT='%F %T '`, zsh enables `EXTENDED_HISTORY`, and zsh wraps `history` around `fc -l -D -t '%F %T'` for timestamp plus elapsed-duration display (`<1s`, `1s`-`9s`, then native `M:SS`). Bash also pins `checkwinsize`. `HISTCONTROL` remains unset by choice.
- 2026-04-26 — **Line-editor defaults added:** Bash and zsh now bind Up/Down to prefix history search and use native case-/hyphen-insensitive completion matching. `zoxide`, Bash `magic-space`/`histverify`, OMZ history-substring-search, autosuggestions, syntax highlighting, autocomplete, and broad keybinding tables are explicitly declined for now.
- 2026-04-26 — **Tool-support layer renamed:** shell-specific completion loaders were renamed to `tool-support.bash` and `tool-support.zsh`, then fzf was folded into that layer alongside command-generated completion support. Bash and zsh now source installed `fzf --bash` / `fzf --zsh` integration when `fzf` exists, with no repo opt-out; the zsh wrapper filters fzf's known immutable-`zle` restore warning.
- 2026-04-26 — **Commit-message support-work guidance clarified:** managed `home/.codex/AGENTS.md` now says routine docs/context and test-update bullets should be omitted from mixed feature commit messages because that support work is assumed.
- 2026-04-26 — **Codex and git-spice completion fallbacks added:** added guarded command-generated completions for Codex and git-spice in Bash and zsh. The `gs` alias is now explicitly bound to git-spice completion when `gs` is aliased to `git-spice`, overriding zsh's stock Ghostscript completion only in that alias case.
- 2026-04-26 — **Docker completion fallback added:** added guarded Docker generated completions to Bash and zsh startup. Bash still lets bash-completion register framework/snippet completions first via `complete -p docker`, and zsh still lets native/Homebrew functions win via `_comps[docker]`. tmux and Vim remain system-owned because tmux lacks a first-party generator, Homebrew supplies Bash tmux snippets, and zsh ships `_tmux` / `_vim`.
- 2026-04-26 — **Working memory moved to `.context`:** renamed repo and template working-memory directories from `context/` to `.context/`, then updated AGENTS, README, settings, and template references to match the hidden directory.
- 2026-04-26 — **Commit-message guidance tightened:** managed `home/.codex/AGENTS.md` and project `AGENTS.md` were tightened around tense, sentence-style capitalization, and omitting routine documentation/context/test bullets from mixed feature commit messages. This was later superseded by the imperative-mood default recorded above.
- 2026-04-26 — **RC local hooks target-aligned:** renamed the interactive rc override hooks from `.sh_local` / `.bash_local` / `.zsh_local` to `.shrc_local` / `.bashrc_local` / `.zshrc_local`, matching the managed startup files that source them. Profile-level hooks remain `.profile_local`, `.bash_profile_local`, and `.zprofile_local`.
- 2026-04-26 — **Startup fixtures fail on assertion errors:** `test/verify.sh` now enables `errexit`/`ERR_EXIT` before sourcing startup fixtures so bare assertion commands reliably fail the suite. This exposed zsh's predefined `HISTSIZE=2000`, so `home/.config/zsh/rc.zsh` now pins the repo's intended `HISTSIZE`/`SAVEHIST` defaults before `.zshrc_local` can override them.
- 2026-04-26 — **System-first completion pass:** added Bash and zsh completion loaders for Homebrew/package-manager completions, kept Git's active-install fallback, and added generated `gh`/`kubectl` completions when those commands exist. Bash treats an already-loaded framework as authoritative, then tries Homebrew formula prefixes, optional `pkg-config`, and conventional Ubuntu/Debian-style paths before installing guarded fallbacks. Zsh now prepends Homebrew site-functions before `compinit`, adds active-Git fallback only when no `_git` is visible in `fpath`, and uses generated completions only when `_comps[command]` is absent.
- 2026-04-26 — **Verify output grouped by suite:** `test/verify.sh` still runs linearly and fails fast, but now prints suite headers for static analysis, linting, and functionality with indented check names for easier scanning.
- 2026-04-26 — **Shell formatting added to verify:** `test/verify.sh` now requires `shfmt` and runs `scripts/shfmt-dotfiles.bash --all --check` as part of the full gate, so shell formatting drift is caught before commit/pre-commit time.
- 2026-04-26 — **Shell dev-tool discovery centralized:** added `scripts/shell_files.bash` as the Bash-only discovery/dialect helper for repo-local shell tools. `test/verify.sh`, `scripts/shellcheck-dotfiles.bash`, and `scripts/shfmt-dotfiles.bash` now share it; POSIX deployment discovery remains separate in `scripts/home_tree_manifest.sh`.
- 2026-04-26 — **ShellCheck required in verify:** `test/verify.sh` now requires ShellCheck and runs the repo-aware `scripts/shellcheck-dotfiles.bash --all` phase. The wrapper discovers tracked shell files, skips zsh files that ShellCheck cannot parse, and centralizes narrow false-positive suppressions for sourced fragments.
- 2026-04-25 — **OMB branch absorbed zsh stack:** rebased `feature/oh-my-bash-inspiration` onto the former `feature/zsh` head, resolved the VS Code ShellCheck settings conflict by keeping both ignore patterns and the wrapper path, deleted the local `feature/zsh` branch through git-spice, and confirmed `test/verify.sh` passes.
- 2026-04-25 — **VS Code ShellCheck tuned for dotfiles:** added repo-local `.vscode/settings.json` to opt sh/bash/zsh startup files back into the ShellCheck extension, plus `.shellcheckrc` suppressions for sourced dotfiles without shebangs and dynamic `$HOME` source paths.
- 2026-04-25 — **Project markdownlint preferences:** added repo-root `.markdownlint.json` to disable MD013, MD022, MD029, and MD032 project-wide while keeping the MD034 exception scoped to `.context/`. MD029 was made project-wide because the only clean path-scoped markdownlint mechanism would require placing config under `home/`, whose filesystem layout is bootstrap data.
- 2026-04-25 — **Context markdownlint exception:** added explicit `.context/.markdownlint.json` and `code_template/.context/.markdownlint.json` rule disables for committed `.context` trees, including MD034 where raw URLs are often useful as references.
- 2026-04-25 — **Verify discovers generic test surfaces:** `test/verify.sh` now derives managed target expectations from `scripts/home_tree_manifest.sh` and discovers shell syntax checks from the repo tree by extension/shebang, keeping only a small mapping for extensionless startup files.
- 2026-04-25 — **Tests moved out of scripts:** moved the verification entrypoint to `test/verify.sh` and shell startup fixtures to `test/fixtures/verify/`; `scripts/` is now reserved for bootstrap-support helpers and small repo tools.
