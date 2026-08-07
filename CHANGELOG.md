## Unreleased

### 🐛 Bug Fixes

- **Safe area insets are now correct when `show` is called from above the `Scaffold`**
  - A page showing an overlay from its own `build`/`State` context previously
    got the status bar height instead of the app bar height, so top banners
    painted over the app bar and hid the back button.
  - `Scaffold.maybeOf` only walks upwards; the lookup now falls back to a
    breadth-first search downwards when there is no `Scaffold` above.
  - Nested `Scaffold`s resolve to the outer one, which owns the chrome the
    overlay appears over.
  - Applies to both `AppBarHeight` and `BottomBarHeight`.
- An unrecognised `bottomNavigationBar` no longer reports a negative inset.
- **`close()` no longer hangs on an overlay whose tree was destroyed**
  - It awaited the exit animation, but a torn-down tree has no ticker to drive
    it, so the future never completed — leaving the closer registered and its
    `AnimationController` undisposed for the rest of the process.
  - The animation is now skipped when the entry is already gone.
- **Stale closers are pruned**
  - A closer whose overlay was destroyed without `close()` stayed selectable by
    `Overlays.all()` forever. Each `show` now drops them.
  - An overlay that outlives its route is *not* stale: routes are entries in
    one shared `Overlay`, so a banner shown from a page deliberately survives
    a `pop`. Call `close()` explicitly if you want it gone with the page.
- `TransitionBuilders.size` no longer uses the deprecated
  `SizeTransition.axisAlignment`. Its own `axisAlignment` argument is
  unchanged and is translated to `alignment` internally.
- **Overlays in a nested `Navigator` no longer clear the chrome twice**
  - Insets are measured against the screen, but an `OverlayEntry` is
    positioned against the `Overlay` it is inserted into, which does not have
    to start at the top of the screen.
  - With a nested `Navigator` inside a `Scaffold` body (a per-tab navigator,
    for example) the overlay already begins below the app bar, so the full
    inset was applied on top of an origin that had cleared it — leaving a gap
    the height of the app bar.
  - `show` now measures the insets against the overlay the entry lands in, and
    `overlay.safeArea` reports them in that overlay's coordinates.

### 📝 Documentation

- Documented the positioning modes in the README: safe area (default),
  `safeArea: false` for edge-to-edge over the app bar, explicit `margin` for
  anything in between, per-edge insets via `overlay.safeArea`, and full-bleed
  backgrounds via `backgroundMargin`.
- Removed a docstring for a `fullScreen` parameter that does not exist; the
  equivalent is `safeArea: false`.

### 🏗️ API

- `OverlayController` and `OverlaySafeArea` are now exported from
  `package:context_show/context_show.dart`. They were already reachable
  through `show`, but could not be named without a direct import.

## 0.3.0

This release improves the `context.close()` API with flexible parameter ordering and includes CI/CD workflow improvements.

### 💥 Breaking Changes

- **`context.close()` signature changed to support flexible parameter ordering**
  - Parameters can now be passed in any order: `(selector, result)` or `(result, selector)`
  - Automatic detection of parameter types for improved developer experience
  - This change may affect code that explicitly relies on positional parameter ordering

```dart
// Both parameter orders now work
context.close(Overlays.first(), 'result_value');
context.close('result_value', Overlays.first());

// With custom selectors
context.close((overlays) => overlays.byId('myId'), 'result_value');
context.close('result_value', (overlays) => overlays.byId('myId'));
```

### ✨ New Features

- **Flexible parameter ordering for `context.close()`**
  - Pass parameters in any order for better ergonomics
  - Support for closing with selector, result, or both
  - Enhanced documentation and examples
- Add comprehensive test suite for `context.close()` functionality
- Simplify CI workflows and add streamlined testing, formatting, and release automation

---

## 0.2.0

This release introduces a major API refactoring to provide more granular control over overlay layouts and improve flexibility.

### 💥 Breaking Changes

The `context.show()` method has been significantly refactored. The following parameters have been changed or removed:

- **`fullScreen` is removed.**
  - To control whether the overlay respects the safe area, use the new `safeArea` parameter.
  - To show an overlay over the entire screen (including the app bar), use `rootOverlay: true`.
- **`alignment` default behavior is changed.**
  - The default alignment is now `Alignment.center`, in 0.1.0 default alignment was `Alignment.bottomCenter`

### ✨ New Features

#### Granular Layout & Behavior Control

| Parameter | Type | Description |
|-----------|------|-------------|
| `safeArea` | `bool` | If `true` (default), the overlay respects all safe insets — including the **system status bar**, **device notches**, as well as **Scaffold elements** like **AppBar** and **BottomNavigationBar**. Ignored if margin (for content) or backgroundMargin (for background) is manually provided. |
| `margin` | `EdgeInsets?` | Applies custom padding around the **main content**. **Overrides** `safeArea` for the content area. |
| `backgroundMargin` | `EdgeInsets?` | Applies custom padding around the **background layer**. **Overrides** `safeArea` for the background. |
| `clipper` | `Widget Function(Widget child)?` | Wraps the **main content** with any Flutter clipping widget (`ClipRect`, `ClipRRect`, `ClipOval`, etc.). |
| `backgroundClipper` | `Widget Function(Widget child)?` | Same as `clipper`, but applied to the **background widget**. |

---

#### 🧱 Examples

**Using a rectangular clip on the main content:**

```dart
context.show(
  (overlay) => MyOverlay(),
  clipper: (child) => ClipRect(child: child),
);
```

**Circular overlay background with custom margin (ignores safeArea):**

```dart
context.show(
  (overlay) => MyOverlay(),
  background: (overlay) => Container(color: Colors.black54),
  backgroundClipper: (child) => ClipOval(child: child),
  backgroundMargin: EdgeInsets.all(16), // safeArea ignored for background
);
```

---

#### `rootOverlay`

A new boolean parameter that controls **which Navigator’s overlay** is used:

- `rootOverlay: true` → Inserts into the **top-level Navigator** (use when inside nested navigation
- `rootOverlay: false` *(default)* → Inserts into the **closest local Navigator**

### Migration Guide

Here’s how to migrate your code from `v0.1.0` to `v0.2.0`.

#### Replacement for `fullScreen: true`

In **v0.2.0**, the `fullScreen` parameter has been removed.  
To achieve the same effect, use:

- `safeArea: false` — disables padding around system UI (status bar, navigation bar, etc.)
- `rootOverlay: true` — ensures the overlay is inserted into the root navigator (recommended for nested navigation apps)

```diff
-context.show(
-  (overlay) => MyOverlay(),
-  fullScreen: true,
-);
+context.show(
+  (overlay) => MyOverlay(),
+  safeArea: false,
+  rootOverlay: true, // Optional: only needed in nested navigation contexts
+);
```

#### Default Alignment Change (`Alignment.center`)

In **v0.2.0**, the default alignment for `context.show()` is now `Alignment.center`.

You can remove the explicit parameter:

```diff
-context.show(
-  (overlay) => MyOverlay(),
-  alignment: Alignment.center,
-);
+context.show(
+  (overlay) => MyOverlay(),
+);
```

---

#### New Usage for `Alignment.bottomCenter`

If you now want to explicitly position your overlay at the bottom center:

```diff
 context.show(
   (overlay) => MyOverlay(),
-);
+  alignment: Alignment.bottomCenter,
+);
```

## 0.1.0

Initial release 🎉
