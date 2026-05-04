# Gemini 3.1 Pro Preview

## Source References

Cached source documents:

- `agents/official-docs/gemini-3-developer-guide.md`
- `agents/official-docs/gemini-3-getting-started.md`
- `agents/official-docs/gemini-3-thinking.md`
- `agents/official-docs/gemini-3.1-pro.md`
- `agents/official-docs/gemini-cli/docs/get-started/gemini-3.md`
- `agents/official-docs/gemini-cli/docs/cli/model.md`
- `agents/official-docs/gemini-cli/docs/cli/model-routing.md`
- `agents/official-docs/gemini-cli/docs/reference/configuration.md`

Intentionally uncached live references:

- Google AI Gemini models reference:
  <https://ai.google.dev/gemini-api/docs/models>
- Google Gemini 3.1 Pro announcement:
  <https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-1-pro/>

## Role In This Repo

Use `gemini-3.1-pro-preview` as the preferred Google-family target for demanding
coding, multi-step debugging, codebase reasoning, and Gemini CLI skill artifact
generation.

Treat this file as model guidance, not as the authoritative API reference. The
official docs above remain the source of truth for exact model ids, supported
parameters, launch stage, pricing, quotas, and availability.

Gemini 3.1 Pro Preview is a preview model. It is appropriate for personal and
experimental agent-workflow bring-up, but preview behavior, capacity, and routing
can change. Re-check the live model pages before broad team rollout or before
creating long-lived artifacts that assume exact model behavior.

## Core Capabilities

- Model id: `gemini-3.1-pro-preview`.
- Custom-tools endpoint: `gemini-3.1-pro-preview-customtools`.
- Inputs: text, code, images, audio, video, and PDFs.
- Output: text.
- Context: 1,048,576 input tokens and 65,536 output tokens.
- Knowledge cutoff: January 2025.
- Region: global for Vertex AI.
- Strong use cases: complex reasoning, autonomous coding, broad multimodal
  analysis, codebase-sized context, deep tool use, and difficult debugging.
- Supported API capabilities include system instructions, structured output,
  function calling, search grounding, code execution, count tokens, thinking,
  implicit and explicit context caching, RAG Engine, file/search-related flows,
  and OpenAI-compatible chat completions.
- Unsupported or limited capabilities include Gemini Live API, image output,
  content credentials, and native image segmentation in Gemini 3 Pro.

## Configuration Stance

- Prefer the strongest available Gemini Pro route for personal coding sessions.
- Configure personal Gemini CLI use with `model.name = "pro"` when the goal is
  the latest available Pro route, including preview releases.
- Keep maintained runtime artifact directories explicit and versioned. Map
  Gemini CLI's live `pro` alias to `gemini-3.1-pro-preview` in
  `agents/harnesses/gemini.yaml` while 3.1 Pro Preview is the preferred target.
- Preserve high reasoning for demanding coding work. Gemini CLI's `chat-base-3`
  already uses high thinking for Gemini 3; the managed config keeps a concrete
  `gemini-3.1-pro-preview` custom alias extending that baseline.
- Do not use `thinking_budget` for Gemini 3-family tuning. Use
  `thinking_level` / Gemini CLI `thinkingLevel` instead.
- If access is unavailable, fall back interactively through Gemini CLI's
  `/model` command, preferably to **Auto (Gemini 3)** or **Pro** rather than to
  Flash.

## Gemini CLI Routing

Gemini CLI has two distinct concepts that must stay separate:

- Live model preference: `model.name = "pro"` follows Gemini CLI's Pro route.
- Artifact/model guidance target: `gemini-3.1-pro-preview` stays concrete and
  versioned.

As of 2026-05-03 on this machine, a local `gemini --model pro
--output-format stream-json` run reported final usage under
`gemini-3.1-pro-preview`. That proves the current local `pro` route reaches
3.1 Pro Preview, but the route is still a harness alias. Keep artifact paths,
stamps, model notes, and model guide names concrete.

Gemini CLI may use `gemini-3.1-pro-preview-customtools` when 3.1 is available
and custom-tool routing is active. If a runtime artifact was authored through
that endpoint, record it in the updater output instead of pretending the plain
endpoint authored the file.

