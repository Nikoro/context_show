import 'package:flutter/material.dart';

/// A utility class to get the height of the app bar.
///
/// It is used to calculate the safe area for the overlay.
abstract class AppBarHeight {
  const AppBarHeight._();

  /// Returns the height of the app bar if it exists, otherwise returns null.
  ///
  /// Example:
  ///
  /// ```dart
  /// final appBarHeight = AppBarHeight.maybeOf(context);
  /// ```
  static double? maybeOf(BuildContext context) =>
      Scaffold.maybeOf(context)?.appBarMaxHeight;
}
