# Cursor Composer 2 Fast Guide

- Status: repo-authored guide derived from official Cursor docs, the Composer 2
  technical report, and local Cursor CLI behavior.
- Last reviewed: 2026-05-02.
- Primary cached sources:
  - `agents/official-docs/composer-2-technical-report.pdf`
  - `agents/official-docs/cursor-agent-cli-overview.md`
  - `agents/official-docs/cursor-agent-cli-usage.md`
  - `agents/official-docs/cursor-agent-cli-parameters.md`
  - `agents/official-docs/cursor-agent-cli-configuration.md`
  - `agents/official-docs/cursor-agent-cli-mcp.md`
  - `agents/official-docs/cursor-agent-rules.md`
- External sources to re-check when availability, pricing, or model ids matter:
  - <https://cursor.com/blog/composer-2>
  - <https://cursor.com/blog/composer-2-technical-report>
  - <https://docs.cursor.com/models>
- Repo consumers:
  - `agents/skills/artifacts/cursor-agent/composer-2-fast/skills/*/SKILL.md`
  - `agents/skills/src/**/model-notes/composer-2-fast.md`
  - `agents/harnesses/cursor-agent.md`
  - future Cursor Agent skills under `agents/skills/`

## Why this guide exists

Composer 2 Fast is a Cursor-hosted coding model variant intended for agentic
software engineering inside the Cursor harness. Cursor presents Composer 2 as a
domain-specialized coding model trained and evaluated in realistic Cursor
sessions, with the fast variant sharing the Composer 2 intelligence profile
while prioritizing lower latency for interactive developer workflows.

This file is not a complete copy of Cursor's docs. Do not treat it as canonical
for current pricing, availability, account access, model ids, or CLI flags.
Re-check the official Cursor docs and `cursor-agent --list-models` before
changing deployment targets.

The goal of this guide is to make Composer skill production as well-supported as
the GPT and Claude targets in this repo. It should give future agents enough
model and harness context to produce good Cursor artifacts without repeatedly
re-reading every cached official document.

## Verbatim Anchors

Use these short source phrases as anchors when checking whether this guide has
drifted from the official material:

- Composer 2 is described as a "specialized model" for agentic software
  engineering.
- The technical report emphasizes training in the "same Cursor harness" as the
  deployed model.
- The Cursor rules docs say good rules are "focused, actionable, and scoped."
- Cursor CLI docs say non-interactive print mode has "full write access."
- Cursor MCP docs say CLI MCP uses the "same configuration as the editor."

These anchors are intentionally short. The cached official docs remain the
authoritative source material.

## Executive Summary

Treat Composer 2 Fast as a production coding agent, not as a small helper model.
The "Fast" label describes the latency/cost tradeoff, not a permission to
water down the skill. It should be able to maintain runtime skill artifacts,
navigate the repo, inspect evidence, update files, and run verification.

Composer 2 is most interesting because it is trained and evaluated in a tool
harness close to the one it uses in production. Skill prompts should therefore
lean into agentic coding shape:

- clear outcome
- hard invariants
- concrete repository evidence
- scoped file ownership
- explicit verification
- final response contract

Do not over-specify ordinary engineering steps. Composer should not need a
micromanaged recipe for every search/read/edit operation. Do specify boundaries
where the model can do damage, especially git index ownership, generated
artifact handling, local state boundaries, and secrets.

Cursor's rules system and root `AGENTS.md` are important context sources. Avoid
duplicating root repo instructions inside Cursor skill artifacts. Instead,
runtime skills should describe the extra workflow they add after Cursor has
loaded project rules.

## How To Use This Guide

Use this file when:

- generating or updating a Cursor Agent runtime skill artifact
- writing `model-notes/composer-2-fast.md` for a skill
- deciding whether a behavior belongs in Cursor rules, root `AGENTS.md`, a
  source skill, a model guide, or a harness guide
- debugging Cursor Agent artifact production
- considering whether to manage more of `~/.cursor`

Do not use this file as:

