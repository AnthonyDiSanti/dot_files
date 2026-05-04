# Commit Prep: Gemini 3.1 Pro Preview Notes

- Skill source: `agents/skills/src/commit-prep/SKILL.md`
- Runtime artifact: `agents/skills/artifacts/gemini/gemini-3.1-pro-preview/skills/commit-prep/`
- Harness guide: `agents/harnesses/gemini.md`
- Model guide: `agents/models/gemini-3.1-pro-preview.md`
- Last reviewed: 2026-05-03

Gemini 3.1 Pro Preview responds best to direct, outcome-first instructions.
Do not add chain-of-thought scaffolding, hidden-reasoning requests, or
low-temperature determinism language to the runtime artifact. Let the local
Gemini CLI configuration provide high thinking for hard artifact-production
work, and keep the runtime skill focused on evidence, invariants, verification,
and final output.

Preserve the source invariants exactly:

- Inspect the full dirty tree by default, regardless of what is staged.
- Treat the staging area as user-owned review state.
- Do not stage, unstage, commit, amend, reset, restore, or rewrite git state.
- Update `.context` selectively and compactly.
- Report verification honestly.

Gemini 3.1 Pro Preview may fall back through model routing or be unavailable to
some accounts. If the update run falls back, prompts for fallback in headless
mode, or cannot access the preview model, leave the artifact stale and record
the exact failure rather than claiming a Gemini 3.1 Pro-authored artifact.

Keep final-response requirements explicit and compact. Gemini's direct style is
useful here: report docs/context updates, verification, commit scope, the
copyable commit message, and blockers without turning commit prep into a
transcript.
