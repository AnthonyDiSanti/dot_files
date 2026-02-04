# Decisions

Decider format: `Anthony` for human decisions, `Codex (model: gpt-5.2-codex)` for agent decisions.

## 2026-01-18 — Remove template/seeding phrasing from /context base section
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Updated `code_template/AGENTS.md` to describe `/context` files as the day‑1 base state without referencing templates or seeding.
- Rationale: The document should stand alone as a living guide and describe the current baseline, not its origin.
- Alternatives considered: Keep “seeded structure” wording; rejected to avoid provenance language in day‑1 guidance.
- Consequences / follow-ups: None.

## 2026-01-18 — Treat template /context files as baseline in `code_template/AGENTS.md`
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Use "seeded structure" wording in the template to reflect that `/context` files are already present.
- Rationale: The template ships with a prebuilt `/context`, so it should be treated as the default baseline.
- Alternatives considered: Keep "recommended" wording; rejected because it implies the structure is optional.
- Consequences / follow-ups: None.

## 2026-01-18 — Populate repo AGENTS.md and /context with repo-specific details
- Decider: Codex (model: gpt-5.2-codex)
- Decision: Replaced placeholders in root `AGENTS.md` and `/context` with dot_files-specific guidance and current state; removed the unused reference template.
- Rationale: Move docs from scaffold to production-grade, actionable guidance.
- Alternatives considered: Leave templates for future manual fill-in; rejected to avoid stale placeholders.
- Consequences / follow-ups: Update entries as the repo evolves.

## 2026-01-20 — Recommend commit messages at logical stopping points
- Decider: Anthony
- Decision: Added a workflow rule to pause and propose a git commit with a present-tense title, blank line, and bullet list of changes, per user request.
- Rationale: User preference for consistent, high-quality commit message recommendations.
- Alternatives considered: Keep commit guidance implicit; rejected to make the behavior explicit and repeatable.
- Consequences / follow-ups: Apply this recommendation flow after coherent units of work.

## 2026-01-20 — Use ULIDs for task IDs in `tasks.md`
- Decider: Anthony
- Decision: Task entries use ULID identifiers paired with short human-readable titles.
- Rationale: Reduce ID collisions in agent-managed task lists while keeping entries scannable.
- Alternatives considered: Sequential IDs; rejected due to merge conflict risk in multi-agent edits.
- Consequences / follow-ups: Update task templates and existing task entries to the ULID format.

## 2026-01-20 — Add `/context/user_shared` for collaborative drafts and pre-repo code
- Decider: Anthony
- Decision: Create `/context/user_shared` with guidance for shared docs and early code not yet ready for the repo.
- Rationale: Provide a structured place for collaboration separate from production code and context summaries.
- Alternatives considered: Use `/context/knowledge/` only; rejected because drafts/prototypes can overwhelm curated notes.
- Consequences / follow-ups: Ensure AGENTS/context docs reference the folder and keep it organized.

## 2026-01-20 — Add `/context/scratch` for transient session artifacts
- Decider: Anthony
- Decision: Create `/context/scratch` for short-lived debugging artifacts, namespaced by task ID and cleaned up aggressively.
- Rationale: Preserve temporary work without polluting durable knowledge or source code.
- Alternatives considered: Use `/tmp` only; rejected because it hides useful session context that may need short-term retention.
- Consequences / follow-ups: Document the scratch workflow in AGENTS and `/context` README.

## 2026-01-20 — Migrate knowledge to `/context/knowledge/` with index
- Decider: Anthony
- Decision: Replace `context/knowledge.md` with a `context/knowledge/` directory and an `index.md` that links to topic files.
- Rationale: Keep the knowledge base scalable without bloating a single file or the context window.
- Alternatives considered: Keep a single `knowledge.md` and rely on `/context/reference/`; rejected due to size and discoverability concerns.
- Consequences / follow-ups: Update references from `knowledge.md` to `knowledge/index.md` and keep topic files concise.

## 2026-02-04 — Add no-tech-debt rule to global AGENTS
- Decider: Anthony
- Decision: Added a global rule to avoid long-lived compatibility shims; if temporary artifacts are required, record removal and remove them in the next deploy.
- Rationale: Keep changes clean and prevent temporary workarounds from becoming permanent debt.
- Alternatives considered: Keep guidance implicit; rejected to make the expectation explicit.
- Consequences / follow-ups: None.
