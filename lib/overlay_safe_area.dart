import 'package:context_show/app_bar_height.dart';
import 'package:context_show/bottom_bar_height.dart';
import 'package:flutter/material.dart';

/// A class that holds the safe area for the overlay.
///
/// It is used to avoid the status bar, app bar, and bottom navigation bar.
class OverlaySafeArea {
  /// Creates an [OverlaySafeArea].
  const OverlaySafeArea({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  /// Creates an [OverlaySafeArea] from the given [context].
  ///
  /// Pass [surface] when the overlay is inserted somewhere other than
  /// [context] — the insets are then expressed in that surface's coordinates.
  /// See [OverlaySafeArea.forSurface].
  factory OverlaySafeArea.of(BuildContext context, {BuildContext? surface}) {
    final padding = MediaQuery.paddingOf(context);
    final safeArea = OverlaySafeArea(
      top: AppBarHeight.maybeOf(context) ?? padding.top,
      bottom: BottomBarHeight.maybeOf(context) ?? padding.bottom,
      left: padding.left,
      right: padding.right,
    );
    return surface == null ? safeArea : safeArea.forSurface(surface);
  }

  /// Re-expresses these insets relative to [surface].
  ///
  /// The insets are measured against the screen, but an [OverlayEntry] is
  /// positioned against the [Overlay] it is inserted into — and that overlay
  /// does not have to start at the top of the screen. A nested [Navigator]
  /// inside a [Scaffold] body, for example, owns an overlay that already
  /// begins below the app bar:
  ///
  /// ```dart
  /// Scaffold(
  ///   appBar: AppBar(...),   // 156 tall
  ///   body: Navigator(...),  // its overlay starts at y = 156
  /// )
  /// ```
  ///
  /// Applying a screen-measured inset of 156 there would clear the app bar a
  /// second time and leave a 156px gap. Subtracting how far the surface
  /// already sits down the screen keeps both rulers aligned.
  OverlaySafeArea forSurface(BuildContext surface) {
    final box = surface.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return this;

    final origin = box.localToGlobal(Offset.zero);
    final view = View.maybeOf(surface);
    if (view == null) return this;

    final screen = view.physicalSize / view.devicePixelRatio;
    final bottomGap = screen.height - (origin.dy + box.size.height);
    final rightGap = screen.width - (origin.dx + box.size.width);

    return OverlaySafeArea(
      top: _shrink(top, origin.dy),
      bottom: _shrink(bottom, bottomGap),
      left: _shrink(left, origin.dx),
      right: _shrink(right, rightGap),
    );
  }

  /// Removes the part of [inset] the surface already covers, never going
  /// negative — a negative margin would drag content off screen.
  static double _shrink(double inset, double covered) {
    if (covered.isNaN || covered <= 0) return inset;
    final remaining = inset - covered;
    return remaining > 0 ? remaining : 0;
  }

  /// The top safe area inset.
  final double top;

  /// The bottom safe area inset.
  final double bottom;

  /// The left safe area inset.
  final double left;

  /// The right safe area inset.
  final double right;

  /// The safe area insets.
  ///
  /// Example:
  ///
  /// ```dart
  /// context.show(
  ///   (overlay) => Padding(
  ///     padding: overlay.safeArea.insets,
  ///     child: const Text('Hello'),
  ///   ),
  /// );
  /// ```
  EdgeInsets get insets =>
      EdgeInsets.only(top: top, bottom: bottom, left: left, right: right);
}
