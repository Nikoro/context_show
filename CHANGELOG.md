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
