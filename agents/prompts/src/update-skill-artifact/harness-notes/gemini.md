# Gemini Update-Skill Prompt Notes

Gemini receives the rendered skill-artifact update prompt on stdin in headless
mode.

- The repository root is provided in the rendered prompt; resolve repo-relative
  paths against it.
- If shell-command approval would be required, skip shell verification and
  report that verification was skipped.
- If Gemini hits model capacity, preview access, auth, fallback, or headless
  tool limitations, leave the artifact stale and report the updater command or
  diagnosis for a normal shell run.
