# chezmoi Source State

- Source: official chezmoi docs for source-state attributes, `.chezmoiroot`, target types, scripts, and migration from symlink managers.
- Why it matters: this repo bootstraps by using chezmoi to create symlinks from `$HOME` into `home/`.
- When to consult: changing `bootstrap.sh`, adding new managed home files, or deciding whether a file should be templated, encrypted/private, executable, or symlinked.
- Key points:
  - Use `dot_` source names for leading-dot targets, e.g. `dot_bash_profile` -> `~/.bash_profile`.
  - Use `private_dot_` for managed private directories, e.g. `private_dot_claude` and `private_dot_codex` keep `~/.claude` and `~/.codex` at `700` while child files still symlink in symlink mode.
  - `.chezmoiroot` can let this repo keep `home/` as the source-state root while leaving `settings/`, `bash/`, `lib/`, and `context/` outside target state.
  - `home/.chezmoi.toml.tmpl` sets `mode = "symlink"` so drift happens in tracked source files instead of copied snapshots.
  - Hidden source files are ignored unless they are `.chezmoi*`; `home/.vim` intentionally remains hidden and is linked by `home/symlink_dot_vim.tmpl`.
  - `run_once_`/`run_onchange_` scripts are the right place for selected idempotent install or setup actions; broad macOS defaults should remain explicitly invoked unless a setting is intentionally platform-gated and one-time.
