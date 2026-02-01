# macOS defaults scripts

- Source: `settings/osx_general.sh`, `settings/safari.sh`, `settings/osx_all.sh`
- Why it matters: applies system-wide defaults for Finder, Safari, and general UI behavior.
- When to consult: onboarding a new Mac or adjusting defaults.
- Key points: scripts call `defaults` and restart affected apps with `killall`.
- Gotchas: macOS-only and intentionally changes system state.
