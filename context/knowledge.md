# Knowledge Base

Curated notes that reduce repeated setup or debugging for this dotfiles repo.

## Bootstrap & symlinks (Puppet)
- Source: `bootstrap.sh`, `site.pp`
- Why it matters: defines which dotfiles are linked into `$HOME` and keeps the repo as the single source of truth.
- When to consult: adding/removing dotfiles or debugging missing config on a machine.
- Key points: `bootstrap.sh` sets `FACTER_home_dir` and `FACTER_dotfiles_dir`, then runs `puppet apply site.pp` to link dotfiles.
- Gotchas: Puppet must be installed; ensure target parent directories (for example `~/.codex`) exist on the machine.

## Shell initialization and shared functions
- Source: `home/.bash_profile`, `bash/`
- Why it matters: controls PATH, prompt, and shared shell helpers.
- When to consult: adding new shell functions or CLI utilities.
- Key points: `.bash_profile` sources every file under `bash/`, adds `bin/` to `PATH`, and loads git prompt/completion from `lib/git/contrib`.
- Gotchas: `lib/git` is vendored; keep it intact for prompt/completion to work.

## Vim plugins (Vundle + vendored bundles)
- Source: `home/.vimrc`, `home/.vim/bundle/`
- Why it matters: plugin list and plugin source live in-repo.
- When to consult: adding/removing plugins or updating themes.
- Key points: Vundle bundle list is defined in `.vimrc`; plugin directories are stored under `home/.vim/bundle`.
- Gotchas: keep the bundle directory in sync with `.vimrc` when plugin changes are made.

## macOS defaults scripts
- Source: `settings/osx_general.sh`, `settings/safari.sh`, `settings/osx_all.sh`
- Why it matters: applies system-wide defaults for Finder, Safari, and general UI behavior.
- When to consult: onboarding a new Mac or adjusting defaults.
- Key points: scripts call `defaults` and restart affected apps with `killall`.
- Gotchas: macOS-only and intentionally changes system state.

## Chrome app wrapper
- Source: `bin/make-chrome-app`, `lib/make-chrome-app/makeapp.sh`
- Why it matters: creates standalone macOS app wrappers for web apps.
- When to consult: creating a new Chrome app wrapper.
- Key points: expects Chrome at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`; uses `sips` and `tiff2icns` for icon conversion; writes to `/Applications`.
- Gotchas: macOS-only; requires a valid icon path and write access to `/Applications`.

## macOS keybindings
- Source: `settings/OSXKeyBindings.dict`
- Why it matters: custom Home/End/PageUp/PageDown behavior in Cocoa text fields.
- When to consult: adjusting keybindings or troubleshooting text navigation.
- Key points: copy to `~/Library/KeyBindings/DefaultKeyBinding.dict` to apply.
- Gotchas: changes require app restart to take effect.
