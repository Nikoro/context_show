# TODO

Open problems in `context_show`, written up so the reasoning survives between
sessions. Each file is one problem: what was measured, what is actually open,
and what to watch out for while resolving it.

Discoveries that are *settled* do not live here — they live in
[findings/](../findings/INDEX.md).

## Items

| File | Problem | Verified? | Priority |
|---|---|---|---|
| [closers-are-global.md](closers-are-global.md) | `_closers` is module-global, so `context.close()` ignores its context | yes, measured | needs a design decision, not a fix |

## Done

- **`safe-area-top-inset.md`** — `OverlaySafeArea` only looked up the tree, so a
  banner shown from above its `Scaffold` covered the app bar. Fixed via
  `lib/scaffold_finder.dart`; covered by `test/overlay_placement_test.dart`.
  Two further bugs surfaced while fixing it: insets were measured against the
  screen rather than the `Overlay` the entry lands in, and an unrecognised
  bottom bar could report a negative inset. Both fixed, both tested.

  **Post-0.3.1 follow-up.** The downward search bailed out on `context.dirty`,
  which is far wider than intended: `dirty` means "a rebuild is scheduled", not
  "building right now", and a merely dirty element still has walkable children.
  Any page that changed state in the same turn as it showed a banner (a dialog
  flipping a flag) therefore fell back to the status bar and covered the app
  bar again. The guard now keys on actually building, with a `try`/`catch`
  around the walk because `debugDoingBuild` is const false in release.
  Regression test: "a rebuild scheduled before showing still reads the app
  bar". Unreleased — consumers are on a path dependency until it ships.

## Working rules

**Measure before you argue.** Every file here has recorded at least one claim
that was wrong on first pass and only fell over when run. The interactions live
in `Scaffold`, `MediaQuery` and `Overlay`, not in this package — reading the
source is not enough.

**Land the regression test first.** Nothing here is worth touching without a
test that fails for the right reason.

**Keep the passing shapes passing.** The existing suites are the guard against a
fix that trades one broken shape for another.

The measurement traps themselves — status bars in widget tests, app bar heights,
deadlocking `close()` calls — are documented in
[findings/](../findings/INDEX.md). Read that before writing a probe.