- a live reference for Cursor pricing or account availability
- a substitute for `cursor-agent --list-models`
- a specification for Cursor's private config format
- a reason to hand-edit `agents/skills/artifacts/`

When tuning a skill, read in this order:

1. Source skill `SKILL.md`.
2. Skill-specific `model-notes/composer-2-fast.md`, if present.
3. This model guide.
4. `agents/harnesses/cursor-agent.md`.
5. Cached official Cursor docs only if the above are insufficient.

## Official Docs Coverage

The cached Cursor docs are narrower than the GPT and Claude prompt guides. They
focus on the CLI, rules, MCP, and the Composer 2 technical report. That means
this repo has to infer more guidance from product mechanics and training
details, while keeping live product claims out of committed guidance.

Useful cached docs:

- CLI overview: broad capabilities, interactive/non-interactive modes, sandbox
  controls, sessions, Cloud Agent handoff.
- CLI usage: plan/ask/agent modes, prompting, MCP, rules, CLI worktrees,
  command approval, print mode, write access.
- CLI parameters: exact flags and commands available to automation.
- CLI configuration: global/project config boundary, model selection, managed
  fields, permission arrays.
- CLI MCP: editor-shared MCP configuration and CLI MCP commands.
- Rules: project/user/team rules, `AGENTS.md`, nested `AGENTS.md`, activation
  modes, examples, and best practices.
- Composer 2 technical report: training/evaluation claims, long-horizon
  coding, CursorBench motivation, harness fidelity.

Useful uncached live references:

- Cursor models docs for current model ids and access.
- Composer 2 launch post for current public positioning.
- Cursor pricing/account docs for model gating.

## Technical Report Takeaways

The Composer 2 report frames the model as specialized for agentic software
engineering rather than as a general-purpose reasoning model. Its training
recipe has two main phases:

- continued pretraining with a code-heavy mixture to strengthen base coding
  knowledge
- large-scale reinforcement learning in Cursor-like sessions to improve
  end-to-end agent performance

The practical consequence is that Composer 2 should be good at realistic coding
tasks where the answer is not a single isolated patch. It should receive enough
repository context and enough freedom to inspect the codebase, identify the
right files, make coordinated edits, and verify the result.

The report's emphasis on harness fidelity matters for skill production. A skill
variant targeting Cursor should be authored by Cursor Agent when possible,
because Cursor's own model behavior was shaped around Cursor-style tools and
sessions. If Cursor cannot run, leave artifacts stale or record an explicit
fallback production exception.

CursorBench is described as closer to real software engineering than many public
benchmarks: terse prompts, ambiguous intent, multi-file changes, production log
analysis, code quality, execution efficiency, and interactive behavior. This
means Composer skills should not assume the user will over-specify the solution.
They should clarify or infer when reasonable, but pin non-negotiable repo rules.

The report also values efficient agent behavior. Composer 2 Fast should not be
encouraged to do exhaustive exploration by default. Give it enough evidence
requirements to avoid guessing, then let it stop once it has what it needs.

## Model Stance

Treat Composer 2 Fast as:

- high-trust for ordinary coding implementation
- high-trust for multi-file repository navigation
- high-trust for following concise, concrete rules
- medium-trust for preserving subtle local workflow boundaries unless they are
  explicit
- low-trust for live product/account/pricing facts unless it re-checks them

Composer 2 Fast is a good fit for:

- producing Cursor Agent skill artifacts
- maintaining short operational skills
- implementing repo automation
- refactoring across shell/docs/config files
- using root `AGENTS.md` plus targeted model notes
- fast iterative review loops

Composer 2 Fast is not the first choice for:

- deriving live Cursor account policy
- replacing official docs with memory
- producing long vendor-reference summaries without source review
- silently resolving harness-generation failures through another harness
- broad security-policy interpretation

## Prompting Posture

Use outcome-first prompts. Composer should know what "done" means before it
starts editing.

Good shape:

