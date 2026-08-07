import 'package:context_show/scaffold_finder.dart';
import 'package:flutter/material.dart';

/// A utility class to get the height of the app bar.
///
/// It is used to calculate the safe area for the overlay.
abstract class AppBarHeight {
  const AppBarHeight._();

  /// Returns the height of the app bar if it exists, otherwise returns null.
  ///
  /// The returned height already includes the status bar, because that is what
  /// a real [AppBar] reports — do not add `MediaQuery.padding.top` to it.
  ///
  /// The [Scaffold] is resolved with [ScaffoldFinder], so this also works when
  /// [context] sits *above* the [Scaffold] it belongs to.
  ///
  /// Example:
  ///
  /// ```dart
  /// final appBarHeight = AppBarHeight.maybeOf(context);
  /// ```
  static double? maybeOf(BuildContext context) =>
      ScaffoldFinder.maybeOf(context)?.appBarMaxHeight;
}
