# Chrome app wrapper

- Source: `home/dot_local/bin/make-chrome-app`, `lib/make-chrome-app/makeapp.sh`
- Why it matters: creates standalone macOS app wrappers for web apps.
- When to consult: creating a new Chrome app wrapper or changing where CLI utilities are installed.
- Key points: installs to `~/.local/bin/make-chrome-app`; expects Chrome at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`; uses `sips` and `tiff2icns` for icon conversion; writes the resulting app bundle to `/Applications`.
- Gotchas: macOS-only; requires a valid icon path and write access to `/Applications`; the live CLI is now managed under `home/dot_local/bin/` and deployed as a symlink in `~/.local/bin/`, while `lib/make-chrome-app/` remains the older vendor/reference implementation.
