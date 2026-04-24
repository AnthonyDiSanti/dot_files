# Decisions

Decider format: `Anthony` for human decisions, `Codex (model: gpt-5.2-codex)` for agent decisions.
Keep newest decisions at the top (reverse chronological order).

## 2026-04-24 — Replace chezmoi with a repo-native home tree
- Decider: Anthony
- Decision: Remove chezmoi entirely. Keep `home/` as a literal `$HOME` mirror, use the tracked `home/` tree itself as the deployment manifest, and let `bootstrap.sh` compute managed directories/leaves directly from Git-tracked paths via `scripts/home_tree_manifest.sh`. Use real symlink nodes in the repo where needed: vendored helpers now live at paths such as `home/.config/bash/git-prompt.sh`, and the whole-directory Vim case is represented as `home/.vim` -> `../managed/vim`.
- Rationale: The repo already wanted live-update symlink semantics, and chezmoi’s source-state encoding (`dot_`, `private_`, `symlink_*.tmpl`, `.chezmoiroot`) had become more indirection than value. A literal home tree is easier to read, easier to reason about, and keeps the repo layout aligned with the deployed filesystem shape.
- Consequences / follow-ups: `bootstrap.sh` now requires `git`, keeps a managed-path state file under `~/.local/state/dotfiles/managed-paths`, and uses that to clean up stale targets after deployment-shape changes. `scripts/verify.sh` now validates the repo-native managed-path list instead of chezmoi state. Prefer real symlink nodes and the `managed/` directory over reintroducing template-based target indirection unless a concrete new need appears.

## 2026-04-23 — Default shell internals to XDG config/state paths
- Decider: Anthony
- Decision: Keep the standard shell entrypoints in `$HOME` (`.profile`, `.shrc`, `.bashrc`, `.zshrc`, etc.) for compatibility, but default the internal shell/runtime config to `XDG_CONFIG_HOME` and shell history/state to `XDG_STATE_HOME`. Concretely, `home/.config/shell/paths.sh` now exports default XDG base-dir variables and derives unexported internal `dotfiles_*` path variables, managed bash/zsh config is sourced through that internal path layer, and bash/zsh history files live under `~/.local/state/{bash,zsh}/history` unless overridden.
- Rationale: The home-directory entrypoints are still the right compatibility boundary for login and interactive shells, but the internals behind them do not need to keep hardcoding `~/.config` or state files like shell history in `$HOME`. Separating exported `XDG_*` vars from the shell's internal resolved `dotfiles_*` layer keeps path policy centralized and gives future flexibility without leaking extra globals to child processes.
- Consequences / follow-ups: Continue treating `$HOME` shell wrappers as compatibility shims into the real managed config under `XDG_CONFIG_HOME`. Prefer `XDG_CACHE_HOME` / `XDG_STATE_HOME` for shell-generated runtime artifacts such as completion caches and history files, but route shell-internal path lookups through `dotfiles_*` vars rather than sprinkling raw XDG fallback logic everywhere. `scripts/verify.sh` now asserts the default XDG env vars, internal path vars, and history locations in both bash and zsh startups.

## 2026-04-23 — Keep interactive shell internals native to bash vs zsh
- Decider: Anthony
- Decision: Share portable shell policy and helpers through `home/.config/shell/`, but keep prompt/completion/hook internals native to each interactive shell. Concretely, continue to share PATH/editor/pager defaults, aliases, and portable helper functions across shells, while keeping `PROMPT_COMMAND`/`__git_ps1` logic in bash and `precmd`/`compinit`/native prompt escapes in zsh.
- Rationale: The useful overlap between bash and zsh is at the policy/helper level, not at the prompt/completion mechanism level. Forcing a shared abstraction over shell-specific hooks and prompt semantics would add indirection without buying much reuse, and would make the zsh setup feel more like “bash compatibility mode” than a first-class zsh configuration.
- Consequences / follow-ups: Treat the current shared `shell/` layer as the portability boundary. Prefer zsh-native solutions for future interactive work rather than trying to route new features through shared bash/zsh helper shims. Bash can remain stable/legacy unless a change clearly benefits both shells.