```text
Update the Cursor Agent variant of this skill. Preserve the source skill's hard
invariants, use root AGENTS.md for repo rules, keep the artifact concise, and do
not touch generated artifacts outside the selected target.
```

Weak shape:

```text
Please improve this skill and make it better for Cursor.
```

Composer benefits from concrete constraints more than long lectures. Put the
hard rules early and phrase them as invariants.

Good invariant examples:

- Preserve the user's git index exactly.
- Do not hand-edit runtime artifacts.
- Do not manage the full Cursor config file.
- Keep official docs unmodified.
- Produce only `SKILL.md` for Cursor artifacts unless the harness config changes.

Avoid burying critical constraints in later explanatory paragraphs. Cursor's
non-interactive mode can edit files and run shell commands, so the prompt must
make destructive boundaries obvious.

## Specificity And Freedom

Give Composer freedom where the codebase should guide the implementation:

- which files to inspect
- how to phrase the final runtime artifact
- whether a context note needs updating
- which targeted verification is relevant

Constrain Composer where repo state can be damaged:

- git index and commits
- runtime artifact production path
- official docs cache
- local state files
- secrets
- unsupported harness/model fallbacks

Avoid step-by-step scripts unless order is part of the contract. Composer was
trained for agentic coding tasks; too much procedural detail can crowd out the
repo evidence that should drive the work.

## Reasoning And Planning

Composer 2 Fast should not need elaborate thinking instructions for normal repo
work. Give it explicit success criteria and let the harness manage internal
reasoning.

Use short planning requirements when:

- the task touches multiple repository layers
- artifact production has stale stamps
- the change might cross source/artifact boundaries
- the harness might not be available
- the user is asking to compare approaches

Do not require a visible plan for every small doc edit. This repo's general
agent instructions already handle planning posture.

When a plan is useful, it should name verification:

```text
Success means the source skill and Composer model notes are updated, runtime
artifacts are left untouched, `update-skill.bash --action check` passes for the
selected target, and the full verify suite passes if code changed.
```

## Tool Use

Composer should use standard codebase tools:

- `rg` and `rg --files` for discovery
- file reads before edits
- updater scripts for runtime artifacts
- `git status --short --branch --untracked-files=all` for dirty-tree scope
- targeted shell checks before full verification when shell scripts change

Do not ask Composer to use Cursor MCP by default. Cursor CLI may discover MCP
servers configured for the editor, but repo artifact production should be
repeatable without them.

If MCP is required for a future skill, say exactly which MCP server is required,
why it is required, and whether `--approve-mcps` is expected. Otherwise, leave
MCP out of the updater runner.

## Cursor CLI Harness Mechanics

Cursor CLI supports interactive agent mode, plan mode, ask mode, and
non-interactive print mode. For artifact production, this repo uses
non-interactive print mode through `cursor-agent --print` with text output so
the updater scripts can capture the final response and validate files.

Current runner shape:

```text
runner_args: [--print, --output-format, text, --trust, --force, --sandbox, disabled]
```

The rationale:

- `--print` is the automation surface.
- `--output-format text` keeps updater output simple.
- `--trust` avoids headless workspace trust prompts.
- `--force` avoids command approval prompts inside a scoped artifact update.
- `--sandbox disabled` is a local compatibility choice approved by Anthony
  after `--sandbox enabled` failed on this macOS install.

Do not add flags reflexively:

- Do not add `--model`; the repo policy is to use each harness's local
  configuration as the authoring model.
- Do not add `--worktree`; artifact updates are intended to edit the current
  checkout.
- Do not add `--mode ask`; artifact updates require writes.
- Do not add `--mode plan`; the updater prompt is already scoped.
- Do not add `--approve-mcps` unless a selected workflow explicitly requires
  MCP.

## Cursor Config Boundary

Cursor CLI global config lives at `~/.cursor/cli-config.json`. Official docs say
project config only supports permissions; other CLI settings are global.

This repo should not manage the whole Cursor config file because it can contain:

- auth-related state
- local model picker state
- permission state
- privacy/cache/server data
- CLI-managed fields
- machine-specific defaults

