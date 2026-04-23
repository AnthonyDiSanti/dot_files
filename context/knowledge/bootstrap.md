# Bootstrap & symlinks (chezmoi)

- Source: `bootstrap.sh`, `.chezmoiroot`
- Why it matters: defines which dotfiles are linked into `$HOME` and keeps the repo as the single source of truth.
- When to consult: adding/removing dotfiles or debugging missing config on a machine.
- Key points: `.chezmoiroot` makes `home/` the chezmoi source root; `bootstrap.sh` is POSIX `sh`, hydrates git submodules with `git submodule update --init --recursive` when run from a real git checkout, ignores host-local chezmoi config via `--config /dev/null --config-format toml`, keeps its own persistent state under `XDG_STATE_HOME` / `~/.local/state`, and then runs `chezmoi --source "$repo" --mode symlink apply`.
- Verification: run `scripts/verify.sh` after bootstrap or source-state changes.
- Gotchas: repo principle is that `git pull` should live-update deployed config without re-running bootstrap except when the deployment shape changes, so prefer symlink-backed targets and symlink templates over copied runtime files. `home/.vim` stays hidden and is linked by `home/symlink_dot_vim.tmpl` to preserve the existing whole-directory Vim behavior during the future Vim migration.