## Thinking Levels

Gemini 3 uses `thinking_level` rather than the Gemini 2.5 `thinking_budget`.
The official docs are explicit that using both parameters in the same request is
an error.

Gemini 3.1 Pro supports:

- `low`: fewer thinking tokens; useful for simple, latency-sensitive tasks.
- `medium`: balanced thinking; useful when some reasoning is needed but `high`
  latency is not justified.
- `high`: maximum reasoning allowance and the default for Gemini 3.1 Pro.

Do not assume the level is a strict token guarantee. Treat it as a relative cap
or allowance. For this repo's skill-production and coding tasks, default to
high thinking unless there is a clear latency or quota reason to use medium.

For OpenAI-compatible API use, the docs say standard reasoning parameters map to
Gemini thinking levels. Be careful when reading examples across APIs: the same
semantic choice may be spelled `thinking_level`, `thinkingLevel`, or
`reasoning_effort` depending on the client.

## Prompting Guidance

Gemini 3 is a reasoning model. The official docs recommend a different prompting
style than older Gemini models:

- Prefer direct, concise instructions.
- Avoid elaborate chain-of-thought scaffolding or verbose prompt tricks that
  were used to force older models to reason.
- Use `thinking_level: high` for difficult reasoning instead of asking the model
  to expose or simulate a long hidden reasoning process.
- State the desired output and acceptance criteria explicitly.
- Include file paths, constraints, and verification commands up front for coding
  tasks.
- If you need a more conversational or explanatory response, explicitly ask for
  that tone. Gemini 3 defaults to more direct, efficient answers.
- For long context, place the actual question or task after the large context
  and anchor it with language such as "Based on the information above...".
- For recent facts beyond January 2025, use grounding/search instead of relying
  on the base model.

For skill artifacts, keep runtime instructions concise and procedural. Gemini's
skill system exposes only name/description before activation, so runtime skill
descriptions must be precise trigger contracts. After activation, the body
should focus on the actual workflow, guardrails, verification, and output shape.

## Coding And Agentic Workflows

The model-specific docs call out improved SWE and agentic behavior for Gemini
3.1 Pro. In this repo, take that as a reason to use it for skill-artifact
production once capacity is available, but keep the updater contract tight:

- Give the harness a concrete artifact target.
- Tell it exactly which files it may edit.
- Provide canonical source, model guide, harness guide, skill model notes, and
  the existing artifact.
- Preserve the user's git index and working-tree ownership rules.
- Ask for targeted verification when safe and a clear report when verification
  cannot run.

Gemini 3.1 Pro has a custom-tools endpoint optimized for workflows that mix bash
and custom tools. Use or allow that endpoint when the harness naturally routes
there. It is especially relevant if the plain model ignores custom tools in
favor of shell commands. Because the custom-tools endpoint can produce quality
differences outside tool-heavy workflows, do not collapse it into the same
provenance as the plain endpoint.

When designing custom tool loops outside Gemini CLI, preserve thought signatures
and tool-call ordering. The official SDKs handle normal chat history and
signatures automatically, but hand-rolled harnesses must preserve signatures
across function calls, parallel calls, and multi-step tool turns.

## Tools And Structured Output

Gemini 3 supports combining built-in tools and custom function calling. Useful
API-side capabilities include:

- Google Search grounding.
- URL context.
- Code execution.
- File search.
- Function calling.
- Structured outputs with tools.
- Multimodal function responses.
- Streaming function calling.

For this dotfiles repo, those capabilities mostly matter indirectly because
Gemini CLI mediates tools for artifact production. Do not import API-level tool
or extension concepts into canonical skill source unless the target surface is
explicitly a Gemini API app, Gemini CLI extension, or Gemini-specific tool
integration.

## Long Context And Multimodal Inputs

Gemini 3.1 Pro's 1M-token input window makes it viable for codebase-sized
context, but not every workflow should dump the whole repo. Prefer targeted
source, relevant docs, and concise task framing. Large context still has cost,
latency, and attention risks.

When large context is necessary:

