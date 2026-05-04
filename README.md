# Dotfiles

Personal dotfiles and setup scripts for shell, Vim, tmux, Git, and macOS
workstation settings.

## Bootstrap

This repo uses a repo-native bootstrap to symlink dotfiles into `$HOME`.

### Initial Setup

1. Install `git` for your OS.
2. Clone this repo.
3. Run `./bootstrap.sh`.

`bootstrap.sh` interprets the checked-out `home/` tree as a literal `$HOME`
mirror and symlinks each managed leaf back into the repo. Real symlink nodes in
`home/` are preserved as managed leaves, including symlinked directories. It
keeps a small state file under `XDG_STATE_HOME` / `~/.local/state/dotfiles/` so
later bootstrap runs can clean up removed or reshaped managed targets.

### Previewing Changes

1. Run `./bootstrap.sh --dry-run --verbose`.
2. Run `./bootstrap.sh --list-managed`.

### Verifying

1. Run `test/verify.sh`.

## Vim

Plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug).
The tracked `home/.vim/autoload/plug.vim` file is the vim-plug loader snapshot.
Bootstrap creates a real `~/.vim` directory and symlinks only repo-managed files
inside it; plugin clones install under the local `~/.vim/plugged/` directory.

The UI colorscheme is
[Solarized 8](https://github.com/lifepillar/vim-solarized8)
(`colorscheme solarized8`), which supports true color via `termguicolors` and
falls back to 256-color mode when that is off. `home/.vimrc` sets the `t_8f` /
`t_8b` sequences from `:help xterm-true-color`. tmux enables RGB passthrough
with `terminal-features` in `home/.tmux.conf`; reload tmux after pulling. If
true color is wrong over SSH, run `set notermguicolors` and
`:colorscheme solarized8` for the 256-color fallback.

### Initial Plugin Setup

1. Run `./bootstrap.sh` so `~/.vim/autoload/plug.vim` points at this checkout.
2. Open Vim and run `:PlugInstall`.

### Updating Plugins

1. Open Vim.
2. Run `:PlugUpdate`.

### Removing Old Plugin Directories

If you remove a `Plug` line from `home/.vimrc`, run `:PlugClean` in Vim to
delete the matching tree under `~/.vim/plugged/`. For example, run it after
replacing `vim-colors-solarized` with `vim-solarized8`.

### Upgrading the vim-plug Script Itself

From Vim, `:PlugUpgrade` updates `plug.vim`. Because `~/.vim/autoload/plug.vim`
points at the tracked `home/.vim/autoload/plug.vim` snapshot, the upgrade
changes this repo file directly. Review and commit the snapshot when you want
the new version recorded.

### Adding New Plugins

1. Add a `Plug 'owner/repo'` line in `home/.vimrc` inside the `plug#begin` /
   `plug#end` block.
2. Run `:PlugInstall`.

## Terminal Colors

Ghostty and iTerm2 Solarized Dark settings are managed under `home/` and linked
by `./bootstrap.sh`. iTerm2 gets a dynamic profile named
`Solarized Dark (dotfiles)` under
`~/Library/Application Support/iTerm2/DynamicProfiles/`. Run
`settings/iterm2.sh` to make that profile the default for new iTerm2 windows
and let `tmux -CC` sessions inherit the connecting session profile.

## Agent Skills

Shared agent skill sources live as directories containing `SKILL.md` anywhere under
`agents/skills/src/`, and runtime artifacts live under
`agents/skills/artifacts/`. The skill directory name is the runtime skill id and
must be unique across the source tree. Per-harness deployment paths live in
`home/` as symlink nodes, such as
`home/.agents/skills/commit-prep -> ../../../agents/skills/artifacts/codex/gpt-5.5/skills/commit-prep`.
Claude Code uses the same directory-symlink pattern under `home/.claude/skills/`
and is pinned to Opus 4.6 through `home/.claude/settings.json`; Cursor Agent
uses `home/.cursor/skills/` symlink nodes while leaving Cursor's stateful CLI
config local. Gemini CLI user settings are managed at
`home/.gemini/settings.json`; credentials, account files, trust state, history,
and tmp logs stay local.

## Agent Infrastructure

Agent skills, official vendor docs, and model-specific guidance live under
`agents/`. `agents/official-docs/` is an authoritative vendor-reference area;
most docs are copied from vendor sources, while larger source/example trees are
optional pinned submodules. Current submodules cover Codex source, Anthropic
skill examples/specs, Cursor plugin examples/schemas, and Gemini CLI docs.
Hydrate them only when working on those reference surfaces:

```sh
git submodule update --init --depth 1 \
  agents/official-docs/codex \
  agents/official-docs/anthropic-skills \
  agents/official-docs/cursor-plugins \
  agents/official-docs/gemini-cli
```

`agents/models/` contains repo-authored interpretations and examples used to
tune managed skills and agent instructions. Skill-specific
model notes live beside the skill under
`agents/skills/src/**/<skill>/model-notes/`.
Harness configs, adapter docs, and update prompts live under
`agents/harnesses/`; harness ids match executable names and each
`<harness>.yaml` records that harness's artifact outputs, runner args, home
config path, skill install path, explicit model config key, and optional
harness-native model aliases.
`agents/scripts/update-skill.bash` maintains one source skill across selected
harness/model artifacts, and `agents/scripts/update-all.bash` refreshes all
currently maintained artifacts for selected harness/model targets. Both runners
use committed input-digest stamps under
`agents/skills/.update-stamps/<harness>/<model>/skills/<skill>/` rather than file
mtimes and repeat until the selected artifact matrix reaches a fixed point.
Pass `--force` when a selected skill or matrix should be re-run by the native
harness on the first pass even when its digest stamp is current.
Target filters are axis-based: `--harness` alone or `--model` alone selects
existing artifacts on that axis, while explicitly passing both `--harness` and
`--model` creates that harness/model target if it does not already exist.
`agents/scripts/symlink-skill.bash` and `agents/scripts/symlink-all.bash` deploy
runtime artifacts into the selected home tree, discovering configured
harness/model targets from harness home config files unless both `--harness` and
`--model` are passed explicitly. Harness-native aliases such as Claude Code's
`best` are normalized to canonical artifact model ids before linking.
`symlink-all.bash [skill-prefix]` limits deployment to all source skills below a
subtree such as `agents/skills/src/frontend/`, which is useful when skill source
is organized by team or domain.
