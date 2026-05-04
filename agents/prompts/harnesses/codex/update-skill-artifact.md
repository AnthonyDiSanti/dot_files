# Update Skill Artifact

You are maintaining one runtime skill artifact because an updater script invoked
you for that harness/model target. Create or update only the target artifact
files using the canonical source and guidance below.

## Inputs

- Skill name: `{{SKILL_NAME}}`
- Harness-model artifact: `{{ARTIFACT_NAME}}`
- Canonical source: `{{SOURCE_SKILL}}`
- Runtime artifact directory: `{{ARTIFACT_DIR}}`
- Harness guide: `{{HARNESS_GUIDE}}`
- Harness-specific skill notes: `{{HARNESS_NOTES}}`
- Model guide: `{{MODEL_GUIDE}}`
- Model-specific skill notes: `{{MODEL_NOTES}}`
- Evaluation fixtures: `{{EVAL_DIR}}`

## Codex Runner Context

Codex receives this rendered prompt on stdin through `codex exec`, with the
repository root set as the working directory by the harness configuration.
Resolve repo-relative input and output paths against that working directory.

Codex artifact production uses the local user harness configuration as the
authoring model. Do not add model override instructions to runtime artifacts,
and do not change `agents/harnesses/*.yaml` from this maintenance pass.

If Codex cannot complete because of auth, sandboxing, account limits, model
capacity, preview access, or unavailable tools, leave the runtime artifact
missing or stale. Report the blocker and the exact `agents/scripts/update-skill.bash`
command Anthony should run from a normal shell.

## Required Reads

Read the canonical source, harness guide, and model guide before editing. Read
harness-specific skill notes and model-specific skill notes only when the inputs
point to existing files; those notes are optional target-specific deltas, not
required boilerplate. Read existing runtime artifact files when they exist. Read
evaluation fixtures when they exist to understand behavioral expectations, not
to copy test prose into the runtime artifact.

## Output Files

Create or update only runtime artifact files for the target harness. Use the
harness guide as the source of truth for the output shape. Current examples:

- Codex artifacts: `{{ARTIFACT_DIR}}/SKILL.md` and
  `{{ARTIFACT_DIR}}/agents/openai.yaml`
- Claude Code artifacts: `{{ARTIFACT_DIR}}/SKILL.md`
- Cursor Agent artifacts: `{{ARTIFACT_DIR}}/SKILL.md`
- Gemini CLI artifacts: `{{ARTIFACT_DIR}}/SKILL.md`

Do not edit canonical source, model guides, harness guides, notes, evals,
symlink deployments, updater scripts, or digest stamps. If those inputs appear
wrong or insufficient, report the issue instead of fixing it in this pass.

## Rules

- Treat the existing runtime artifact as maintained output.
- Treat harness notes and model notes as optional deltas. Shared artifact
  production rules belong in this prompt or the canonical source, not repeated
  across every note file.
- Preserve useful hand-written structure and local idioms when the artifact
  exists.
- Apply targeted updates instead of wiping and regenerating existing files.
- If the runtime artifact is missing, create the harness-declared output files
  from the canonical source and target guidance as part of this updater run.
- Create missing artifact files only when this prompt was rendered and delivered
  by the updater. Outside that flow, leave artifacts missing or stale and report
  the updater command instead of manually bootstrapping them.
- Keep runtime instructions concise and model-appropriate.
- Keep generic model guidance out of the runtime skill body.
- Keep skill-specific model rationale in model notes, not in `SKILL.md`.
- Treat canonical `SKILL.md` frontmatter as the skill identity source. Do not
  move interface fields, UI labels, default prompts, or model/harness-specific
  customization into the source skill frontmatter.
- Maintain harness-specific metadata only in runtime artifact files for harnesses
  that define such metadata. Codex uses `agents/openai.yaml`; Claude Code,
  Cursor Agent, and Gemini CLI do not use YAML companion files.
- Preserve all safety and side-effect invariants from the canonical source.
- Use the local harness configuration as the authoring model. Do not add
  target-model CLI override instructions just because the artifact directory
  names a model.
- If the native harness cannot complete because of auth, sandboxing, account
  limits, model capacity, or unavailable preview access, leave the artifact
  missing/stale and report the blocker plus the exact updater command for a
  normal shell run. Do not substitute another harness unless the updater or user
  explicitly selected a fallback.
- Do not create or update stamp files. The updater script owns stamp recording
  after it verifies the expected outputs.
- Do not stage, unstage, commit, amend, reset, restore, or rewrite git state.

## Verification

After editing, run the smallest relevant checks available for the changed files.
If no edits are needed, say so and explain why.
