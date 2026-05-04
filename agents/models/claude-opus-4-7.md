# Anthropic Claude Opus 4.7 Prompt Guide

- Status: repo-authored guide derived from official docs.
- Last reviewed: 2026-05-02.
- Primary sources:
  - [Claude prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
  - [Claude extended thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
  - [Claude model migration guide](https://platform.claude.com/docs/en/about-claude/models/migration-guide)
  - [What's new in Claude Opus 4.7](https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-7)
  - [Introducing Claude Opus 4.7](https://www.anthropic.com/news/claude-opus-4-7)
  - [Claude Code model configuration](https://code.claude.com/docs/en/model-config)
    for Claude Code alias and effort behavior.
- Repo consumers:
  - future Claude-facing agent harnesses
  - cross-model comparison for `agents/skills/`
  - AGENTS instruction tuning when Claude is the executor

## Why this guide exists

Claude Opus 4.7 has meaningfully different prompting and API behavior from
Opus 4.6. It is more literal, more autonomous in some long-horizon contexts,
less validation-forward in tone, stricter around effort, and more deliberate
about tool use. This guide translates the official guidance into repo-local
patterns for agent instructions and skill design.

This file does not mirror the official docs. Re-check the official sources before
changing API parameters, model IDs, token budgets, or safety-sensitive behavior.

## Verbatim anchors

Short exact snippets from the official docs, kept intentionally small:

- "Use examples effectively"
- "More literal instruction following"
- "Extended thinking removed"

Everything else in this file is paraphrase, synthesis, or repo-local adaptation.

## Executive Summary

Claude Opus 4.7 is Anthropic's strongest generally available model for
long-horizon agentic work, coding, knowledge work, vision, and memory tasks. It
often performs well on Opus 4.6 prompts, but migration should still include a
prompt and harness review.

The biggest prompt-level changes:

- response length calibrates more strongly to task complexity
- effort levels are respected more strictly, especially `low` and `medium`
- tool use may be less frequent than Opus 4.6 unless effort/prompting pushes it
- progress updates are often better without rigid scaffolding
- instruction following is more literal
- tone is more direct and less validation-forward
- subagent spawning is more conservative by default
- code-review prompts that say "only important issues" may suppress findings
- frontend/design defaults have a recognizable house style that may need steering

The biggest API/harness changes:

- 1M context and 128k max output are available at launch
- manual extended thinking is removed for Opus 4.7
- adaptive thinking plus effort replaces manual thinking budgets, but thinking
  is off unless explicitly enabled
- non-default sampling parameters are removed
- thinking display defaults to omitted unless summarized output is requested
- the tokenizer can use about 1x to 1.35x as many text tokens as Opus 4.6,
  depending on content
- thinking blocks are preserved across turns, so pass them back unchanged when
  continuing tool-use conversations
- high-resolution images are supported up to 2576px / 3.75MP with 1:1 pixel
  coordinates, and may cost more tokens
- `xhigh` effort exists and is recommended for many coding/agentic use cases
- task budgets exist as an advisory beta for full agentic loops, with a 20k
  token minimum

## Model Stance

Prompt Claude Opus 4.7 as a precise, capable, literal agent. It does not need as
much defensive scaffolding as earlier models, but it does need clear scope. If an
instruction should apply broadly, say so. If examples are representative rather
than exhaustive, say so. If a stage should prioritize recall over precision, say
that directly.

### Practical stance for this repo

For repo work, Claude Opus 4.7 should receive:

- a clear outcome
- explicit scope boundaries
- exact side-effect policy
- tool/subagent decision rules
- verification expectations
- final-output shape

Avoid:

- relying on warm conversational style to imply collaboration
- assuming it will generalize one example to every case
- broad "be conservative" wording when recall matters
- strict progress-update cadence unless the product requires it
- old temperature/top_p/top_k steering habits

## Claude Code Alias Boundary

Claude Code's model-configuration docs say `best` currently resolves to `opus`,
and on the Anthropic API `opus` resolves to Opus 4.7. This repo therefore maps
the Claude Code `best` and `opus` aliases to the canonical `claude-opus-4-7`
artifact target in `agents/harnesses/claude.yaml`.

Keep that as a harness/deployment concern. Runtime artifact directories and
model notes should continue to use the canonical `claude-opus-4-7` id so a
future alias change does not silently rewrite model-specific guidance.

## Response Length And Verbosity

Opus 4.7 varies length by task complexity. Simple lookups may get short answers;
open-ended analysis may become quite long. This is useful when it matches the
product, but unstable if your UI or workflow expects fixed-length responses.

### Steering shorter output

Use direct positive guidance:

```text
Provide concise, focused responses. Include only context that changes the user's
decision or next action. Keep examples minimal unless the user asks for depth.
```

### Steering richer output

```text
For this analysis, optimize for completeness over brevity. Include assumptions,
tradeoffs, concrete examples, and the reasoning needed to evaluate the
recommendation.
```

### Product-specific output contracts

For artifact-generating workflows:

```text
Return a short summary, verification status, the generated artifact, and any
blockers. Do not include a long narrative of how the artifact was derived.
```

For code review:

```text
Lead with findings. Include file/line references. Keep summary short. If no
findings are found, say so and name residual risk.
```

For handoff:

```text
Capture current state, next steps, blockers, and verification. Prefer compact,
path-rich notes over broad summaries.
```

## Effort And Thinking Depth

Opus 4.7 treats effort more strictly than Opus 4.6. At lower effort, the model is
more likely to do exactly what was asked rather than go beyond it. This is useful
for latency and cost, but it creates under-thinking risk for moderately complex
tasks.

### Effort levels

Use this repo-local interpretation:

- `low`: short, scoped, low-risk tasks where speed matters
- `medium`: cost-sensitive tasks that still need some reasoning
- `high`: intelligence-sensitive tasks, most serious coding, most agentic work
- `xhigh`: difficult coding/agentic tasks where quality matters more than cost
- `max`: evals or edge cases where maximum reasoning may be worth overthinking

Anthropic recommends starting many coding/agentic Opus 4.7 workloads at `xhigh`,
with at least `high` for intelligence-sensitive work. For Codex-like use in this
repo, that means Claude 4.7 should not be run at low effort for complex shell,
bootstrap, git, or prompt architecture changes.

### Adaptive thinking

Opus 4.7 uses adaptive thinking when thinking is enabled. Thinking is off by
default; requests with no `thinking` field run without thinking. Manual thinking
budgets from older models do not carry forward and return API errors. If a
prompt depends on visible thinking or explicit thinking budgets, update both API
parameters and user-facing UX.

Use `display: "summarized"` only when the application or prompt-debugging
workflow needs thinking summaries. For non-interactive production pipelines,
prefer omitted display: it reduces time-to-first-text-token, but does not reduce
thinking-token cost.

When continuing a tool-use conversation, preserve received `thinking` and
`redacted_thinking` blocks unchanged. Dropping or rewriting them can break the
multi-turn protocol; carrying them forward is expected for Opus 4.7.

### Steering overthinking

If Opus 4.7 spends too much effort:

```text
Use the smallest reasoning path that satisfies the success criteria. Do not
expand scope unless evidence is missing, verification fails, or the user asked
for a broad audit.
```

If it under-thinks:

```text
Before finalizing, check for hidden dependencies, edge cases, and whether the
verification performed actually covers the changed behavior.
```

## Tool Use

Opus 4.7 may use tools less often than Opus 4.6, relying more on reasoning. This
is often good. For agentic search, coding, and knowledge work, higher effort
usually increases tool use.

### When tools should be used

```text
Use tools when the answer depends on live repo state, current external facts, file
contents, command output, or verification. Do not answer from memory when the
source of truth is available locally.
```

### When tools should not be used

```text
Do not call tools just to improve phrasing, repeat evidence already gathered, or
perform broad exploration after the success criteria are satisfied.
```

### Tool trigger for code edits

```text
If the user asks for a code or config change, inspect the relevant files and make
the change unless they explicitly asked only for discussion. Use existing repo
patterns. Verify the changed behavior when possible.
```

### Tool trigger for vendor docs

```text
If a question depends on current vendor behavior, model guidance, pricing,
availability, or API parameters, use official docs and cite the source URLs.
```

## Progress Updates

Anthropic says Opus 4.7 tends to provide better progress updates in long traces.
Rigid scaffolding such as "after every N tool calls" may be unnecessary or worse.

### Better progress-update rule

```text
Send a short update when entering a major phase, discovering a material fact,
hitting a blocker, or changing the plan. Do not narrate routine file reads or
commands.
```

### Bad progress-update rule

```text
After every three tool calls, summarize everything you have done.
```

Why bad:

- it creates artificial cadence
- it may interrupt efficient work
- it encourages filler updates
- it is detached from actual task state

For this repo, updates should remain sparse, concrete, and action-oriented.

## Literal Instruction Following

Opus 4.7 is more literal than Opus 4.6. If you give an instruction for one item,
do not assume it applies elsewhere. If you want a formatting or behavior rule to
apply broadly, state the scope explicitly.

### Scope examples

Weak:

```text
Format the first finding with a file path and severity.
```

Better:

```text
Format every finding with file path, line, severity, confidence, and impact.
```

Weak:

```text
Use this style in the summary.
```

Better:

```text
Apply this style to the summary, findings, and follow-up sections.
```

Weak:

```text
Do not modify the staging area.
```

Better:

```text
Do not modify the git index in any way: do not stage, unstage, commit, amend,
reset, restore, or rebase unless explicitly asked.
```

## Tone And Writing Style

Opus 4.7 is more direct and opinionated than Opus 4.6. It uses fewer validation
phrases and emoji. This fits this repo's desired engineering tone, but if a
product wants warmth, prompt for it explicitly.

### Repo tone block

```text
Use direct, pragmatic engineering prose. Be concise and specific. Avoid
cheerleading, validation-heavy phrasing, and unnecessary warmth. Explain tradeoffs
when they affect the user's decision.
```

### Warmer product tone block

```text
Use a warm, collaborative tone. Acknowledge the user's framing briefly, then give
a clear recommendation and next step.
```

## Subagent Spawning

Opus 4.7 spawns fewer subagents by default. This is usually good for small tasks
but may reduce parallel exploration in large codebases.

### Repo subagent policy

```text
Use subagents only for bounded work that can run in parallel without blocking the
next local step. Prefer delegation when exploring independent questions or making
disjoint code changes. Do not spawn a subagent for work that can be completed
directly in the current response.
```

### More aggressive parallelism

```text
Spawn multiple subagents in the same turn when independent workstreams can run in
parallel, such as checking unrelated subsystems, comparing multiple vendors, or
editing disjoint file sets.
```

### More conservative behavior

```text
Do not use subagents unless the user explicitly asks for parallel agent work.
Handle ordinary code inspection and small edits locally.
```

For this repo, keep the existing developer instruction: only use subagents when
the user explicitly asks for them. If building a Claude harness without that
global rule, add explicit subagent policy.

## Frontend And Design Defaults

Opus 4.7 has stronger visual design instincts but a recognizable default style:
warm off-white backgrounds, serif display type, italic accents, and terracotta
or amber accents. That can be appropriate for editorial, hospitality, or
portfolio work, but wrong for dashboards, dev tools, finance, healthcare, or
operational interfaces.

### For utilitarian tools

```text
Design for repeated operational use: dense but readable layout, restrained color,
predictable controls, strong scanning hierarchy, and minimal ornament. Avoid
editorial hero treatment, decorative gradients, oversized typography, and
portfolio-style composition.
```

### For creative variety

```text
Before implementing, propose four distinct visual directions tailored to the
brief, each with background color, accent color, typeface, and one-line rationale.
Ask the user to choose one direction.
```

## Code Review Harnesses

Opus 4.7 may obey "only high severity" or "be conservative" so faithfully that
measured recall drops. The issue may be reporting threshold, not bug-finding
ability.

### Coverage-first review prompt

```text
During finding generation, optimize for coverage. Report every plausible issue
that could affect correctness, tests, security, data integrity, or user-visible
behavior. Include confidence and estimated severity so a later pass can filter or
rank findings.
```

### Filtered review prompt

```text
Report only findings that could cause incorrect behavior, a test failure,
security exposure, data loss, or materially misleading output. Omit pure style,
naming, and preference-only issues.
```

For this repo's code-review stance, the filtered version is usually right, but
coverage-first may be useful when validating a new model or prompt.

## Agentic Coding Guardrails

Anthropic's agentic-system guidance adds several practical failure modes that
matter for coding harnesses. Opus 4.7 should be autonomous, but the prompt should
still constrain where autonomy creates noise or false confidence.

Guardrails to preserve in repo-facing prompts:

- read referenced files before making claims about them
- keep temporary files, generated scripts, and one-off scaffolding scarce
- avoid hard-coding implementation to satisfy only the visible tests
- do not treat test success as proof that unrelated behavior is correct
- do not create extra documentation or helper files unless they will be retained
- when debugging, track hypotheses and observations instead of repeatedly trying
  near-identical fixes

Useful block:

```text
Before making codebase claims, inspect the relevant files or command output.
Avoid creating new helper files unless they are part of the final design. When a
test fails, diagnose the behavior it exposes rather than hard-coding to the test.
```

This is especially important for `.context`: durable notes are valuable, but the
agent should not convert every turn into a transcript or create scratch files
when a concise handoff update is enough.

## Long Context

Claude docs recommend careful structure for large inputs. In long context tasks:

- put large source documents before instructions and query
- structure each document with metadata
- put the question near the end
- ask for source-grounded extraction before synthesis when precision matters
- use XML-like tags for separation

### Repo long-context pattern

```text
<repo_context>
  <document path="AGENTS.md">...</document>
  <document path=".context/handoff.md">...</document>
  <document path="changed-file">...</document>
</repo_context>

<task>
Use the repo context above to update the requested skill. Preserve hard
constraints from AGENTS.md and do not duplicate unrelated guidance.
</task>
```

## Agentic State Management

Claude's official docs emphasize long-horizon state tracking, especially across
multiple context windows. The useful repo lesson is not "write everything down";
it is "keep enough structured state that a fresh context can continue safely."

Prompt implications:

- tell the agent whether the harness will compact context or whether it should
  persist handoff notes before the window expires
- use structured state for test matrices, task status, and machine-readable
  progress
- use short prose notes for rationale, next steps, and known blockers
- keep setup and verification commands discoverable so repeated sessions do not
  rediscover them from scratch
- when starting fresh, prefer live repo evidence over stale memory, then
  reconcile the memory files

Repo block:

```text
If context gets tight, preserve only the state needed to continue: current
objective, changed files, verification status, blockers, and next actions. Do not
stop early solely because the context window is low if the harness can continue
after compaction.
```

For this dotfiles repo, `.context/handoff.md` and `.context/tasks.md` are the
right place for live state. `/.context/knowledge/` is for reusable lessons that
would prevent repeated lookup or recurring mistakes.

## XML-Style Structure

Anthropic consistently recommends XML-style tags for complex prompts. Use them
when a prompt mixes instructions, context, examples, and input.

Good tags:

- `<instructions>`
- `<context>`
- `<examples>`
- `<input>`
- `<constraints>`
- `<output_format>`
- `<success_criteria>`
- `<documents>`

Avoid:

- arbitrary tags that obscure meaning
- deeply nested tags without need
- changing tag names across examples
- making every short prompt XML-heavy

## Examples

Claude responds strongly to examples. The docs recommend relevant, diverse, and
structured examples. For repo skills, examples should represent actual tasks and
edge cases, not toy cases.

### Structured output examples

```text
<examples>
  <example>
    <input>Shell startup behavior changed and verification passed.</input>
    <response>Summarize the changed behavior, name the verification command, and
    omit implementation narration.</response>
  </example>
  <example>
    <input>A command failed because a local dependency is missing.</input>
    <response>Name the missing dependency, explain the uncovered risk, and give
    the next best validation.</response>
  </example>
</examples>
```

### Handoff examples

```text
<example>
Current state: shared skill source lives under agents/skills and is deployed to
Codex through home/.agents/skills symlink nodes.
Next step: restart Codex and exercise the updated skill on a realistic request.
Verification: test/verify.sh passed.
</example>
```

## API Migration Notes

When moving to Opus 4.7:

- update model ID to `claude-opus-4-7`
- replace manual thinking budgets with adaptive thinking plus effort
- remove non-default `temperature`, `top_p`, and `top_k`
- remove assistant-message prefills
- explicitly request thinking summaries if the UI needs visible thinking
- retest token counting
- raise `max_tokens` and compaction headroom for high/xhigh/max effort workflows
- consider task budgets only when self-moderated token pacing is desired
- review tool parsing and stop reasons
- re-evaluate image token budget for high-resolution inputs

### Adaptive thinking shape

Use:

```text
thinking={"type": "adaptive"}
output_config={"effort": "high"}
```

Do not use manual budget style for Opus 4.7:

```text
thinking={"type": "enabled", "budget_tokens": 32000}
```

### Sampling migration

Remove non-default sampling parameters. Guide behavior with prompts instead of
temperature/top_p/top_k.

## Task Budgets

Task budgets are beta advisory caps for full agentic loops. They are not hard
limits. The model sees them and uses them to pace work. `max_tokens` remains the
hard per-request output ceiling and is not visible to the model.

The current minimum task budget is 20k tokens. Too-restrictive budgets can reduce
thoroughness or cause refusal, so treat task budgets as product-level pacing
controls rather than quality defaults.

Use task budgets when:

- the product needs work scoped to a token allowance
- graceful partial completion is acceptable
- agent loops may otherwise wander

Avoid task budgets when:

- quality matters more than cost
- open-ended exploration is required
- the minimum budget would still be too restrictive

Repo stance:

- Do not add task-budget assumptions to portable skills.
- Record the concept for future Claude harness work.
- Keep Codex skill behavior independent of Claude-specific beta controls.

## High-Resolution Images

Opus 4.7 supports higher-resolution images than prior Claude models: up to
2576px / 3.75MP, with model coordinates mapped 1:1 to actual pixels. This
matters for computer use, screenshot analysis, document analysis, and UI
inspection.

Prompt implications:

- request image fidelity only when needed
- downsample if exact visual detail is not needed
- remove coordinate scaling assumptions when using model-returned coordinates
- provide crop or zoom tools when screenshots contain dense UI or small text
- retest cost and token budget for image-heavy workflows

Repo implication:

- if future Claude harnesses inspect screenshots, specify whether visual fidelity
  or cost matters more
- preserve actual-image dimensions in bug reports when coordinate precision
  matters
- for computer-use workflows, verify that the model can inspect the relevant UI
  region before asking it to click, type, or report coordinates

## Common Failure Modes And Fixes

### It does too little at low effort

Cause:

- Opus 4.7 scopes tightly at low/medium effort.

Fix:

```text
Use high effort for this task. Before finalizing, check for hidden dependencies,
edge cases, and whether verification covers the changed behavior.
```

### It does not use tools enough

Cause:

- Opus 4.7 may reason more and call tools less.

Fix:

```text
Use tools whenever live repo state, current docs, command output, or verification
could change the answer. Do not answer from memory when the source of truth is
available.
```

### It follows a narrow example too literally

Cause:

- literal instruction following.

Fix:

```text
The examples illustrate style and structure, not a complete list of cases. Apply
the same rules to every finding and every changed file.
```

### It suppresses review findings

Cause:

- too-conservative review prompt.

Fix:

```text
In the finding-generation pass, optimize for coverage. Include low-confidence
findings with confidence labels. A later pass will filter severity.
```

### It gives too many updates

Cause:

- inherited progress scaffolding.

Fix:

```text
Update only on major phase changes, material findings, blockers, or changed plan.
Do not summarize routine tool calls.
```

## Prompt Blocks Library

### Opus 4.7 coding agent baseline

```text
You are a precise, autonomous coding agent. Make the requested change end to end
when the request is clear. Inspect live repo state before editing. Preserve
user-owned git state. Use tools for repo facts and verification. Ask only when
missing information materially changes the implementation or risk.
```

### Tool-use trigger

```text
Use tools for facts that depend on current files, commands, external docs, or
verification. If a fact is stable and already available in context, do not call a
tool just to reconfirm it.
```

### Literal-scope guard

```text
Apply these requirements to the whole task, every changed file, every reported
finding, and the final response unless a narrower scope is explicitly stated.
```

### Progress update guard

```text
Provide concise progress updates only when starting a major phase, discovering a
material fact, hitting a blocker, or changing the plan.
```

### Review recall guard

```text
For review, report every issue that could affect correctness, security, tests,
data integrity, or user-visible behavior. Include confidence and severity.
```

## Skill Design Implications

If adapting a Codex skill for Claude Opus 4.7:

- add explicit scope of applicability
- use examples for output style
- state when tools are required
- state subagent policy explicitly
- avoid broad "be conservative" wording unless precision is more important than recall
- avoid rigid progress cadence
- prefer prompt-level behavior control over sampling parameters
- keep output contracts concrete

Skill-specific model notes belong beside the source skill under `agents/skills/src/**/<skill>/model-notes/`.
Keep this guide focused on Claude Opus 4.7 behavior that generalizes across
skills; use per-skill notes for audits, tuning conclusions, and examples that
only apply to one skill.

## Evaluation Checklist

Use this checklist after retuning for Opus 4.7:

- Is effort high enough for the task type?
- Does the prompt state broad scope explicitly?
- Are examples representative and diverse?
- Are tool triggers explicit?
- Is progress-update scaffolding minimal?
- Does tone match the product?
- Does review guidance optimize for the right recall/precision tradeoff?
- Does the prompt require file inspection before codebase claims?
- Does long-horizon work have an explicit state-management strategy?
- Does it avoid retained clutter from temporary scaffolding?
- Are API parameters valid for Opus 4.7?
- Are thinking display and token budget handled intentionally?
- Are high-resolution image costs considered when relevant?
- Are task budgets avoided unless deliberately used?
- Are sampling parameters removed?

## Maintenance Notes

Revisit this guide when:

- Anthropic changes Opus 4.7 migration guidance.
- Claude Managed Agents expose different behavior.
- a Claude harness is added to this repo.
- a skill behaves too literally or too conservatively under Claude.
- future Claude models replace Opus 4.7 as the target.