The current dotfiles boundary is intentionally narrow:

- manage `home/.cursor/skills/<skill>` symlink nodes
- do not manage `home/.cursor/cli-config.json`
- discover live model targets from config when present
- use explicit `--harness cursor-agent --model composer-2-fast` for repo-home
  symlink bootstrapping

Observed local config exposes `modelId`; public docs describe a `model` object.
Keep `model_config_key: modelId` explicit in `cursor-agent.yaml` until a real
reason appears to support more shapes.

## Cursor Rules And AGENTS.md

Cursor Agent reads project rules, user rules, team rules, and `AGENTS.md`.
Official Cursor docs describe `AGENTS.md` as a simple markdown alternative to
structured `.cursor/rules`, and note nested `AGENTS.md` support.

Use root `AGENTS.md` as the shared repo contract. It already benefits Cursor
Agent, Codex, and other harnesses that honor it.

Use `.cursor/rules` only when Cursor-specific activation semantics matter:

- always-apply Cursor-only behavior
- file-glob-scoped guidance
- manually attached Cursor rules
- team-facing Cursor rule import/export workflows

Do not duplicate root `AGENTS.md` inside Cursor skills. Runtime skills should
describe the workflow delta, not restate the entire project contract.

Expect external rule layers to exist. Team rules can take precedence over user
rules, and user rules can add personal preferences. Skill artifacts should not
try to nullify those layers. They should state repo invariants that must hold
regardless of personal style.

## Rules-Style Guidance For Skills

Cursor's rule docs recommend focused, actionable, scoped rules. Apply the same
pressure to Cursor runtime skills:

- Keep the skill tight enough to load directly.
- Use concrete examples when ambiguity would cause errors.
- Reference files instead of copying large source material.
- Avoid documenting commands the base agent already knows.
- Avoid edge-case policies that rarely apply.
- Add instructions when an actual repeated failure appears.

This does not mean all model guidance should be short. This model guide can be
long because it is loaded by the updater prompt as source material, not as the
runtime skill that fires during every user task.

Runtime artifact target:

- usually under 500 lines
- often much shorter for one workflow
- must preserve invariants
- should avoid background essays

Model guide target:

- deep enough to prevent repeated harness mistakes
- organized by retrieval sections
- includes failure modes and prompt blocks
- can be 500-2000 lines when source material justifies it

## Runtime Skill Shape

Cursor Agent skill artifacts currently use only:

```text
SKILL.md
```

Do not add:

- Codex `agents/openai.yaml`
- Claude `model` frontmatter
- updater stamps
- README files
- hidden build metadata

Use frontmatter:

```yaml
---
name: commit-prep
description: ...
---
```

Cursor supports `disable-model-invocation: true` for explicit-only skills. Omit
it when the skill should be available through natural language invocation.

For `commit-prep`, omission is intentional because users naturally ask for
commit prep, journaling, handoff notes, and commit messages.

## Artifact Production Policy

Runtime artifacts are maintained outputs. Do not hand-edit or directly generate
files under:

```text
agents/skills/artifacts/
```

Use:

```text
agents/scripts/update-skill.bash --harness cursor-agent --model composer-2-fast --action run <skill>
```

or:

```text
agents/scripts/update-all.bash --harness cursor-agent --model composer-2-fast
```

The scripts matter because they provide:

- common updater prompt
- selected harness adapter
- model guide
- skill-specific model notes
- existing artifact context
- output validation
- digest stamp handling

If Cursor Agent cannot run because of auth, sandboxing, account limits, or a
missing executable, leave the artifact stale. Give Anthony the exact command to
run from a normal shell. Do not silently patch the artifact with Codex.

Fallback harness production is an explicit exception, not normal operation. If
Anthony approves it, record the exception in `.context`.

## Prompt Blocks Library

### General Cursor Skill Update

