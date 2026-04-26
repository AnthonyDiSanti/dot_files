# Shell initialization and shared functions

- Source: `home/.profile`, `home/.shrc`, `home/.bash_profile`, `home/.bashrc`, `home/.zprofile`, `home/.zshrc`, and `home/.config/{shell,bash,zsh}/`
- Why it matters: controls PATH, prompt, aliases, and the shared shell baseline.
- When to consult: changing shell startup order, adding shared shell helpers, or deciding whether behavior belongs in POSIX baseline vs shell-specific layers.

## Key Points

- Startup layering: `.profile` and `.shrc` bootstrap into `shell/profile.sh` and `shell/rc.sh`; Bash and zsh each have profile/rc wrappers that layer shell-specific config on top.
- Path state: `shell/paths.sh` exports default `XDG_*` vars and derives the shell's unexported internal `dotfiles_*` path layer.
- Homebrew: the shared login profile runs guarded `brew shellenv` for `/opt/homebrew/bin/brew` or `/usr/local/bin/brew`, then prepends `~/.local/bin` and `~/bin` so user-local tools win.
- Shell roles: use POSIX `sh` for deployment-critical bootstrap/shared runtime baselines, `bash` for repo-local dev automation like `test/verify.sh`, and `zsh` for interactive prompt/completion UX.
- Completion policy: Git prompt helper discovery is shared POSIX policy; Git Bash completion candidate ordering lives under `home/.config/bash/git-completion.sh` for fallback use when no existing Git completion is registered.
- Bash completion ownership: `home/.config/bash/completion.bash` owns Bash completion registration, including Git fallback completion; `home/.config/bash/rc.bash` keeps Git prompt helper loading only.
- Non-Git completions: Bash loads system/package-manager `bash-completion` frameworks plus generated completions for selected installed commands such as `codex`, `docker`, `gh`, `git-spice`, and `kubectl`; zsh prepends Homebrew site-functions before `compinit` and only falls back to generated completions when no native command completion exists.
- Bash completion framework order: treat an already-loaded `bash-completion` as authoritative, then try direct Homebrew formula prefixes, optional `pkg-config` metadata, and finally conventional distro paths such as `/etc/profile.d/bash_completion.sh` and `/usr/share/bash-completion/bash_completion`.
- Prompt/interactive boundary: keep shared policy/helpers in `shell/`, but keep shell-native prompt, completion, and hook internals in `bash/` and `zsh/` rather than building a shared abstraction over them.
- User tools: `make-chrome-app` lives in `~/.local/bin/`.

## Gotchas

- The shell entrypoints intentionally remain in `$HOME` for compatibility, even though the managed internals now prefer XDG-derived paths.
- Bash and zsh history live under `XDG_STATE_HOME` / `~/.local/state` unless explicitly overridden.
- zsh predefines `HISTSIZE`, so use assignment rather than `${HISTSIZE:-...}` when pinning repo defaults; host-specific overrides can still happen later in `.zshrc_local`.
- Prefer the internal `dotfiles_*` vars for shell path plumbing after `paths.sh` has loaded, and reserve raw `XDG_*` fallback logic for the tiny wrapper/bootstrap edge.
- `paths.sh` is required infrastructure rather than a best-effort helper: the shared and shell-specific rc/profile layers fail fast if it cannot be loaded or does not initialize the expected path vars.
- The repo no longer supports repo-managed shell-local override hooks like `profile.local.sh`, `local.sh`, `local.bash`, or `local.zsh`, but target-aligned home-level `_local` files remain supported as the host-specific override layer: `.profile_local`, `.shrc_local`, `.bash_profile_local`, `.bashrc_local`, `.zprofile_local`, and `.zshrc_local`.
- Shell files under `home/.config/bash/` and `home/.config/zsh/` are intended for their target shell only.
- Git prompt-helper loading intentionally follows the active `git` binary instead of a vendored `lib/git` checkout, so prompt behavior can change when PATH selects a different Git install.
- Completions are system-first: prefer Homebrew/package-manager/native completions and command-provided generators over vendored completion files. For zsh, add native site-functions to `fpath` before `compinit`; for Bash, source the bash-completion framework when present and do not broadly source snippets without it.
- Alias completion overrides should be capability- and alias-guarded. `gs` is intentionally rebound from zsh's stock Ghostscript completion to git-spice completion only when the shared alias layer defines `gs=git-spice`.
- Capability guards are appropriate at external integration boundaries: use runtime-observed state such as `complete -p git`, zsh `_git` visibility in `fpath`, or `_comps[kubectl]` before installing fallbacks. Avoid coarse file-level loaded guards such as `DOTFILES_BASH_LOADED`, which can go stale and prevent convergence.
- Prefer explicit call-site data flow in shell helpers: avoid passing function names as strings when a helper can read stdin and be fed by redirection/process substitution in the shell-specific layer.
- Rerunnable startup tests should replay the same top-level files an interactive login shell is expected to load; if a new startup file such as `.zshenv` is added, include it in that replay.
- Startup fixtures are assertion files, not setup files; `test/verify.sh` enables `errexit` / `ERR_EXIT` before sourcing them so bare tests such as `complete -p git` or `[[ ... ]]` fail the suite when the expected startup state is missing.
- Most of the shell stack is now meant to be rerunnable in the same shell: `paths.sh`, `rc.sh`, `bash/rc.bash`, `zsh/rc.zsh`, and `zsh/prompt.zsh` no longer use coarse file-level guards, and the zsh layer dedupes `fpath` / `precmd` registration instead.
- The old `DOTFILES_*_LOADED` markers were removed entirely once they stopped serving a real runtime purpose.
- The remaining narrow guard is Homebrew `shellenv` inside `home/.config/shell/profile.sh`, because rerunning that block would otherwise duplicate PATH-like entries; that guard still uses a process-local token (`${BASHPID:-$$}` / `$$`) so inherited stale env from a parent GUI/session does not block startup.
- `home/.vim` is a real symlink node, pointing to `../managed/vim` for the whole-directory Vim case.
- Do not assume zsh is automatically the best scripting language here; for mostly-orchestration scripts, bash remains the default unless there is a specific zsh-only payoff.
- ShellCheck and shfmt are required dev verification dependencies. `test/verify.sh` runs `scripts/shellcheck-dotfiles.bash --all` and `scripts/shfmt-dotfiles.bash --all --check`; VS Code ShellCheck points at the same ShellCheck wrapper. `scripts/shell_files.bash` owns Bash-only dev-tool shell file discovery/dialect classification for verify, ShellCheck, and shfmt; keep POSIX deployment discovery in `scripts/home_tree_manifest.sh`. `scripts/shfmt-dotfiles.bash` uses `shfmt -i 2 -ci -bn` and supports check/diff/write modes. Keep tool-specific zsh skips and narrow false-positive suppressions centralized in the wrappers rather than adding inline linter directives to managed shell files.
