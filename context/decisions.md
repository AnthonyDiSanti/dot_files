# Decisions

Decider format: `Anthony` for human decisions, `Codex (model: gpt-5.2-codex)` for agent decisions.
Keep newest decisions at the top (reverse chronological order).

## 2026-04-20 — Prefer live repo state over stale `/context` snapshots
- Decider: Anthony
- Decision: When `/context` conflicts with live repo evidence such as `git status`, current files, recent commits, or the working tree, agents should trust the live state and reconcile `/context` before answering status or next-step questions.
- Rationale: `/context` is durable working memory, but it can naturally lag behind the actual repository state and should not override direct evidence.
- Alternatives considered: Treat `/context` as authoritative until manually updated; rejected because it can leave agents one step behind after commits or other state changes.
- Consequences / follow-ups: Mirror the guidance in both the live repo and `code_template` `AGENTS.md` files so future repos inherit the same precedence rule.

## 2026-04-20 — Keep generated Codex rules separate from curated rules
- Decider: Anthony
- Decision: Do not git-manage `~/.codex/rules/default.rules`; instead, plan to add a curated managed rules file such as `home/private_dot_codex/rules/global.rules`.
- Rationale: Codex writes accepted/generated approval rules to `default.rules`, so that file should remain local and mutable. Portable rules that should apply across machines belong in a separate stable `.rules` file.
- Alternatives considered: Track `default.rules` directly; rejected because Codex naturally mutates it. Add a merge script immediately; deferred because Codex natively scans multiple `.rules` files under `rules/`.
- Consequences / follow-ups: Restart Codex after rule-file changes and test important commands with `codex execpolicy check --pretty --rules ... -- <command>`.

## 2026-04-20 — Use chezmoi symlink mode for dotfiles
- Decider: Anthony
- Decision: Replace the Puppet bootstrap with chezmoi, keep `home/` as the source-state root via `.chezmoiroot`, and use `mode = "symlink"` so managed `$HOME` files point back into the git checkout.
- Rationale: The repo should keep dotfiles as live tracked files so drift is visible in git instead of hidden in copied snapshots.
- Alternatives considered: Use copied-file chezmoi mode; rejected because it would allow `$HOME` files to diverge from the source checkout unless changes are explicitly re-added.
- Consequences / follow-ups: Keep selective macOS settings as explicit scripts unless a setting is deliberately moved to a platform-gated `run_once_`/`run_onchange_` script; migrate Vim away from Vundle separately and revisit non-portable color configuration.

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
