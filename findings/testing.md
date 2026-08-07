# Testing

### [GOTCHA] [CRITICAL] A widget test has no status bar unless you give it one
**Area:** `test/overlay_placement_test.dart`
**Tags:** `#testing` `#gotcha`
**Verified:** 2026-08-07

**Symptom:** A safe-area bug ships past a fully green suite.

**Root cause:** `tester.view.padding` defaults to zero, so a broken inset that
falls back to `padding.top` returns 0 — exactly what a correct inset returns
when there is no chrome. Broken and correct shapes become indistinguishable.

**Workaround:** Set a status bar in every safe-area test:

```dart
tester.view.padding = const FakeViewPadding(top: 100);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.reset);
```

This is how the reported app-bar bug reached production.

### [GOTCHA] [CRITICAL] `await close()` before pumping deadlocks the test
**Area:** `test/closer_lifecycle_test.dart`
**Tags:** `#testing` `#gotcha`
**Verified:** 2026-08-07

**Symptom:** The test hangs until the timeout with no output. Easy to misread
as a bug in the code under test — an earlier write-up of this concluded the
behaviour was "unverifiable" for that reason.

**Root cause:** `close()` awaits `controller.reverse()`, which only advances
while the test clock is pumped. Awaiting it before `pumpAndSettle()` means
nothing ever drives the animation.

**Workaround:** Do not await; pump instead.

```dart
context.close();              // no await
await tester.pumpAndSettle();
```

The exception is a torn-down tree: there `close()` skips the animation and
completes on its own, so awaiting it directly is both safe and the point of
the test.