- Put background/context first and the actual task last.
- Repeat the target files, constraints, and expected output near the final task.
- Ask the model to ground conclusions in the provided context.
- Avoid mixing unrelated reference bundles unless they are explicitly needed.

For multimodal or document-heavy work:

- Gemini 3 introduces `media_resolution` to trade off fidelity against token
  use and latency.
- Higher image/PDF resolution helps with fine details and dense text.
- Lower resolution is often enough for broad image/video understanding.
- Migrating to Gemini 3 defaults can increase token use for PDFs and decrease
  token use for video.
- PDF usage metadata may be reported under image modality rather than document
  modality in Vertex AI.
- Dense PDFs that previously worked under older defaults may need explicit high
  media resolution.

This repo's current skill pipeline is text-centric, so do not add multimodal
complexity unless a future skill actually consumes images, PDFs, video, or
screen recordings.

## Generation Defaults

The Gemini 3 docs recommend keeping temperature at the default `1.0`. Lower
temperature settings that were useful for older deterministic-output workflows
can cause loops or performance degradation on complex tasks.

For this repo:

- Do not set low temperature in Gemini skill-artifact production unless there is
  a specific measured reason.
- Prefer explicit output formats and acceptance criteria over low-temperature
  determinism.
- Keep topP/topK aligned with Gemini CLI's Gemini 3 defaults unless testing
  shows a concrete issue.

## Migration Notes From Gemini 2.5

When moving expectations from Gemini 2.5-family models to Gemini 3.1 Pro:

- Replace complex chain-of-thought prompt scaffolding with direct prompts plus
  high thinking.
- Use `thinking_level`; do not mix it with `thinking_budget`.
- Expect different PDF/document tokenization and OCR behavior.
- Expect media token consumption to change because Gemini 3 uses new media
  resolution behavior.
- Use `media_resolution_high` for dense document parsing that depends on fine
  detail.
- Do not rely on native image segmentation from Gemini 3 Pro.
- Gemini 3 supports broader tool combinations, including built-in tools and
  custom function calling in the same flow.

## Artifact Production Policy

Native Gemini artifact production should use the local Gemini CLI configuration.
Do not add `--model gemini-3.1-pro-preview` to the generic runner just because
the artifact target is versioned. The artifact target controls:

- artifact directory name
- model guide
- skill-specific model notes
- input digest stamp path
- deployment alias normalization

The live harness config controls the authoring model. If Gemini routes from
`pro` to `gemini-3.1-pro-preview`, that is acceptable. If it falls back to a
different model because of quota, capacity, or missing preview access, record
the fallback and leave the artifact stale unless Anthony explicitly accepts the
fallback-authored artifact.

The first Gemini `commit-prep` artifact run in this branch wrote `SKILL.md` but
hit repeated `MODEL_CAPACITY_EXHAUSTED` responses before the native run could
record a digest stamp. A later prompt-infra pass recorded the stamp after
confirming no runtime skill content edit was required. Treat future capacity or
fallback-authored changes as provenance-sensitive and record what actually
authored the artifact.

## Capacity, Quota, And Preview Risk

Gemini CLI can prompt to keep trying an overloaded Gemini 3 Pro model or fall
back to Gemini 2.5 Pro. In headless artifact production, capacity failures can
leave partial output. The updater should detect missing stamps and report the
artifact as stale.

Guidance:

- Prefer retrying the explicit Gemini target when the goal is artifact
  provenance.
- Do not silently accept fallback-authored artifacts.
- Use `stream-json` when debugging model selection because final stats can show
  the concrete model that served the request.
- Record whether the plain endpoint or custom-tools endpoint produced the
  artifact if that distinction matters.

## Skill-Specific Tuning

Keep generic Gemini behavior here. Put skill-specific instructions under:

```text
agents/skills/src/<skill>/model-notes/gemini-3.1-pro-preview.md
```

For `commit-prep`, the important skill-specific invariants are:

- inspect the full dirty working tree, not just staged files
- preserve the user's git index exactly
- keep `.context` concise and retrieval-oriented
- run relevant verification or report why it cannot run
- draft one commit message covering the full uncommitted state unless the user
  narrows scope

Those are skill contract requirements, not generic Gemini model behavior.
