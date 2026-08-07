# Overlay lifecycle

How entries, closers and animation controllers live and die.

### [DECISION] [NOTE] An overlay deliberately outlives its route
**Area:** `lib/context_show.dart`
**Tags:** `#design-decision` `#architecture`
**Verified:** 2026-08-07

**What:** A banner shown from a page stays on screen after that page is popped.

**Why:** `MaterialApp` has exactly **one** `Overlay`; routes are entries inside
it, not Overlays of their own (measured: `overlays in tree: 1` before and after
a push, and the page's overlay is identical to the root one). The overlay never
belonged to the page, so there is nothing to tear down with it. Auto-dismiss
still fires normally afterwards.

**Alternatives considered:** Treating this as a leak and force-closing on pop.
Rejected — it is useful behaviour, and callers who want the banner gone with
the page can call `close()` explicitly. Staleness pruning is careful to exempt
this case.

### [BUG] [CRITICAL] `close()` hung forever on a destroyed tree
**Area:** `lib/context_show.dart`
**Tags:** `#gotcha` `#data-integrity`
**Verified:** 2026-08-07

**Trigger:** Calling `close()` on an overlay whose widget tree is already gone.

**Root cause:** It awaited the exit animation, but a torn-down tree has no
ticker to drive it, so the future never completed — leaving the closer
registered and its `AnimationController` undisposed for the process lifetime.

**Fix applied:** Skip the animation when `entry.mounted` is false, and prune
stale closers on each `show`.

### [GOTCHA] [CRITICAL] A controller running when its vsync dies is a Flutter-level leak
**Area:** `lib/context_show.dart`
**Tags:** `#gotcha` `#architecture`
**Verified:** 2026-08-07

**Symptom:** "NavigatorState was disposed with an active Ticker" when a tree is
destroyed mid-animation.

**Root cause:** Not specific to this package — a bare `AnimationController`
reproduces it identically. The dispose signal never reaches the animation's
owner in time.

**Workaround:** None available from library code; `catchError` on the
`TickerFuture` and `controller.stop()` were both tried and neither intercepts
it. Tests settle the entry animation before tearing the tree down.

### [NOTE] [GOTCHA] An `OverlayEntry` is not `mounted` until the next frame
**Area:** `lib/context_show.dart`
**Tags:** `#gotcha` `#testing`
**Verified:** 2026-08-07

`mounted` stays false immediately after `insert()` and only flips once the
`Overlay` rebuilds. Any "is this entry dead?" check based on `!mounted` must
first prove the entry was ever alive, or it will discard entries created
earlier in the same frame — which broke three passing tests before the latch
in `show()` was added.

### [NOTE] [GOTCHA] A background widget is placed by an `Align`
**Area:** `lib/context_show.dart`
**Tags:** `#gotcha` `#ui`
**Verified:** 2026-08-07

A `Container` with only a color expands to fill the screen, which is what the
demos rely on. A widget that sizes itself to its child — `ColoredBox` — collapses
to a point instead. Wrap those in `SizedBox.expand`.
