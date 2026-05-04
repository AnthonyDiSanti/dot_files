# Commit Prep — Claude Opus 4.6 Notes

- Skill source: `agents/skills/src/commit-prep/SKILL.md`
- Runtime artifact: `agents/skills/artifacts/claude/claude-opus-4-6/skills/commit-prep/`
- Last reviewed: 2026-05-02

Opus 4.6 will likely need stronger retrieval budgets and stop rules than
GPT-5.5. Preserve full-dirty-tree scope by default, exact index preservation, and
avoid over-journaling `.context`.

Prefer adaptive thinking for any API-backed artifact production or eval flow.
Manual thinking budgets are still functional for Opus 4.6 but deprecated, so do
not add new skill infrastructure that depends on fixed `budget_tokens` values.

Anthropic's official skill examples reinforce that Claude needs trigger text in
the `description`, not buried in the body. When regenerating this artifact,
keep the description assertive around commit prep, journaling, handoff/context
capture, and commit-message drafting. Keep the body focused on the operational
contract and use model notes/evals for rationale rather than copying broad docs
into runtime instructions.