## 2026-04-22 — Split shell language roles by use case
- Decider: Anthony
- Decision: Use POSIX `sh` for deployment-critical bootstrap paths, `bash` for repo-local dev automation, and `zsh` as the interactive shell that receives ongoing UX investment. Concretely, keep `bootstrap.sh` POSIX `sh`, keep `scripts/verify.sh` in bash, and continue the prompt/completion migration work in zsh.
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
- Decision: Ship **`home/.config/ghostty/config`** so bootstrap symlinks **`~/.config/ghostty/config`**. Use canonical Solarized Dark hex (upstream Xresources ANSI mapping), **`alpha-blending = native`** (Display P3 compositing on macOS per Ghostty docs), **`palette-generate = true`** so indices 16–255 derive from the base-16 Solarized palette, and **`macos-titlebar-style = transparent`** so title chrome matches base03. Extend **`scripts/verify.sh`** with managed paths and a temp-home symlink assertion for Ghostty.
- Rationale: No need to restore the **altercation/solarized** submodule for terminal chrome; Ghostty’s own options cover wide-gamut blending and a cohesive 256-color ramp. Document **`linear-corrected`** in-config as an optional tweak if fringe artifacts appear.
- Consequences / follow-ups: Reload Ghostty after apply (**Cmd+Shift+,**). Linux gets **`native`** as sRGB per Ghostty (still explicit and consistent).

## 2026-04-21 — Remove unused `settings/solarized` submodule
- Decider: Anthony
- Decision: Delete the **`settings/solarized`** git submodule (full **altercation/solarized** checkout). Replace with documentation: **`settings/README.md`** and **`context/knowledge/solarized.md`** pointing to upstream for Terminal/iTerm/Ghostty/Xresources needs. **Vim** remains **`lifepillar/vim-solarized8`** via vim-plug; **tmux** styling stays in **`home/.tmux.conf`**.
- Rationale: Nothing in bootstrap or scripts referenced the submodule (~19MB, 600+ files). It duplicated the old Vim bundle under `vim-colors-solarized/` and confused “vendored Solarized” vs the active vim-plug theme. Clone upstream on demand when configuring non-Vim apps.
- Consequences / follow-ups: `git clone --recurse-submodules` no longer pulls Solarized; **AGENTS.md** and `context/` updated.

## 2026-04-21 — Use Solarized 8 for true-color terminal Vim
- Decider: Anthony
- Decision: Replace **altercation/vim-colors-solarized** with **lifepillar/vim-solarized8**; load **`colorscheme solarized8`**. Enable **`termguicolors`** when `has('termguicolors')`, and set **`t_8f` / `t_8b`** per `:help xterm-true-color`. Remove the old **`g:solarized_termcolors`** hack and the **`ColorColumn`** `ctermfg=Red` override (the scheme styles `ColorColumn`). In **tmux**, set **`terminal-features ',*:RGB'`** so nested Vim receives true color.
- Rationale: Original Solarized does not define `guifg`/`guibg` for terminal Vim, so **`termguicolors`** cannot apply canonical hex colors; Solarized 8 is maintained for true-color and 256/16 fallbacks.
- Consequences / follow-ups: Run **`:PlugInstall`** to swap plugins; **reload tmux** after pulling `dot_tmux.conf`. On hosts where true color fails, **`set notermguicolors`** then **`:colorscheme solarized8`** (documented in README and `context/knowledge/vim.md`).

## 2026-04-21 — Use vim-plug with tracked submodule loader
- Decider: Anthony
- Decision: Manage plugins with **vim-plug**: add `lib/vim-plug` as a **git submodule**, symlink `managed/vim/autoload/plug.vim` → `../../../lib/vim-plug/plug.vim`, and use `call plug#begin('~/.vim/plugged')` in `home/.vimrc`. Ignore `~/.vim/plugged/` in git. Remove the **Vundle** submodule (`managed/vim/bundle/vundle`). Apply the previously chosen **upgraded GitHub repos** (ctrlpvim, easymotion, vim-mundo, preservim NERD*) and **Mundo** mappings (`g:mundo_*`, `:MundoToggle`).
- Rationale: Bare `pack/` + manual or submodule-per-plugin was heavier than wanted; vim-plug stays maintained, keeps SSH story to “submodules + bootstrap + `:PlugInstall`,” and avoids curling `plug.vim` on each machine when the submodule is present.
- Alternatives considered: Only native packages; minpac—see prior discussion; deferred in favor of vim-plug ergonomics.
- Consequences / follow-ups: Old ignored clones under `~/.vim/bundle/` can be deleted locally; `scripts/verify.sh` and README must reference `PlugInstall` not `BundleInstall`. **Recorded 2026-04-21:** `scripts/verify.sh` run clean post-migration; README step documents `rm -rf ~/.vim/bundle` for leftover Vundle-era trees.

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
- Consequences / follow-ups: **Done 2026-04-21** via vim-plug (`context` decisions entry); remove legacy `bundle/` dirs locally if present.

## 2026-04-20 — Prefer vanilla Vim for portable dotfiles; defer Neovim
- Decider: Anthony
- Decision: Treat **Vim** (not Neovim) as the supported editor in this repo for now, so a minimal setup over SSH—clone or unpack dotfiles, run bootstrap, open `vim`—works without extra runtime dependencies. Consider **Neovim** as a deliberate next step later, not part of the current migration.
- Rationale: Remote servers often have Vim or can install it easily; Neovim adds another version matrix and plugin/runtime expectations. Aligning the Vundle replacement and plugin refresh with stock Vim keeps the “ssh in and be productive” story simple.
- Alternatives considered: Standardize on Neovim now for better LSP and plugin ecosystem; deferred until local/SSH workflows are stable on Vim.
- Consequences / follow-ups: Plugin manager and plugin choices should stay compatible with Vim 8+ where possible; document any optional Neovim path in `/context` when revisited.