```text
Update the Cursor Agent runtime artifact for this source skill.

Use the source SKILL.md as canonical behavior, the Composer 2 Fast guide for
model-specific guidance, and cursor-agent.md for harness shape. Preserve useful
existing artifact phrasing, but correct anything that conflicts with source,
model notes, or harness policy.

Do not edit other harness artifacts. Do not stage, unstage, or commit. Keep the
Cursor artifact concise and operational.
```

### Artifact Boundary Reminder

```text
Runtime artifacts are maintained outputs. Edit only the selected artifact target
because this updater run is the production path for that target. Do not update
stamps manually; the runner owns stamp handling.
```

### Cursor Config Boundary

```text
Do not manage the full Cursor CLI config. This repo manages skill symlink nodes
under home/.cursor/skills and leaves ~/.cursor/cli-config.json as local state.
If model discovery is needed, use the harness config model_config_key.
```

### Commit-Prep Cursor Variant

```text
For commit-prep, preserve full-dirty-tree scope by default, preserve the user's
git index exactly, update durable context selectively, and draft the commit
message in the repo's current format. Keep the Cursor artifact focused on this
workflow and avoid duplicating root AGENTS.md.
```

### Account Or Sandbox Blocker

```text
If Cursor Agent cannot run because of auth, account/model policy, sandbox
availability, or a missing executable, stop and report the blocker. Leave the
artifact stale. Do not author the target artifact through another harness unless
Anthony explicitly approves fallback production.
```

## Skill Design For Composer

Good Composer runtime skills:

- name when to use the skill in the description
- start with outcome and success criteria
- list invariants before workflow
- identify required evidence
- avoid duplicating root instructions
- keep final response requirements explicit
- mention verification expectations
- name any files that are uniquely important
- state what not to touch

Weak Composer runtime skills:

- explain generic software engineering at length
- assume Cursor cannot read `AGENTS.md`
- omit destructive boundaries
- conflate source skills with runtime artifacts
- add Codex or Claude metadata
- rely on MCP without saying so
- leave final output shape ambiguous

Composer is trained for realistic coding sessions, so a skill can assume the
model understands normal repo work. Spend tokens on the workflow-specific
rules that are not obvious from general coding ability.

## Migration Pattern For Existing Skills

When adding a Cursor/Composer variant for an existing skill:

1. Confirm the source skill has clear frontmatter and invariants.
2. Add or update `model-notes/composer-2-fast.md` only for skill-specific
   tuning.
3. Confirm `agents/models/composer-2-fast.md` covers generic model behavior.
4. Confirm `agents/harnesses/cursor-agent.md` covers harness shape.
5. Run `update-skill.bash --harness cursor-agent --model composer-2-fast`.
6. Review the artifact as maintained output.
7. Run `update-skill.bash --action check` for the target.
8. Run relevant repo verification.
9. Record blockers if Cursor could not produce the artifact.

Do not copy the Codex artifact and tweak it by hand. If the Cursor run fails,
the correct state is stale plus a blocker, not a manually synchronized artifact.

## Common Failure Modes And Fixes

### Artifact output gets too generic

Cause: The prompt relied on Composer's general coding ability but did not name
the repo-specific invariant.

Fix: Add or strengthen the invariant in source `SKILL.md` or
`model-notes/composer-2-fast.md`, then regenerate through the updater.

### Artifact duplicates root AGENTS.md

Cause: Cursor rules and `AGENTS.md` are being treated as unavailable to the
runtime model.

Fix: Keep the skill focused on the workflow delta. Reference repo instructions
instead of copying them.

### Artifact assumes Cursor config is repo-managed

Cause: The model saw `~/.cursor/cli-config.json` in official docs and treated it
as a normal dotfile target.

Fix: Reassert the repo boundary: full Cursor config is local state for now; only
`home/.cursor/skills/<skill>` symlink nodes are managed.

### Artifact adds unsupported sidecar files

Cause: The model generalized from Codex `agents/openai.yaml` or other harness
shapes.

Fix: Cursor artifacts currently contain only `SKILL.md`. If that changes, update
`cursor-agent.yaml` outputs first.

