# `context.close()` ignores the context it is called on

**Status: verified, undecided.** The behaviour below is measured and real. What
is open is not *whether* it happens but *which contract this package wants* —
and both answers change the public API, so it needs a deliberate call.

## The observation

`lib/context_show.dart` keeps one module-global registry:

```dart
final _closers = <OverlayCloser>[];
```

`close` is an extension on `BuildContext`, so it reads as scoped:

```dart
context.close(Overlays.all());
```

but the selector receives every registered closer in the process, and `this` is
never consulted. Measured with two overlays shown from two sibling contexts:

```
before: A=1 B=1
after : A=0 B=0     ← a.close(Overlays.all()) closed B as well
```

## The decision to make

**If `close` is meant to be global**, it should not be a `BuildContext`
extension — a top-level `closeOverlays(...)` would not imply a scoping it does
not have. Documenting it is free and may be the honest description of what this
already is.

**If `close` is meant to be scoped**, closers need to carry their
`Navigator`/`Overlay` identity, and the default selector should only reach the
ones visible from the calling context. This is a breaking change.

Note the practical impact is narrow today: `Overlays.last()` — the default —
always targets the newest closer, so the global registry only surprises callers
who use `Overlays.all()` or a custom selector.

## Already resolved — do not re-litigate

These were part of the original write-up and are now settled, with tests in
`test/closer_lifecycle_test.dart`:

- **Closers leaked on teardown.** `close()` awaited an exit animation that a
  torn-down tree can never drive, so it hung and never unregistered. Fixed by
  skipping the animation when the entry is gone, plus pruning stale closers on
  each `show`.
- **"An overlay outliving its route is a bug."** It is not. `MaterialApp` has
  one `Overlay`; routes are entries in it, so a banner shown from a page
  deliberately survives a pop, and auto-dismiss still fires. Pruning exempts
  this case explicitly.
- **"The probe hangs, so this is unverifiable."** It hung because it awaited
  `close()` before pumping the test clock. Do not await; call `close()` and then
  `pumpAndSettle()`. See `findings/testing.md`.

## Also worth checking

Test isolation was measured and is *not* affected: a leftover closer does not
break a following test, because `Overlays.last()` picks the newest one. Only
`Overlays.all()` in a process shared across tests could see stale entries, and
pruning on `show` now handles that.