## 2026-04-20 — Use broad managed Codex allow rules for git and npm
- Decider: Anthony
- Decision: Keep the managed `~/.codex/rules/global.rules` baseline intentionally broad with `prefix_rule(pattern=["git"], decision="allow")` and `prefix_rule(pattern=["npm"], decision="allow")`, while leaving the local generated `default.rules` empty until new machine-local approvals are learned.
- Rationale: Git and npm are comfortable global allow surfaces for this workflow, and the broad prefixes are simpler to maintain than curating many tool-specific subcommands.
- Alternatives considered: Keep the seeded list of specific command approvals; rejected because it was noisier and offered no practical benefit once broad `git` and `npm` access were deemed acceptable.
- Consequences / follow-ups: Restart Codex after the rule-file change and add any future non-portable approvals back to the local `default.rules` only if they should stay machine-specific.

## 2026-04-20 — Prefer live repo state over stale `/context` snapshots
- Decider: Anthony
- Decision: When `/context` conflicts with live repo evidence such as `git status`, current files, recent commits, or the working tree, agents should trust the live state and reconcile `/context` before answering status or next-step questions.
- Rationale: `/context` is durable working memory, but it can naturally lag behind the actual repository state and should not override direct evidence.
- Alternatives considered: Treat `/context` as authoritative until manually updated; rejected because it can leave agents one step behind after commits or other state changes.
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
- Consequences / follow-ups: Agents should keep project notebooks current proactively and always propose a commit message that covers staged and unstaged changes.

## 2026-04-13 — Lighten `code_template/docs` scaffolding
- Decider: Anthony
- Decision: Remove the seeded `/code_template/docs` topic files and keep only a lightweight landing page plus flexible guidance that lets agents shape the docs structure per repo.
- Rationale: The fixed scaffold was over-prescriptive and pushed agents toward artificial categories instead of documenting the repo in the most effective retrieval shape.
- Alternatives considered: Keep the starter topic set and ask agents to replace it; rejected because the scaffold itself was adding noise and biasing structure too early.
- Consequences / follow-ups: Template adopters should create only the topic files their repo needs and keep `/docs/README.md` as a lightweight routing map.

## 2026-04-13 — Fold repo `context/reference` into `context/knowledge`
- Decider: Anthony
- Decision: Remove the live repo `context/reference/` split and keep reusable repo, vendor, and workflow notes in `context/knowledge/` instead.
- Rationale: A single retrieval path is easier for agents to follow and matches the streamlined context model used elsewhere in the repo.
- Alternatives considered: Keep a separate `reference/` library; rejected because the split added indirection without enough value in practice.
- Consequences / follow-ups: Update AGENTS/context guidance to route future reusable notes into `knowledge/` topic files and remove the placeholder `reference/` files.

## 2026-04-13 — Merge repo `user_shared` into `scratch`
- Decider: Anthony
- Decision: Removed `context/user_shared/` and redefined `context/scratch/` as the single git-tracked staging area for collaborative drafts, experiments, pre-repo code, and other content that does not yet have a stable home in the repo.
- Rationale: One staging area is easier for agents to use consistently than trying to distinguish between collaborative drafts and scratch artifacts.
- Alternatives considered: Keep `user_shared` and `scratch` separate; rejected because the distinction was not driving useful behavior.
- Consequences / follow-ups: Namespace `scratch/` by task or work thread and promote or delete contents once they have a proper home.

## 2026-04-13 — Keep decision logs in reverse chronological order
- Decider: Anthony
- Decision: Keep `context/decisions.md` and `code_template/context/decisions.md` ordered newest first.
- Rationale: Reverse chronological order optimizes retrieval by putting the most relevant, recent decisions at the top.
- Alternatives considered: Keep oldest-first ordering; rejected because it makes current policy harder to find quickly.
- Consequences / follow-ups: Add new decisions at the top of the file and update templates to reinforce the convention.

## 2026-04-13 — Merge template `user_shared` into `scratch`
- Decider: Anthony
- Decision: Removed `code_template/context/user_shared/` and redefined `code_template/context/scratch/` as the single git-tracked staging area for collaborative drafts, experiments, and other content that does not yet have a stable home in the repo.
- Rationale: The separate folders were not pulling their weight, while one shared staging area is easier for agents to understand and use consistently.
- Alternatives considered: Keep `user_shared` and `scratch` separate; rejected because the distinction was not producing useful agent behavior.
- Consequences / follow-ups: Template adopters should namespace `scratch/` by task or work thread and promote or delete contents once they have a proper home.

