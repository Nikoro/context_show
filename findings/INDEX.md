# Findings Index

Crucial discoveries captured during development sessions. Every claim here was
measured in a widget test, not reasoned about from the source — several entries
record a hypothesis that was wrong on first pass and only fell over when run.

| File | Area | Findings | Last Updated |
|------|------|----------|--------------|
| [safe-area.md](safe-area.md) | Safe area & inset calculation | 5 | 2026-08-07 |
| [overlay-lifecycle.md](overlay-lifecycle.md) | Entries, closers, controllers | 5 | 2026-08-07 |
| [testing.md](testing.md) | Widget test pitfalls | 2 | 2026-08-07 |

## All Finding Titles

### safe-area.md
- [GOTCHA] [CRITICAL] An `AppBar`'s height already includes the status bar
- [GOTCHA] [CRITICAL] Inside a `Scaffold` body, `MediaQuery` reports no padding
- [GOTCHA] [CRITICAL] `Scaffold.maybeOf` only walks upwards
- [GOTCHA] [CRITICAL] `visitChildElements` throws during build
- [GOTCHA] [CRITICAL] Insets must be measured against the surface the entry lands in

### overlay-lifecycle.md
- [DECISION] [NOTE] An overlay deliberately outlives its route
- [BUG] [CRITICAL] `close()` hung forever on a destroyed tree
- [GOTCHA] [CRITICAL] A controller running when its vsync dies is a Flutter-level leak
- [NOTE] [GOTCHA] An `OverlayEntry` is not `mounted` until the next frame
- [NOTE] [GOTCHA] A background widget is placed by an `Align`

### testing.md
- [GOTCHA] [CRITICAL] A widget test has no status bar unless you give it one
- [GOTCHA] [CRITICAL] `await close()` before pumping deadlocks the test
