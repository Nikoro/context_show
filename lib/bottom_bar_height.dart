import 'package:context_show/app_bar_height.dart';
import 'package:context_show/scaffold_finder.dart';
import 'package:flutter/material.dart';

/// A utility class to get the height of the bottom navigation bar.
///
/// It is used to calculate the safe area for the overlay.
abstract class BottomBarHeight {
  const BottomBarHeight._();

  /// Returns the height of the bottom navigation bar if it exists,
  /// otherwise returns null.
  ///
  /// It supports [BottomAppBar], [NavigationBar], and [BottomNavigationBar].
  ///
  /// The [Scaffold] is resolved with [ScaffoldFinder], so this also works when
  /// [context] sits *above* the [Scaffold] it belongs to.
  ///
  /// Example:
  ///
  /// ```dart
  /// final bottomBarHeight = BottomBarHeight.maybeOf(context);
  /// ```
  static double? maybeOf(BuildContext context) =>
      switch (ScaffoldFinder.maybeOf(context)?.widget.bottomNavigationBar) {
        BottomAppBar _ => Theme.of(context).bottomAppBarTheme.height ?? 80,
        NavigationBar _ => Theme.of(context).navigationBarTheme.height ?? 80,
        BottomNavigationBar _ => kBottomNavigationBarHeight, // 58 actually
        null => null,
        _ => _fallbackHeight(context),
      };

  /// Infers the height of an unrecognised bottom bar by subtracting the body
  /// and the app bar from the screen height.
  ///
  /// This only holds when [context] is inside the body, since it measures the
  /// context's own render box. From above the [Scaffold] that box is the whole
  /// screen and the subtraction yields a meaningless 0 (or a negative number),
  /// so clamp it away rather than reporting a bogus inset.
  static double _fallbackHeight(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final bodyHeight = renderBox?.size.height ?? 0;
    final appBarMaxHeight = AppBarHeight.maybeOf(context) ?? 0;
    final height = MediaQuery.heightOf(context) - bodyHeight - appBarMaxHeight;
    return height > 0 ? height : 0;
  }
}