## 2026-04-13 — Make documentation upkeep mandatory and restore template `context/knowledge`
- Decider: Anthony
- Decision: Updated `code_template/AGENTS.md` to require proactive documentation updates after every substantial turn, and restored `code_template/context/knowledge/` as a place for agent-oriented supplemental knowledge that does not belong in canonical repo docs.
- Rationale: Agents were not maintaining docs reliably enough, and some reusable agent knowledge needs a home outside `/docs/`.
- Alternatives considered: Keep all durable writing in `/docs/` only; rejected because agent workflows, sandbox notes, and certain third-party learnings are useful but not appropriate as main repo docs.
- Consequences / follow-ups: Template adopters should treat `/docs/` as canonical repo truth and `/context/knowledge/` as supplemental agent knowledge.

## 2026-04-13 — Recenter `code_template` around `/docs` as canonical documentation
- Decider: Anthony
- Decision: Reworked `code_template` so `AGENTS.md` is a routing layer, `/docs` is the canonical documentation system, and `/context` is limited to live state, drafts, and scratch artifacts.
- Rationale: Optimize retrieval for agents and avoid splitting durable documentation across `knowledge/`, `reference/`, and context files.
- Alternatives considered: Keep the old `knowledge/` and `reference/` split; rejected because it added indirection without improving retrieval.
- Consequences / follow-ups: Template adopters should maintain `/docs/README.md` plus topic files and keep `/context` focused on working memory.

## 2026-02-04 — Add no-tech-debt rule to global AGENTS
- Decider: Anthony
- Decision: Added a global rule to avoid long-lived compatibility shims; if temporary artifacts are required, record removal and remove them in the next deploy.
- Rationale: Keep changes clean and prevent temporary workarounds from becoming permanent debt.
- Alternatives considered: Keep guidance implicit; rejected to make the expectation explicit.
- Consequences / follow-ups: None.

## 2026-01-20 — Migrate knowledge to `/context/knowledge/` with index
- Decider: Anthony
- Decision: Replace `context/knowledge.md` with a `context/knowledge/` directory and an `index.md` that links to topic files.
- Rationale: Keep the knowledge base scalable without bloating a single file or the context window.
- Alternatives considered: Keep a single `knowledge.md` and rely on `/context/reference/`; rejected due to size and discoverability concerns.
- Consequences / follow-ups: Update references from `knowledge.md` to `knowledge/index.md` and keep topic files concise.

## 2026-01-20 — Add `/context/scratch` for transient session artifacts
- Decider: Anthony
- Decision: Create `/context/scratch` for short-lived debugging artifacts, namespaced by task ID and cleaned up aggressively.
- Rationale: Preserve temporary work without polluting durable knowledge or source code.
- Alternatives considered: Use `/tmp` only; rejected because it hides useful session context that may need short-term retention.
- Consequences / follow-ups: Document the scratch workflow in AGENTS and `/context` README.

## 2026-01-20 — Add `/context/user_shared` for collaborative drafts and pre-repo code
- Decider: Anthony
- Decision: Create `/context/user_shared` with guidance for shared docs and early code not yet ready for the repo.
- Rationale: Provide a structured place for collaboration separate from production code and context summaries.
- Alternatives considered: Use `/context/knowledge/` only; rejected because drafts/prototypes can overwhelm curated notes.
- Consequences / follow-ups: Ensure AGENTS/context docs reference the folder and keep it organized.

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

## 2026-01-18 — Populate repo AGENTS.md and /context with repo-specific details
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Replaced placeholders in root `AGENTS.md` and `/context` with dot_files-specific guidance and current state; removed the unused reference template.
- Rationale: Move docs from scaffold to production-grade, actionable guidance.
- Alternatives considered: Leave templates for future manual fill-in; rejected to avoid stale placeholders.
- Consequences / follow-ups: Update entries as the repo evolves.

## 2026-01-18 — Treat template /context files as baseline in `code_template/AGENTS.md`
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Use "seeded structure" wording in the template to reflect that `/context` files are already present.
- Rationale: The template ships with a prebuilt `/context`, so it should be treated as the default baseline.
- Alternatives considered: Keep "recommended" wording; rejected because it implies the structure is optional.
- Consequences / follow-ups: None.

## 2026-01-18 — Remove template/seeding phrasing from /context base section
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Updated `code_template/AGENTS.md` to describe `/context` files as the day-1 base state without referencing templates or seeding.
- Rationale: The document should stand alone as a living guide and describe the current baseline, not its origin.
- Alternatives considered: Keep "seeded structure" wording; rejected to avoid provenance language in day-1 guidance.
- Consequences / follow-ups: None.
