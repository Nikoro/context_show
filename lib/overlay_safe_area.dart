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
  factory OverlaySafeArea.fromContext(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return OverlaySafeArea(
      top: AppBarHeight.maybeOf(context) ?? padding.top,
      bottom: BottomBarHeight.maybeOf(context) ?? padding.bottom,
      left: padding.left,
      right: padding.right,
    );
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
