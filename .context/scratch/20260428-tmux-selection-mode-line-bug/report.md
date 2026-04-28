# Upstream tmux bug: `selection-mode line` clobbers anchor row and applies lazily

Draft of a GitHub issue to file at <https://github.com/tmux/tmux/issues>.
Discovered 2026-04-28 while building Vim-style v/V/C-v selection toggles in `home/.tmux.conf`. As of this date the bug reproduces on tmux 3.6a (latest stable, released 2025-12-05) and on `tmux/tmux` master at HEAD; no related fixes are present in master post-3.6a, and no matching open issue exists on the tracker.

## Repo workaround status

`home/.tmux.conf`'s V (line-selection) toggle currently routes around this bug as follows:

- **Fresh entry** (no active selection): the binding uses `send-keys -X rectangle-off ; send-keys -X select-line` instead of the symmetric `begin-selection ; rectangle-off ; selection-mode line` used by v and C-v. `select-line` directly sets the line flag, anchors at column 0 of the current row, and moves the cursor to end-of-line — bypassing the buggy `selection-mode line` code path entirely.
- **Mid-selection switch** (active selection in char or rectangle mode, user presses V): the binding still uses `send-keys -X rectangle-off ; send-keys -X selection-mode line`. There is no good substitute here — `select-line` would collapse any existing multi-line range to a single line, and no other command preserves the existing anchor while flipping to line mode. This path is accepted as broken until the upstream bug is fixed; the user-visible symptom is the anchor jumping to the top of the visible viewport on the next cursor movement after V.

### Migration plan once tmux is fixed

When `selection-mode line` is fixed upstream and the fixed version is in use:

1. The mid-selection switch path will start working immediately with no code change required — the existing `rectangle-off ; selection-mode line` invocation is the textbook-correct call and is currently waiting on tmux to honor it.
2. The fresh-entry path can optionally be migrated from `select-line` to `begin-selection ; rectangle-off ; selection-mode line` for symmetry with the v and C-v bindings. This is a stylistic / consistency change rather than a correctness change; both forms produce a working line-mode selection. The behavioral difference is on the cursor's position in the V-press row — `select-line` moves the cursor to end-of-line, while `selection-mode line` should preserve the cursor's column (matching vim's V).

When making either change, retest the full v / V / C-v / Space / Escape matrix described under "Reproducer with full v/V/C-v bindings" below to confirm anchor preservation, lazy-application timing, and toggle-off behavior.

---

## Title

`selection-mode line` does not preserve the existing anchor and only applies on the next cursor-movement event in copy-mode-vi

## Version

- tmux 3.6a (the latest stable as of 2026-04-28)
- Also reproduces on `tmux/tmux` master at HEAD as of 2026-04-28

## Summary

When `send-keys -X selection-mode line` is invoked in copy-mode-vi, two related issues occur:

1. The mode change does not visually take effect at the moment the command runs. The selection's display continues to render as it did under the previous mode until a cursor-movement event happens.
2. When the change finally takes effect (on the next cursor movement), the selection's anchor row is replaced rather than preserved. In every reproduction I have, the anchor row gets clobbered to the top of the visible viewport.

The combination makes `selection-mode line` unusable for switching an active selection into line mode, because the resulting selection runs from the top of the viewport down to the cursor instead of from the original anchor row down to the cursor.

`selection-mode char` exhibits only issue #1 (lazy application). The anchor is preserved correctly when applying char mode, so that direction is merely visually surprising rather than functionally broken.

## Steps to reproduce

1. Start tmux 3.6a with vi copy-mode keys (`set -g mode-keys vi`).
2. Add a binding that switches an existing selection into line mode. Minimal example:

   ```tmux
   set -g mode-keys vi
   bind -T copy-mode-vi V send-keys -X selection-mode line
   ```

3. Press `prefix [` to enter copy mode somewhere with several lines of scrollback above the cursor.
4. Press `Space` (the default vi binding for `begin-selection`) to start a character selection.
5. Press `j j j` to extend the selection across a few lines.
6. Press `V` (the binding above) to switch to line mode.
7. Press `j` once more.
8. Press `y` (or whatever yanks) and inspect the buffer.

## Expected behavior

- After step 6, the selection's mode flips to line. The anchor's row remains where `Space` was pressed in step 4, the cursor's row remains where `j j j` left it in step 5, and the selection visually re-renders as full lines from the anchor's row to the cursor's row.
- After step 7, the selection extends by one more full line in the direction of motion.
- The yanked content in step 8 begins at the anchor's row and ends at the final cursor's row.

## Actual behavior

- After step 6, no visual change occurs. The character-mode highlight from step 5 remains on screen.
- After step 7, the selection visibly snaps. It now runs from row 0 of the visible viewport down to the new cursor row, rendered as full lines (line mode applied). The original anchor row has been replaced.
- The yanked content in step 8 begins at the top of the visible viewport, not at the anchor.

## Additional observations

### Lazy application is symmetric, but the anchor bug is line-specific

Switching from line back to char via `selection-mode char` exhibits the same lazy-application behavior (no visual change at the moment of the command, snap to char-mode highlight on the next cursor movement), but the anchor is preserved correctly. After one cursor movement the resulting selection is exactly what one would expect.

This points to `selection-mode <type>` setting an internal flag without triggering re-evaluation of the selection's extent, plus a separate bug in the line-direction re-evaluation that overwrites the anchor's row.

### `begin-selection ; selection-mode line` is also affected

A fresh entry into line mode via `begin-selection` followed by `selection-mode line` exhibits the same anchor jump. `begin-selection` correctly anchors the selection at the cursor's position, but the subsequent `selection-mode line` overwrites the anchor row with the top of the viewport on the next cursor movement.

### Going from rectangle directly to line never engages line mode

With a binding that issues `rectangle-off ; selection-mode line` on an active rectangle selection, the next cursor movement after the switch extends the selection in **char** mode, not line mode — as if `selection-mode line` had no effect at all. A second cursor movement is required for line mode to engage, and at that point the anchor jumps as described above.

### Reproducer with full v/V/C-v bindings

A complete vim-style v/V/C-v toggle setup that exercises every affected path:

```tmux
set -g mode-keys vi

bind -T copy-mode-vi v if -F '#{selection_active}' {
  send-keys -X rectangle-off
  send-keys -X selection-mode char
} {
  send-keys -X begin-selection
  send-keys -X rectangle-off
  send-keys -X selection-mode char
}

bind -T copy-mode-vi V if -F '#{selection_active}' {
  send-keys -X rectangle-off
  send-keys -X selection-mode line
} {
  send-keys -X begin-selection
  send-keys -X rectangle-off
  send-keys -X selection-mode line
}

bind -T copy-mode-vi C-v if -F '#{selection_active}' {
  send-keys -X rectangle-on
  send-keys -X selection-mode char
} {
  send-keys -X begin-selection
  send-keys -X rectangle-on
  send-keys -X selection-mode char
}
```

With these bindings:

- Fresh `V` from no selection: anchor jumps to top of viewport on the next cursor movement.
- `v` then `j j j` then `V`: anchor jumps; subsequent navigation extends from viewport top.
- `v` then `C-v` then `V`: line mode never engages on the first navigation; second navigation engages line mode and exhibits the anchor jump.
- `V` then `v`: visually lazy but functionally correct after one cursor movement (anchor preserved).

## Workaround

Replace `selection-mode line` with `select-line` for any path where the desired result is "line-mode selection of the current row." `select-line` directly sets `lineflag = LINE_SEL_LEFT_RIGHT`, clears the rectangle flag, anchors the selection at column 0 of the current row, and moves the cursor to end-of-line — entirely bypassing the `selection-mode` code path:

```tmux
bind -T copy-mode-vi V if -F '#{selection_active}' {
  send-keys -X rectangle-off
  send-keys -X selection-mode line   # still buggy here; no good substitute when preserving an existing multi-line range is required
} {
  send-keys -X rectangle-off
  send-keys -X select-line             # works correctly for fresh entry
}
```

This is sufficient for fresh entry but does not help when switching an existing multi-line range into line mode, because `select-line` resets the anchor to the current row and collapses the selection to one line.

## Suspected cause

`selection-mode <type>` appears to set the selection's type flag without calling the function that re-evaluates the selection's extent. The re-evaluation happens on the next cursor movement when copy mode normally recomputes the selection's visible extent. In that re-evaluation path, the line-mode branch sources the anchor's row from a value that defaults to row 0 of the viewport rather than reading the existing selection's anchor.

A reviewer with the source open should look at:

- `window_copy_cmd_select_mode` (or whichever function `selection-mode` dispatches to in `window-copy.c`) — does it call any function that updates the live selection extent, or does it only set a flag?
- The cursor-movement re-evaluation path for the line-mode branch — what does it use as the selection's anchor row when `lineflag` is `LINE_SEL_LEFT_RIGHT` and the selection is already active?

I have not yet read the source thoroughly enough to identify the exact lines.