### Artifact edits official docs

Cause: The model treats cached docs as working material instead of source
material.

Fix: Official docs are authoritative caches. Replace them with fresh vendor
exports; do not hand-edit them.

### Cursor account rejects the selected model

Cause: Cursor account/model policy can block named model runs even when
`cursor-agent --list-models` advertises a model.

Fix: Leave the artifact stale. Do not use another harness silently. Either run
the updater after account access changes, or record an explicit fallback
production exception.

### Sandbox mode blocks production

Cause: Cursor CLI sandbox availability varies by installation/platform.

Fix: Keep the selected harness config explicit. This repo currently uses
`--sandbox disabled` for Cursor Agent after Anthony approved that local
relaxation.

### Prompt becomes too long for artifact production

Cause: The model guide, official docs, source skill, and existing artifact all
compete for context.

Fix: Keep the updater prompt selective. Prefer this derived model guide over
bulk-loading every Cursor official doc unless the task specifically needs it.

### Cursor skill does not auto-trigger

Cause: Description is too vague, or `disable-model-invocation: true` was added.

Fix: Make the description specific about user requests that should trigger the
skill. Omit `disable-model-invocation` unless explicit-only behavior is desired.

### Cursor artifact ignores source-skill changes

Cause: Existing artifact phrasing was preserved too aggressively.

Fix: Source skill wins. Existing artifact text is input for continuity, not a
reason to preserve stale behavior.

## Evaluation Checklist

For a Cursor/Composer skill artifact, check:

- Does `SKILL.md` preserve source-skill invariants?
- Is the artifact concise and operational?
- Does frontmatter include `name` and `description`?
- Is `disable-model-invocation` absent unless explicit-only use is intended?
- Are Codex/Claude-only files and metadata absent?
- Does the artifact avoid duplicating root `AGENTS.md`?
- Does it name required evidence?
- Does it state final response shape?
- Does it preserve git index ownership when relevant?
- Does it avoid managing full Cursor config?
- Does it avoid depending on MCP without an explicit reason?
- Does `update-skill.bash --action check` pass?
- Does the digest stamp reflect a successful native harness run?

For commit-prep specifically:

- Full dirty tree is default scope.
- Staged-only is only explicit-user-request scope.
- Context updates are selective.
- Verification is reported clearly.
- Commit message follows repo format.
- Excluded dirty files are listed only for narrowed scope.
- Runtime artifact production blockers are not hidden.

## Maintenance Notes

Keep this guide deeper than a README but shorter than the official docs cache.
The target range is roughly the same as the GPT and Claude guides: enough detail
to prevent repeated harness mistakes, not a full vendor-doc mirror.

When Cursor releases a new Composer model:

1. Cache official exportable docs where appropriate.
2. Add `agents/models/<model>.md`.
3. Add skill-specific model notes only when the generic guide is insufficient.
4. Add or update artifacts through `update-skill.bash`.
5. Deploy symlinks with `symlink-skill.bash` or `symlink-all.bash`.
6. Leave old artifacts available until Anthony decides which model should be
   deployed.

When Cursor docs change:

- Replace cached official docs with fresh exports.
- Update this guide with derived implications.
- Do not edit copied official docs directly.
- Re-run artifact status checks; guidance changes should make affected
  artifacts stale until native harnesses review them.

## Commit-Prep Specific Notes

For `commit-prep`, Composer 2 Fast should:

- inspect the full dirty tree by default, not only staged files
- preserve the index exactly
- update context only when it helps future review or resumption
- treat runtime skill artifacts as produced outputs that must flow through
  updater scripts
- draft commit messages in the repo's current imperative format
- report stale/unrefreshed artifacts plainly instead of pretending they were
  regenerated

If the canonical source skill changes, regenerate the Cursor artifact with:

```text
agents/scripts/update-skill.bash --harness cursor-agent --model composer-2-fast --action run commit-prep
```

If that command fails due to Cursor account/model restrictions, leave the
artifact stale and record the blocker.
