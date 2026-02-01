# Chrome app wrapper

- Source: `bin/make-chrome-app`, `lib/make-chrome-app/makeapp.sh`
- Why it matters: creates standalone macOS app wrappers for web apps.
- When to consult: creating a new Chrome app wrapper.
- Key points: expects Chrome at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`; uses `sips` and `tiff2icns` for icon conversion; writes to `/Applications`.
- Gotchas: macOS-only; requires a valid icon path and write access to `/Applications`.
