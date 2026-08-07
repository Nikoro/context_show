# Safe area & insets

Flutter behaviour this package's inset calculation depends on, plus the traps
found while fixing it. Every number was measured in a widget test.

### [GOTCHA] [CRITICAL] An `AppBar`'s height already includes the status bar
**Area:** `lib/app_bar_height.dart`
**Tags:** `#gotcha` `#architecture`
**Verified:** 2026-08-07

**Symptom:** A fix for a too-small inset leaves a status-bar-sized gap above
every banner on ordinary pages.

**Root cause:** With a 100px status bar, a real `AppBar` reports **156**, not
`kToolbarHeight` (56). Adding `padding.top` on top of that double-counts.

**Workaround:** Never add `padding.top` to an app bar height. `math.max(appBar,
padding.top)` is also not the fix it looks like: with a real app bar the max is
already the app bar so nothing changes, and where the inset is wrong the
padding is 0 so the max is still 0. It fixes nothing.

### [GOTCHA] [CRITICAL] Inside a `Scaffold` body, `MediaQuery` reports no padding
**Area:** `lib/overlay_safe_area.dart`
**Tags:** `#gotcha` `#architecture`
**Verified:** 2026-08-07

**Symptom:** Building a margin from `MediaQuery.paddingOf(context).top` silently
yields 0, so the overlay lands at the very top of the screen.

**Root cause:** Once an app bar has consumed the padding, both `paddingOf` and
`viewPaddingOf` return zero below it. `viewPaddingOf` is *not* an escape hatch
here — that was the second wrong guess while writing the README.

**Workaround:** Use `overlay.safeArea`, which is measured against the chrome the
overlay actually appears over.

### [GOTCHA] [CRITICAL] `Scaffold.maybeOf` only walks upwards
**Area:** `lib/scaffold_finder.dart`
**Tags:** `#architecture` `#gotcha`
**Verified:** 2026-08-07

**Symptom:** A page showing a banner from its own `build`/`State` context gets
the status bar height instead of the app bar height, so the banner covers the
back button.

**Root cause:** The calling context sits *above* the `Scaffold`, where
`Scaffold.maybeOf` finds nothing and `padding.top` is still unconsumed.

**Workaround:** `ScaffoldFinder` keeps the upward hit as first choice, then
searches downwards **breadth-first** — BFS finds the outer Scaffold, which owns
the chrome; a depth-first walk would descend into an inner app-bar-less
Scaffold and report no chrome at all.

### [GOTCHA] [CRITICAL] `visitChildElements` throws during build
**Area:** `lib/scaffold_finder.dart`
**Tags:** `#gotcha` `#architecture`
**Verified:** 2026-08-07

**Symptom:** Resolving insets from a `build()` method crashes with
"visitChildElements() called during build".

**Root cause:** The child list is still being assembled at that point.

**Workaround:** Bail out when `context.dirty`. Note `debugDoingBuild` alone is
**not** sufficient — it is set only inside `assert` blocks, so it is always
false in release and the crash would return in production. `dirty` is a real
field and holds in both modes.

### [GOTCHA] [CRITICAL] Insets must be measured against the surface the entry lands in
**Area:** `lib/overlay_safe_area.dart`
**Tags:** `#architecture` `#gotcha`
**Verified:** 2026-08-07

**Symptom:** With a nested `Navigator` inside a `Scaffold` body, a banner lands
a full app bar too low (measured: 312 instead of 156).

**Root cause:** Insets are measured against the screen, but an `OverlayEntry` is
positioned against its `Overlay` — and a nested one already starts below the app
bar. The chrome gets cleared twice.

**Workaround:** `OverlaySafeArea.forSurface` subtracts how far the surface
already sits down the screen. Using the overlay's *context* is not enough — that
reports the same numbers as the calling context; the fix needs the geometric
offset via `localToGlobal`. The same applies to the bottom edge.
