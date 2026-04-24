# Bootstrap & symlinks

- Source: `bootstrap.sh`, `scripts/home_tree_manifest.sh`
- Why it matters: defines which dotfiles are linked into `$HOME` and keeps the repo as the single source of truth.
- When to consult: adding/removing dotfiles or debugging missing config on a machine.
- Key points: `bootstrap.sh` is POSIX `sh`, hydrates git submodules with `git submodule update --init --recursive` when run from a real git checkout, interprets tracked files under `home/` as the literal `$HOME` target tree, derives parent directories from that tree, and symlinks each managed leaf back into the repo checkout. It records the current managed-path set under `XDG_STATE_HOME` / `~/.local/state/dotfiles/managed-paths` so later bootstrap runs can remove stale paths after target-shape changes.
- Verification: run `scripts/verify.sh` after bootstrap or `home/`-tree changes.
- Gotchas: repo principle is that `git pull` should live-update deployed config without re-running bootstrap except when the deployment shape changes, so prefer repo-backed symlink targets over copied runtime files. `home/.vim` is now a real symlink node to `../managed/vim` so the Vim tree can stay whole-directory-linked without special bootstrap metadata. Vendored git helpers under `home/.config/{bash,zsh}/` are also real symlink nodes, not template-generated link targets.
