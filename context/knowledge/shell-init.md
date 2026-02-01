# Shell initialization and shared functions

- Source: `home/.bash_profile`, `bash/`
- Why it matters: controls PATH, prompt, and shared shell helpers.
- When to consult: adding new shell functions or CLI utilities.
- Key points: `.bash_profile` sources every file under `bash/`, adds `bin/` to `PATH`, and loads git prompt/completion from `lib/git/contrib`.
- Gotchas: `lib/git` is vendored; keep it intact for prompt/completion to work.
