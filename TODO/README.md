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
