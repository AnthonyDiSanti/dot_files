# Decisions

## 2026-01-18 — Remove template/seeding phrasing from /context base section
- Decider: agent
- Decision: Updated `code_template/AGENTS.md` to describe `/context` files as the day‑1 base state without referencing templates or seeding.
- Rationale: The document should stand alone as a living guide and describe the current baseline, not its origin.
- Alternatives considered: Keep “seeded structure” wording; rejected to avoid provenance language in day‑1 guidance.
- Consequences / follow-ups: None.

## 2026-01-18 — Treat template /context files as baseline in `code_template/AGENTS.md`
- Decider: agent
- Decision: Use "seeded structure" wording in the template to reflect that `/context` files are already present.
- Rationale: The template ships with a prebuilt `/context`, so it should be treated as the default baseline.
- Alternatives considered: Keep "recommended" wording; rejected because it implies the structure is optional.
- Consequences / follow-ups: None.

## 2026-01-18 — Populate repo AGENTS.md and /context with repo-specific details
- Decider: agent
- Decision: Replaced placeholders in root `AGENTS.md` and `/context` with dot_files-specific guidance and current state; removed the unused reference template.
- Rationale: Move docs from scaffold to production-grade, actionable guidance.
- Alternatives considered: Leave templates for future manual fill-in; rejected to avoid stale placeholders.
- Consequences / follow-ups: Update entries as the repo evolves.
