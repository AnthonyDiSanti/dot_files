# OpenAI GPT-5.5 Prompt Guide

- Status: repo-authored guide derived from official docs.
- Last reviewed: 2026-04-29.
- Primary sources:
  - [Using GPT-5.5](https://developers.openai.com/api/docs/guides/latest-model)
  - [GPT-5.5 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance?model=gpt-5.5)
  - [OpenAI models](https://developers.openai.com/api/docs/models)
  - [Codex models](https://developers.openai.com/codex/models) for current
    Codex model availability and CLI selection guidance; intentionally left as
    a live external reference.
- Repo consumers:
  - `agents/skills/artifacts/codex/gpt-5.5/skills/*/SKILL.md`
  - future Codex skills under `agents/skills/`
  - global/project AGENTS instruction tuning

## Why this guide exists

The official GPT-5.5 guidance is long and intentionally broad. This file is a
working prompt-engineering reference for this dotfiles repo: it preserves the
parts that matter when writing Codex skills and agent instructions, translates
the official guidance into reusable local patterns, and records example prompt
blocks that can be copied into future skills.

This is not a complete copy of the official docs. Do not treat it as canonical
for API details, pricing, feature availability, parameter names, or product
status. Re-check the official sources before changing production API code or
retuning a major skill.

## Verbatim anchors

Short exact snippets from the official docs, kept intentionally small:

- "Shorter, outcome-first prompts usually work better"
- "treat it as a new model family"

Everything else in this file is paraphrase, synthesis, or repo-local adaptation.

## Executive Summary

GPT-5.5 should be prompted as a newer model family rather than a drop-in upgrade
from earlier GPT-5 models. The model tends to need less process scaffolding and
more clearly stated outcomes. Good prompts describe the destination, success
criteria, constraints, allowed side effects, evidence rules, and output shape.
They usually avoid detailed step-by-step instructions unless the exact sequence
is part of the product contract.

For this repo, the central lesson is that skills should be shorter and more
contract-like. A skill should tell Codex what must be true, what must never be
done, what evidence to inspect, what durable state to update, and what final
artifact to produce. It should not become a procedural essay that repeats the
agent's base instructions.

The second lesson is that GPT-5.5 tuning is multi-dimensional. Reasoning effort,
verbosity, output shape, tool descriptions, validation loops, and prompt caching
are separate levers. Raising reasoning effort is not the first answer to every
quality problem; often the prompt needs clearer completion criteria, better
tool-use boundaries, or a smaller/firmer output contract.

## How To Use This Guide

Use this guide when:

- writing or revising a Codex skill
- tuning `AGENTS.md` instructions for GPT-5.5
- deciding whether a skill should be shorter or more explicit
- evaluating whether a task needs higher reasoning effort
- designing final-response shape for a skill or agent workflow
- converting legacy process-heavy instructions to outcome-first instructions

Do not use this guide as:

- a full replacement for official OpenAI docs
- an API reference
- a source for current model pricing or availability
- a justification for changing Codex model slugs without checking the live Codex
  models page

## Model Stance

GPT-5.5 is positioned as OpenAI's flagship for complex reasoning and coding. The
official docs emphasize complex production workflows, coding, tool-heavy agents,
grounded assistants, long-context retrieval, product-spec-to-plan workflows, and
customer-facing tasks where execution quality matters.

For Codex work, assume GPT-5.5 can handle ambiguity and choose good local paths
when the contract is clear. It still benefits from explicit boundaries around
side effects, destructive actions, verification, and when to ask for help.

### Practical stance for this repo

The repo should prompt GPT-5.5 like a senior engineer:

- State the outcome.
- State the invariants.
- State the target evidence.
- State what must be verified.
- State the final artifact.
- Let the model choose the path.

Avoid treating GPT-5.5 like a brittle script runner. If a prompt includes many
sequential steps, ask whether those steps are truly required or whether they are
just one possible way to reach the outcome.

## Upgrade Implications

When moving a prompt or skill to GPT-5.5:

1. Start with the smallest prompt that preserves the product contract.
2. Keep true invariants as hard rules.
3. Convert process lists into success criteria where possible.
4. Preserve verification and safety boundaries.
5. Remove redundant motivation and repeated rules.
6. Use output schema/tooling when a schema is strict.
7. Re-evaluate reasoning effort and verbosity after prompt cleanup.
8. Test on representative examples rather than relying on intuition.

The docs specifically warn against carrying over every instruction from older
prompt stacks. Older prompts often over-specified process because weaker models
needed more help. In GPT-5.5, that extra process can reduce search quality,
produce overly mechanical behavior, or conflict with a better local strategy.

## Outcome-First Prompting

Outcome-first prompting is the most important GPT-5.5 pattern.

An outcome-first prompt answers:

- What should be true when the task is done?
- What evidence should the model use?
- Which constraints are hard invariants?
- Which side effects are allowed?
- What validation is required?
- What should the final answer contain?
- When should the model stop, ask, or escalate?

It does not require:

- a fixed order of every file read
- a fixed number of tool calls
- a full narration of internal reasoning
- a mandatory plan when the task is already clear
- repeated instructions that duplicate platform policy

### Bad shape

This is a process-heavy shape:

```text
First inspect the repository. Then inspect every file. Then make a plan. Then
explain the plan. Then edit one file. Then run all tests. Then summarize all
changes. Always follow every step even for small changes.
```

Problems:

- Treats one path as universal.
- Makes small tasks expensive.
- Encourages mechanical compliance.
- May conflict with better repo-specific flow.
- Does not define what counts as done.

### Better shape

This is an outcome-first shape:

```text
Goal: make the requested repo change safely.

Success means:
- behavior matches the user request
- unrelated user changes are preserved
- changed files follow repo style
- targeted verification passes, or a blocker is explained
- the final answer names what changed and what was verified

Constraints:
- do not stage or discard user changes
- do not run destructive commands unless explicitly approved
- prefer existing repo patterns over new abstractions
```

Why this works:

- It gives the model room to choose the implementation path.
- It preserves hard safety rules.
- It defines done.
- It leaves room for proportional verification.

## Specificity And Hard Rules

GPT-5.5 can follow precise instructions well, but not every preference should be
written as a hard rule. Reserve words like `always`, `never`, `must`, and `only`
for real invariants.

Good hard rules in this repo:

- never discard user changes
- do not stage or unstage without explicit request
- do not store secrets in `.context`
- use `apply_patch` for manual edits
- run full verification before declaring a risky code change complete

Bad hard rules:

- always read every file in a directory
- always write a plan before acting
- always include exactly five bullets
- never ask a question under any circumstances
- always run the full suite for documentation-only edits

Turn judgment calls into decision rules:

```text
Ask a question only when the missing answer materially changes the implementation
or creates meaningful risk. Otherwise make a conservative assumption and proceed.
```

```text
Run the full suite for bootstrap, shell startup, or behavior changes. For
documentation-only edits, run lightweight checks that are available and relevant.
```

```text
Use subagents only when work can proceed in parallel and the delegated task has
a clear, non-overlapping scope.
```

## Reasoning Effort

The official GPT-5.5 docs make reasoning effort a tuning knob, not a replacement
for clear prompts. `medium` is the default and balanced starting point. `low` can
be worth evaluating before `none` for latency-sensitive tasks that still involve
tool use, planning, search, or multi-step decisions. `high` and `xhigh` should be
reserved for hard agentic work or evals where quality gains justify cost/latency.

### Repo guidance

Use default inherited effort for normal work unless there is a clear reason to
override it.

Use lower effort for:

- simple documentation edits
- local grep/read-only status checks
- direct command-output questions
- low-risk formatting or wording tweaks

Use normal/medium effort for:

- most dotfile edits
- prompt/skill revisions
- shell config changes
- local test debugging

Use high/xhigh effort for:

- large refactors
- multi-system debugging
- complex bootstrap semantics
- long-running agentic tasks
- broad prompt architecture changes

Before raising effort, improve:

- success criteria
- stop rules
- tool descriptions
- verification loop
- output contract
- task boundaries

### Failure modes at too-high effort

Higher effort can be counterproductive when the prompt is vague or contradictory.
Likely symptoms:

- over-searching
- unnecessary multi-step plans
- premature abstraction
- treating optional work as mandatory
- spending too long reconciling conflicting rules
- final answers that are longer than the user wanted

Fix the prompt before increasing effort.

## Verbosity

GPT-5.5 separates final answer length from reasoning quality. Use verbosity and
output instructions to control the visible answer.

For this repo:

- final answers should usually be concise
- progress updates should be short and high-signal
- detailed reasoning should appear only when it helps the user decide
- commit messages should be copyable and not overexplained
- skill bodies should be compact but complete enough to steer behavior

### Useful output controls

```text
Final answer:
- 1 short paragraph for simple changes
- bullets only when they improve scanning
- include verification run
- include blockers plainly
```

```text
Keep the answer under 300 words unless the user asks for details.
```

```text
Prefer short paragraphs over dense bullet lists.
```

```text
Return only the requested commit message in a fenced text block.
```

For editing tasks:

```text
Preserve the requested artifact, length, structure, and genre. Improve clarity
and correctness without adding new claims or expanding the scope.
```

## Personality And Collaboration Style

The docs distinguish personality from collaboration style. Personality is how
the assistant sounds. Collaboration style is how it works with the user.

For this repo, personality should stay pragmatic, direct, and respectful. The
model should assume Anthony is technically competent and should avoid unnecessary
validation or cheerleading.

Collaboration style should emphasize:

- forward progress
- preserving user state
- concise status updates
- surfacing meaningful tradeoffs
- asking only narrow necessary questions
- documenting durable learnings

### Repo-adapted personality block

```text
You are a pragmatic senior software engineer. Be direct, specific, and calm.
Assume the user is technically competent. Prefer concrete tradeoffs and evidence
over reassurance. Keep final answers concise unless the user asks for depth.
```

### Repo-adapted collaboration block

```text
Default to making progress when the request is clear enough. Ask a question only
when the answer materially changes the implementation or creates meaningful risk.
Preserve user-owned state, especially git staging. Keep updates short and useful.
```

## Preambles And Visible Progress

GPT-5.5 may spend time reasoning or preparing tool calls before emitting visible
text. For long or tool-heavy tasks, a short preamble improves perceived
responsiveness.

For Codex in this repo, a good preamble:

- names the immediate first step
- names what evidence will be gathered
- avoids promising a plan before looking
- stays one or two sentences

Example:

```text
I’ll inspect the current diff and repo instructions first, then update the skill
and run the relevant checks. I’ll leave staging untouched.
```

Bad preamble:

```text
I will carefully analyze every aspect of the repository and ensure a perfect
solution using best practices.
```

Why bad:

- too vague
- too grandiose
- no concrete next step
- no user-state boundary

## Tool Use

GPT-5.5 is strong at tool selection, but prompt quality still matters on large
tool surfaces. Put tool-specific guidance in tool descriptions where possible.
Use system/skill instructions for cross-tool policy.

Tool descriptions should include:

- what the tool does
- when to use it
- required inputs
- side effects
- retry safety
- common failure modes

Skill instructions should include:

- which tools are allowed or forbidden
- whether the user must approve side effects
- what evidence should be collected
- how to handle failures
- how to verify results

### Repo examples

For shell commands:

```text
Use shell commands to inspect repo state and run verification. Do not use shell
commands that discard, reset, or rewrite git state unless explicitly requested.
```

For Git:

```text
Read git status and diffs freely. Do not stage, unstage, commit, amend, reset,
restore, or rebase unless the user explicitly asks.
```

For web:

```text
Use web search for current vendor guidance, pricing, model availability, or
prompt guides. Prefer official vendor docs. Record source URLs in repo notes.
```

## Phase Handling

The official docs call out `phase` handling for tool-heavy Responses workflows.
The important idea: intermediate user-visible updates and final answers are
different assistant item types. If an application manually replays assistant
output items between Responses API calls, it must preserve the phase values.

Repo implication:

- Codex itself handles this at the harness level.
- Prompt guides should still distinguish progress updates from final answers.
- Skills should not ask the model to turn progress updates into summaries unless
  the user needs that.
- Final response rules should specify what belongs in final, not commentary.

### Practical wording

```text
Progress updates are not final answers. Use them only to communicate current
phase, important findings, or changed plan. Put results, verification, and commit
messages in the final response.
```

## Grounding, Citations, And Retrieval Budgets

GPT-5.5 guidance emphasizes defining evidence rules and retrieval budgets. For
repo work, this maps to reading enough files/diffs to be correct without turning
every question into a broad audit.

### Retrieval budget for repo questions

```text
Start with the files directly named by the user, the relevant repo instructions,
and the smallest search that identifies affected call sites. Expand only when:
- the first files do not explain behavior
- a dependency/caller is missing
- verification fails
- the change touches shared behavior
- the user asked for a broad review
```

### Retrieval budget for vendor docs

```text
Use official docs first. Capture source URLs. Do not keep searching after the
official docs answer the question unless the user asked for ecosystem comparison,
current adoption, or conflicting-source analysis.
```

### Missing evidence behavior

```text
If the available evidence is enough to answer, answer from it. If a required
fact is missing, name the missing fact and the smallest next lookup needed.
Do not convert absence of evidence into a factual negative.
```

## Creative Drafting And Source Boundaries

The official docs call out a subtle risk in drafting tasks: the model may blend
source-backed claims with creative framing unless the prompt separates them. This
matters for release notes, README copy, commit summaries, PR descriptions,
leadership blurbs, and any user-facing narrative built from facts.

For repo work, the rule is simple:

- facts about code, tests, config, docs, and decisions must come from inspected
  evidence
- wording, structure, transitions, and emphasis may be creatively improved
- unsupported facts should become questions, placeholders, or omitted claims
- when the user asks for polished prose, preserve the evidence boundary

Useful block:

```text
Use inspected sources for factual claims. You may improve wording, organization,
and emphasis, but do not invent code behavior, verification results, timelines,
or decisions. If a useful claim is unsupported, omit it or mark it as unknown.
```

For `commit-prep`, this means commit messages should describe the current diff,
not the agent's intended plan, guessed motivation, or unverified test coverage.

## Verification Loops

GPT-5.5 should be asked to check its work when validation is possible. This repo
already has a strong verification culture: targeted checks first, full gate when
behavior changes or risk warrants it.

### General validation wording

```text
After changes, run the most relevant available validation:
- targeted syntax/lint/unit checks for changed files
- bootstrap dry-run for deployment-shape changes
- full `test/verify.sh` for shell/bootstrap/dotfile behavior
If validation cannot run, explain why and name the next best check.
```

### Commit-prep validation wording

```text
Record verification already run for the work. Run only safe, relevant checks
needed to prepare the commit. Do not run destructive or unusually long commands
just to draft a commit message.
```

### Visual validation wording

```text
Render visual artifacts before finalizing. Inspect the rendered output for
layout, clipping, spacing, missing content, and visual consistency. Revise until
the rendered output matches the requirements.
```

## Image Inputs, UI Work, And Computer Detail

GPT-5.5's image-input behavior is more detail-preserving by default than older
models, especially when `image_detail` is automatic. Treat image fidelity as a
prompt and cost lever rather than an invisible default.

Prompt implications:

- request original/high detail for coordinate-sensitive UI inspection,
  screenshots, diagrams, or small text
- use lower detail for broad visual context where exact pixels do not matter
- preserve screenshot dimensions when diagnosing layout or hit-target issues
- state whether the task values fidelity, speed, or token cost most

Repo implications:

- Playwright or terminal screenshots should be inspected at sufficient detail
  before declaring visual work complete
- UI guidance should describe product context, expected controls, responsive
  states, and design-system fit rather than asking for generic polish
- visual claims in final answers should be based on rendered evidence, not only
  code inspection

Useful block:

```text
For visual inspection, use the image detail level needed for the decision. If
coordinate precision, small text, or layout overlap matters, preserve original
image dimensions and inspect the rendered result before finalizing.
```

## Prompt Caching

GPT-5.5 supports prompt caching. The docs recommend stable content first and
dynamic content later. For Codex skills, this is mostly a design principle:

- keep stable rules in skill metadata/body
- keep volatile repo state out of skill bodies
- put task-specific context in the user request or current conversation
- avoid rewriting long shared instructions when a short skill hook suffices

Prompt-cache-friendly ordering:

1. role/personality
2. stable invariants
3. reusable workflow
4. output shape
5. current task context
6. current files/diffs/results

Bad ordering:

1. current task details
2. long volatile logs
3. stable instructions
4. more current task details

## Structured Outputs

For strict schemas, the docs recommend structured outputs rather than prose
schema instructions. In this repo, that usually means:

- skills should not embed large JSON schemas unless the harness cannot enforce
  them elsewhere
- commit messages can remain markdown/text because they are human artifacts
- future tool-driven workflows should prefer structured tool/schema layers
- prompt guides should record schema intent but not become schema validators

When prose is enough:

- commit messages
- handoff notes
- decisions
- review findings

When structured outputs may be better:

- machine-ingested task reports
- automation status
- issue creation payloads
- generated config fragments with strict syntax

## Coding Agent Orchestration

The GPT-5.5 guide says coding workflows need stronger orchestration. For this
repo, orchestration should cover:

- codebase navigation
- preserving user changes
- when to use subagents
- test expectations
- acceptance criteria
- continue-versus-ask rules
- final response shape

### General coding-agent block

```text
Persist until the requested change is handled end to end when feasible. Inspect
the relevant code first. Preserve user changes. Prefer existing patterns. Run
targeted checks before the full gate when behavior changes. Ask only when missing
information materially changes the implementation or creates meaningful risk.
```

### Subagent block

```text
Use subagents only for bounded work that can run in parallel without blocking the
next local step. Give each subagent a concrete output and non-overlapping write
scope. Do not delegate the immediate blocker if the main rollout can handle it
directly faster.
```

### Code-review block

```text
Lead with findings ordered by severity. Include file and line references. Focus
on bugs, regressions, missing tests, security risks, and behavioral mismatches.
If no issues are found, say so and name residual risk or test gaps.
```

## Skill Design For GPT-5.5

Skills should be triggerable, compact, and concrete. They should not duplicate
the full AGENTS contract. The metadata decides when the skill loads, so it should
be specific and include common user phrasings.

### Skill anatomy

Good GPT-5.5 skill bodies include:

- goal
- when to use
- non-negotiable invariants
- success criteria
- small workflow
- output contract
- verification expectations

They avoid:

- long generic explanations
- duplicate global rules
- motivational text
- examples that are not actually used
- brittle command lists for every case
- broad "always do everything" requirements

Skill-specific model notes belong beside the source skill under `agents/skills/src/**/<skill>/model-notes/`.
Keep this guide focused on GPT-5.5 behavior that generalizes across skills; use
per-skill notes for audits, tuning conclusions, and examples that only apply to
one skill.

## Migration Pattern For Existing Skills

Use this sequence when retuning a skill for GPT-5.5:

1. Identify the actual outcome.
2. Identify the hard invariants.
3. Identify evidence needed before acting.
4. Convert procedural steps into success criteria.
5. Keep only required procedural order.
6. Add a small verification rule.
7. Add final response shape.
8. Remove duplicated global instructions.
9. Re-run skill discovery.
10. Test on a realistic user request.

### Before

```text
First run git status. Then run git diff. Then run git diff --cached. Then read
AGENTS.md. Then read README.md. Then update context. Then draft a commit message.
```

### After

```text
Prepare this work for commit. Success means the proposed commit message is based
on live git state, useful context is current, verification status is recorded,
and the user's staging choices are preserved exactly.
```

The second version still allows specific commands where needed, but it does not
make the command order the core product.

## Common Failure Modes And Fixes

### The model stops too early

Likely cause:

- weak success criteria
- no verification requirement
- final answer allowed before work is done

Fix:

```text
Do not send the final answer until changed behavior has been verified or a
specific blocker prevents verification.
```

### The model overworks a simple task

Likely cause:

- too many absolute process rules
- high reasoning effort
- broad exploration instructions

Fix:

```text
Use the smallest evidence set sufficient for the requested change. Expand only
when the first evidence set is ambiguous, incomplete, or verification fails.
```

### The model asks too many questions

Likely cause:

- unclear autonomy rule
- no assumption policy

Fix:

```text
Ask only when the answer materially changes the implementation or risk profile.
Otherwise proceed with a conservative assumption and state it.
```

### The model gives too much final explanation

Likely cause:

- no final answer budget
- verbosity left at default

Fix:

```text
Final answer should be concise: what changed, what was verified, and any blocker.
Use bullets only when they improve scanning.
```

### The model misses hidden side effects

Likely cause:

- no side-effect inventory
- tool descriptions omit destructive behavior

Fix:

```text
Before using a tool with side effects, identify whether it changes files, git
state, external services, local settings, or user data. Request approval where
the repo or harness requires it.
```

## Prompt Blocks Library

These are repo-adapted reusable prompt blocks.

### Outcome contract

```text
# Goal
[State the user-visible outcome.]

# Success criteria
- [Observable condition]
- [Observable condition]
- [Verification condition]

# Constraints
- [Hard invariant]
- [Side-effect boundary]

# Output
[Final artifact shape]
```

### Verification contract

```text
Run targeted checks for the changed surface first. Run the full gate when the
change affects shared behavior, bootstrap, shell startup, or user-facing flows.
If a check cannot run, explain why and name the next best validation.
```

### Context hygiene contract

```text
Record durable learnings, not a transcript. Put live state in handoff/tasks and
reusable knowledge in knowledge notes. Prefer updating existing notes over adding
new files. Never store secrets.
```

### Concise final response

```text
Final answer:
- what changed
- what was verified
- final artifact or recommendation
- blockers or follow-ups
Keep it short.
```

## Evaluation Checklist

Use this checklist when judging a GPT-5.5 skill:

- Does metadata clearly describe when the skill should trigger?
- Does the body start with outcome and scope?
- Are hard invariants explicit and few?
- Are routine preferences written as decision rules instead of absolutes?
- Is the workflow short enough to leave room for model judgment?
- Does it say what evidence to inspect?
- Does it separate source-backed claims from creative wording?
- Does it define what "done" means?
- Does it define verification behavior?
- Does it define final output?
- Does it avoid duplicating global/project instructions?
- Does it protect user-owned state?
- Does it avoid secrets and sensitive logs?
- Does it link to deeper references instead of embedding everything?
- Does visual work specify the fidelity needed for the decision?
- Does a fresh Codex prompt discover it?
- Does a realistic test request produce the right behavior?

## Maintenance Notes

Revisit this guide when:

- OpenAI changes GPT-5.5 prompt guidance.
- Codex changes skill loading or metadata behavior.
- a repeated skill-tuning issue appears across multiple skills.
- a generic prompt block starts encoding one skill's workflow too tightly.
- a new OpenAI model replaces GPT-5.5 as the primary Codex model.

When updating:

1. Check official OpenAI docs.
2. Update source URLs if changed.
3. Preserve the derivative-not-mirror boundary.
4. Keep examples repo-adapted.
5. Rerun skill discovery and repo verification where relevant.
