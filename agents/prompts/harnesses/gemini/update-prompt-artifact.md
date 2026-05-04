# Update Prompt Artifact

You are maintaining one harness-specific prompt artifact because an updater
script invoked you for that harness target. Create or update only the target
prompt file using the canonical source and guidance below.

Gemini receives the rendered prompt-artifact maintenance prompt on stdin in
headless mode.

## Inputs

- Prompt name: `{{PROMPT_NAME}}`
- Canonical source: `{{SOURCE_PROMPT}}`
- Prompt artifact: `{{PROMPT_ARTIFACT}}`
- Harness guide: `{{HARNESS_GUIDE}}`
- Harness-specific prompt notes: `{{HARNESS_NOTES}}`

## Required Reads

Read the canonical prompt source and harness guide before editing. Read
harness-specific prompt notes only when the input points to an existing file;
those notes are optional harness-specific deltas, not required boilerplate. Read
the existing prompt artifact when it exists.

## Output Files

Create or update only the requested prompt artifact. Do not update runtime skill
artifacts, canonical prompt source, harness guides, harness notes, updater
scripts, or digest stamps from this prompt-maintenance pass. If those inputs
appear wrong or insufficient, report the issue instead of fixing it here.

## Rules

- Treat the existing prompt artifact as maintained output.
- Treat prompt harness notes as optional deltas. Shared prompt-artifact rules
  belong in this canonical prompt, not repeated across every note file.
- Preserve useful hand-written structure and harness-specific adaptations when
  the artifact exists.
- Apply targeted updates instead of wiping and regenerating existing files.
- If the prompt artifact is missing, create it from the canonical source and
  harness-specific notes as part of this updater run.
- Create missing prompt artifacts only when this prompt was rendered and
  delivered by the updater. Outside that flow, leave prompt artifacts missing or
  stale and report the updater command instead of manually bootstrapping them.
- Keep canonical placeholders such as `{{SKILL_NAME}}` or `{{ARTIFACT_DIR}}`
  intact unless the source prompt deliberately changes them.
- Move harness-specific runner behavior into the harness prompt artifact or
  harness notes, not into harness YAML `runner_args`.
- Do not assume plugin packaging, MCP, editor state, or other harness extension
  surfaces unless the source prompt explicitly adds that target.
- Use the local harness configuration as the authoring model. Do not add
  target-model CLI override instructions to prompt artifacts.
- The repository root is provided in the rendered prompt; resolve repo-relative
  paths against it.
- If the native harness cannot complete because of auth, sandboxing, account
  limits, model capacity, unavailable preview access, fallback, or headless
  tool limitations, leave the prompt artifact missing/stale and report the
  blocker plus the exact updater command for a normal shell run. Do not
  substitute another harness unless the updater or user explicitly selected a
  fallback.
- Do not create or update stamp files. The updater script owns stamp recording
  after it verifies the expected output.
- Do not stage, unstage, commit, amend, reset, restore, or rewrite git state.

## Verification

After editing, run the smallest relevant checks available for the changed files.
If no edits are needed, say so and explain why. If shell-command approval would
be required, skip shell verification and report that verification was skipped.
