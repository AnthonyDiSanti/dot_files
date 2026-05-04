# Anthropic Claude Opus 4.6 Prompt Guide

- Status: repo-authored guide derived from official docs.
- Last reviewed: 2026-05-02.
- Primary sources:
  - [Claude prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
  - [Claude extended thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
  - [Claude model migration guide](https://platform.claude.com/docs/en/about-claude/models/migration-guide)
  - [Claude release notes](https://support.claude.com/en/articles/12138966-release-notes)
  - [Claude Code model configuration](https://code.claude.com/docs/en/model-config)
    for Claude Code alias and effort behavior.
- Repo consumers:
  - cross-model comparison for Claude-facing agent instructions
  - migration review when moving from Opus 4.6 to Opus 4.7
  - prompt debugging when a Claude harness over-explores

## Why this guide exists

Opus 4.6 is not the primary target for current Codex work, but it matters as the
baseline from which Opus 4.7 behavior is described. The official docs repeatedly
compare Opus 4.7 to Opus 4.6, so this file captures what to expect when prompts
were tuned for 4.6 and why those prompts may need adjustment.

This file is a derivative repo guide, not a mirror of Anthropic documentation.
Check official docs before changing API code, model slugs, effort settings, or
thinking configuration.

## Verbatim anchors

Short exact snippets from the official docs, kept intentionally small:

- "Overthinking and excessive thoroughness"
- "adaptive thinking"
- "Use examples effectively"

Everything else in this file is paraphrase, synthesis, or repo-local adaptation.

## Executive Summary

Claude Opus 4.6 improved coding and agent workflows over earlier Claude models
and became more responsive to system prompts and tool instructions. It can also
do substantial upfront exploration, especially at higher effort settings. This
often improves final quality, but it can inflate latency, thinking tokens, and
tool usage.

If a prompt was written for older Claude models that underused tools, it may be
too aggressive for Opus 4.6. Instructions such as "if in doubt, use the tool" or
"always gather more context" can produce over-triggering. The better pattern is
conditional tool use: use a tool when it materially improves understanding,
verification, or correctness.

Opus 4.6 also shares many current Claude best practices: clear and direct
instructions, context/motivation, examples, XML structure, role prompts,
long-context structure, output controls, explicit tool-use behavior, and adaptive
thinking. Current Anthropic guidance recommends adaptive thinking for Opus 4.6;
manual thinking budgets still work, but are deprecated.

## Model Stance

Prompt Opus 4.6 as a capable, tool-using agent that may need scope control. It
can do deep exploration and high-quality synthesis, but prompts should define
when exploration is useful and when to stop.

### Practical stance for this repo

For repo work under Opus 4.6:

- give a clear outcome
- give explicit stop conditions
- avoid "always search/tool" defaults
- specify when broad context gathering is useful
- tune effort down if over-exploration continues
- keep verification explicit
- preserve user state with hard rules

## Claude Code Alias Boundary

Claude Code can accept aliases such as `best` and `opus`, but those aliases now
resolve to newer Opus targets on the Anthropic API. This repo keeps the Opus 4.6
deployment pinned with the full `claude-opus-4-6` model id. Do not use `best` or
`opus` as shorthand for Opus 4.6 in artifacts, model notes, or home symlinks.

## Main Difference From Opus 4.7

Opus 4.7 is more literal and often uses tools less by default. Opus 4.6 is more
likely to explore broadly and use tools more aggressively, especially when prompts
encourage thoroughness.

Therefore:

- Opus 4.6 prompts may need ceilings.
- Opus 4.7 prompts may need scope-expansion and tool-trigger clarity.
- Opus 4.6 prompts may need fewer "be thorough" nudges.
- Opus 4.7 prompts may need more explicit "apply this broadly" wording.

## Over-Exploration

The most important 4.6-specific behavior is upfront exploration. This can be
valuable for hard codebase work. It can be wasteful for narrow changes, commit
messages, small config updates, or tasks with clear local evidence.

### Symptoms

- reads many unrelated files
- runs several searches after enough evidence exists
- explores alternate approaches without need
- spends too long planning
- produces long summaries of context
- overuses tools that used to undertrigger

### Fixes

Use targeted tool rules:

```text
Use additional searches or file reads only when the current evidence is
insufficient to make the change safely, verification fails, or the user asked for
a broad audit.
```

Constrain decision revisiting:

```text
Choose a reasonable approach and proceed. Revisit the approach only if new
evidence contradicts it, implementation fails, or verification exposes a gap.
```

Lower effort when appropriate:

```text
This is a bounded low-risk change. Use low or medium effort and avoid broad
exploration unless the first evidence set is insufficient.
```

## Adaptive Thinking

Opus 4.6 supports adaptive thinking, where the model decides whether and how much
to think based on query complexity and effort. Manual extended-thinking budgets
still function, but current guidance treats them as deprecated and favors
adaptive thinking plus effort controls.

### Repo stance

Prefer:

```text
thinking={"type": "adaptive"}
output_config={"effort": "medium"}
```

Avoid adding new Opus 4.6 integrations that depend on
`thinking={"type":"enabled","budget_tokens":N}`. If maintaining an older
manual-budget integration, keep `budget_tokens` below `max_tokens`, remember that
thinking tokens count against output limits, and plan to migrate to adaptive
thinking before the manual mode is removed.

For API flows that do not expose thinking to users, `display: "omitted"` can
reduce time-to-first-text-token without reducing thinking-token cost. Opus 4.6
defaults to summarized thinking, unlike Opus 4.7.

When continuing tool-use conversations with thinking enabled, pass received
`thinking` and `redacted_thinking` blocks back unchanged. Opus 4.6 preserves
thinking blocks across turns, which helps protocol correctness and cache behavior
but consumes context in long conversations.

Use lower effort for:

- small documentation edits
- straightforward docs or status tasks
- direct shell questions
- low-risk config wording changes

Use higher effort for:

- multi-file shell startup changes
- bootstrap behavior changes
- complex debugging
- security-sensitive review
- large prompt architecture work

## Tool Use

Opus 4.6 is more responsive to explicit tool instructions than older Claude
models. Prompt language originally designed to force tool use may become too
strong.

### Bad tool guidance for Opus 4.6

```text
Always use the repository search tool before answering.
If in doubt, inspect more files.
Default to using every available tool.
```

### Better tool guidance

```text
Use tools when they materially improve correctness, reveal live repo state, or
verify behavior. Stop gathering context once the success criteria can be met with
the evidence already available.
```

### Action trigger

Claude docs note that "can you suggest changes" may lead to suggestions instead
of edits. If edits are intended, say so.

```text
Implement the requested change directly. Use tools to inspect the repo and edit
files. Provide recommendations only for decisions that materially affect scope or
risk.
```

For discussion-only:

```text
Do not edit files. Analyze the options and recommend a path. Wait for explicit
approval before making changes.
```

## Parallel Tool Calls

Claude's latest models can execute tool calls in parallel. For Opus 4.6, this can
speed context gathering, but the prompt should prevent unsafe parallelism.

### Parallel-safe

- reading independent files
- searching unrelated terms
- checking multiple static docs
- inspecting independent test fixtures

### Sequential-only

- commands where one output determines the next input
- writes to the same file
- git state changes
- operations with shared temp files
- actions with side effects

### Prompt block

```text
Parallelize read-only independent inspection. Run dependent operations
sequentially. Never guess placeholder parameters for a tool call; wait for the
required value or gather it first.
```

## Clear And Direct Instructions

Anthropic's general guidance for Claude remains straightforward: be clear,
direct, and specific. Explain the desired output and constraints. If step order
matters, use numbered or bullet steps. If it does not, use success criteria.

### Repo example

Weak:

```text
Clean this up.
```

Better:

```text
Simplify the bootstrap helper while preserving current managed-path behavior.
Success means `./bootstrap.sh --list-managed` output is unchanged and
`test/verify.sh` passes.
```

## Context And Motivation

Claude benefits from knowing why a behavior matters.

### Example

```text
Preserve user-owned state because the user may be reviewing or editing alongside
the agent. Treat existing user changes as intentional unless evidence shows
otherwise.
```

This is better than only saying:

```text
Do not unstage files.
```

The "why" helps the model generalize to related actions such as reset, restore,
amend, or rebasing.

## Examples

Use examples when output format or tone matters. Good examples are relevant,
diverse, and structured.

### Structured response examples

```text
<examples>
  <example name="implementation-done">
    <status>the requested code/config change is complete and verification passed</status>
    <response>Summarize the behavior change, name verification, and keep process
    narration short.</response>
  </example>
  <example name="documentation-only">
    <status>only durable docs or context changed</status>
    <response>State which docs changed and why no behavior verification was
    needed, or name the lightweight check that ran.</response>
  </example>
  <example name="blocked-verification">
    <status>verification command missing dependency</status>
    <response>Name the failed check, explain the missing dependency, and propose
    the next best validation.</response>
  </example>
</examples>
```

### Output example

```text
Docs/context updated: .context/handoff.md and .context/decisions.md.
Verification: test/verify.sh passed.
Output: requested artifact is ready.

<artifact>
...
</artifact>
```

## XML Structure

Use XML-like tags for complex prompts with multiple kinds of information. This
helps Claude distinguish instructions from inputs and examples.

### Useful structure

```text
<instructions>
Update the requested skill while preserving repo-specific invariants.
</instructions>

<repo_rules>
Follow AGENTS.md. Do not store secrets in .context.
</repo_rules>

<current_state>
...relevant files, current behavior, and verification state...
</current_state>

<output_format>
Return changed behavior, verification, final artifact, and blockers.
</output_format>
```

Avoid using XML tags for every tiny prompt. They are most useful when the prompt
mixes multiple information types.

## Long Context

For long documents or large repositories:

- place source documents near the top
- put the query/instruction near the end
- structure documents with source metadata
- ask for quote extraction before synthesis when fidelity matters
- avoid dumping irrelevant files

### Repo pattern

```text
<documents>
  <document path="AGENTS.md">...</document>
  <document path=".context/handoff.md">...</document>
  <document path="agents/skills/example-skill/SKILL.md">...</document>
</documents>

<task>
Revise the skill so it preserves repo-specific invariants and follows Claude
Opus 4.6 prompt guidance without over-exploration.
</task>
```

## Agentic State And Guardrails

Anthropic's broader agentic-system guidance is relevant to Opus 4.6 even though
this file focuses on migration and prompt tuning. Opus 4.6 can do long-horizon
work, but it is also more likely than Opus 4.7 to over-explore, spawn subagents,
or create supporting artifacts when direct work would be enough.

State guidance:

- tell the model when context compaction or restart recovery is available
- save only continuation-critical state: objective, changed files, verification,
  blockers, and next actions
- use structured state for task matrices or test status
- use prose state for rationale and handoff
- prefer live repo evidence over stale memory when resuming

Coding guardrails:

- inspect referenced files before making claims about code
- limit temporary scripts and scratch files to cases where they materially reduce
  repeated work
- delete or promote scaffolding before finalizing
- avoid hard-coding behavior to satisfy only visible tests
- avoid "fixing" by repeatedly trying similar changes without a new hypothesis

Useful block:

```text
Persist only the state needed to continue safely after compaction or restart.
Before codebase claims, inspect the relevant files. Create temporary helpers only
when they materially reduce repeated work, and remove or promote them before the
task is complete.
```

## Output And Formatting

Claude's latest models are direct and may skip summaries unless prompted. If a
summary is needed, ask for it. If prose is preferred over bullets, say so. If
markdown should be limited, provide a positive format target.

### Summary after tools

```text
After completing a task that involved tools, provide a brief summary of what
changed, what was verified, and any follow-up.
```

### Prose instead of bullets

```text
Use short prose paragraphs. Use bullets only for discrete lists where scanning
matters.
```

### Plain text math

Opus 4.6 may default to LaTeX for math. If plain text is needed:

```text
Write math expressions using plain text characters such as /, *, and ^. Do not
use LaTeX or MathJax notation.
```

## Prefilled Responses

Starting with Claude 4.6-family behavior, assistant prefills are no longer a
future-proof control mechanism. Use structured outputs or explicit output-format
instructions instead.

### Replace prefill with format contract

Instead of relying on an assistant prefill like:

```text
{"status":
```

Use:

```text
Return valid JSON matching this shape: {"status": "...", "summary": "..."}.
Do not include markdown fences.
```

When strict validation matters, prefer the API's structured output features.

## Migration To Opus 4.7

If a prompt was tuned for Opus 4.6, review these areas before moving to 4.7:

- effort levels are stricter
- manual thinking budgets are removed
- non-default sampling parameters are removed
- visible thinking summaries are omitted by default
- tone may be more direct
- tool use may be less frequent
- subagent spawning may be less frequent
- instructions are interpreted more literally
- token counts may change
- high-resolution images may increase costs

### Prompt migration checklist

- Remove broad "always use tools" guidance.
- Add explicit tool triggers if 4.7 underuses tools.
- Add broad-scope wording if 4.7 applies examples too narrowly.
- Rebaseline verbosity.
- Rebaseline effort.
- Remove prefill assumptions.
- Replace sampling steering with prompt steering.
- Review code-review recall/precision instructions.

## Common Failure Modes And Fixes

### Over-searching

Cause:

- prompt inherited old anti-undertrigger guidance
- high effort on a bounded task
- no retrieval budget

Fix:

```text
Use the smallest context sufficient for the requested change. Expand only when
the first evidence set is incomplete, contradictory, or verification fails.
```

### Too much upfront planning

Cause:

- prompt asks for a plan even when edits are expected
- model is at high effort

Fix:

```text
For straightforward implementation requests, inspect the relevant files and make
the change. Give a plan only when the user asks for one or when scope/risk needs
agreement first.
```

### Tool overtriggering

Cause:

- "if in doubt, use tool" style instructions

Fix:

```text
Use tools when they materially improve correctness or verification. Do not call a
tool only to reaffirm stable context already available.
```

### Too much final detail

Cause:

- no verbosity or output shape

Fix:

```text
Final answer should include only changed files summary, verification, and next
step or commit message. Omit detailed process narration.
```

### It only suggests changes

Cause:

- action intent ambiguous

Fix:

```text
The user wants implementation. Make the change directly unless a missing decision
materially affects scope or safety.
```

## Prompt Blocks Library

### Bounded exploration

```text
Gather enough context to make the change safely, then stop. Expand scope only
when evidence is missing, contradictory, or verification fails.
```

### Tool-use budget

```text
Prefer one targeted search/read pass. Run additional searches only for missing
callers, dependencies, or failing verification.
```

### Implementation default

```text
If the user asks for a change, implement it. If the user asks for explanation,
answer without editing. If ambiguous, infer the likely intent and proceed unless
the risk is material.
```

### User-owned state preservation

```text
Treat existing user state as intentional. Read it when needed for correctness,
but do not overwrite, discard, rewrite, or narrow around it unless explicitly
asked.
```

### Final artifact shape

```text
Return docs/context changes, verification, the requested final artifact, and any
excluded scope or blockers.
```

## Skill Design Implications

If adapting a skill for Opus 4.6:

- add retrieval budgets
- add stop rules
- avoid "always use tools"
- be explicit when implementation is expected
- use examples for final output
- include why critical constraints matter
- keep verification explicit
- consider lower effort for bounded tasks

Skill-specific model notes belong beside the source skill under `agents/skills/src/**/<skill>/model-notes/`.
Keep this guide focused on Claude Opus 4.6 behavior that generalizes across
skills; use per-skill notes for audits, tuning conclusions, and examples that
only apply to one skill.

## Evaluation Checklist

Use this checklist after retuning for Opus 4.6:

- Does the prompt prevent unnecessary broad exploration?
- Does it define when to stop searching?
- Does it distinguish suggestion requests from implementation requests?
- Does it preserve user-owned git state?
- Does it require file inspection before codebase claims?
- Does it keep continuation state compact and useful?
- Does it avoid retained clutter from temporary scaffolding?
- Does it include output examples if format matters?
- Does it explain why critical rules matter?
- Does it avoid obsolete prefill assumptions?
- Does it avoid non-default sampling as a steering mechanism?
- Does effort match task risk and scope?
- Does final output stay concise?

## Maintenance Notes

Revisit this guide when:

- Anthropic changes Opus 4.6 support or migration docs.
- a Claude 4.6 harness is added to this repo.
- a prompt tuned for Opus 4.6 is migrated to Opus 4.7.
- a Claude agent over-explores or overuses tools.
- a future Claude model makes 4.6 primarily historical.
