import 'package:context_show/app_bar_height.dart';
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
  /// Example:
  ///
  /// ```dart
  /// final bottomBarHeight = BottomBarHeight.maybeOf(context);
  /// ```
  static double? maybeOf(BuildContext context) =>
      switch (Scaffold.maybeOf(context)?.widget.bottomNavigationBar) {
        BottomAppBar _ => Theme.of(context).bottomAppBarTheme.height ?? 80,
        NavigationBar _ => Theme.of(context).navigationBarTheme.height ?? 80,
        BottomNavigationBar _ => kBottomNavigationBarHeight, // 58 actually
        null => null,
        _ => _fallbackHeight(context),
      };

  static double _fallbackHeight(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final bodyHeight = renderBox?.size.height ?? 0;
    final appBarMaxHeight = AppBarHeight.maybeOf(context) ?? 0;
    return MediaQuery.heightOf(context) - bodyHeight - appBarMaxHeight;
  }
}
