# Commit Prep — Claude Opus 4.7 Notes

- Skill source: `agents/skills/src/commit-prep/SKILL.md`
- Runtime artifact: `agents/skills/artifacts/claude/claude-opus-4-7/skills/commit-prep/`
- Last reviewed: 2026-05-02

Opus 4.7 will likely need slightly more explicit scope and representative
examples because it follows instructions literally. Preserve full-dirty-tree
scope by default, exact index preservation, and concise final output.

If this skill is updated through Anthropic API surfaces rather than Claude Code,
use adaptive thinking instead of manual thinking budgets. Do not rely on visible
thinking summaries for commit-prep correctness; final evidence should come from
repo state, context edits, and verification output.

Anthropic's official skill examples reinforce progressive disclosure and
eval-driven iteration. For `commit-prep`, preserve a concise runtime `SKILL.md`
with clear trigger frontmatter, evidence requirements, invariants, and final
response format. Put evaluation scenarios in `evals/` and tuning rationale in
these notes rather than making the Claude artifact an exhaustive process essay.
