import 'package:flutter/material.dart';

/// Finds the [ScaffoldState] whose chrome an overlay shown from a given
/// context will appear over.
///
/// [Scaffold.maybeOf] only walks *upwards*, so it misses the very common shape
/// where a page shows an overlay from its own `build`/`State` context:
///
/// ```dart
/// Widget build(BuildContext context) {   // <- this context is ABOVE the Scaffold
///   return Scaffold(appBar: AppBar(...), body: ...);
/// }
///
/// void _onSaved() => context.show(...);  // must still clear the app bar
/// ```
///
/// This helper keeps the unambiguous upward answer as the first choice and
/// only descends when there is none.
abstract class ScaffoldFinder {
  const ScaffoldFinder._();

  /// Returns the closest [ScaffoldState] above [context], or the first one
  /// below it if there is none above.
  ///
  /// Returns null when the context has no [Scaffold] in either direction.
  static ScaffoldState? maybeOf(BuildContext context) =>
      Scaffold.maybeOf(context) ?? _firstBelow(context);

  /// Breadth-first search for the first [ScaffoldState] under [context].
  ///
  /// Breadth-first matters: with nested Scaffolds it finds the *outer* one,
  /// which owns the chrome the overlay actually appears over. A depth-first
  /// walk could descend into an inner, app-bar-less Scaffold first and report
  /// no chrome at all.
  static ScaffoldState? _firstBelow(BuildContext context) {
    if (context is! Element || !context.mounted) return null;

    // visitChildElements throws only while the element is *actively building*,
    // because the child list is still being assembled. A merely dirty element
    // — one with a rebuild scheduled — still has its previous children and
    // walks fine, so `dirty` must not gate the search: a page that changes
    // state just before showing an overlay (a dialog flipping a flag, say) is
    // dirty at that moment, and giving up there costs it the app bar height
    // and drops the banner onto the status bar.
    if (_isBuilding(context)) return null;

    var frontier = <Element>[context];

    while (frontier.isNotEmpty) {
      final next = <Element>[];

      for (final element in frontier) {
        ScaffoldState? found;

        // Defensive: `debugDoingBuild` is a debug-only signal, so in release
        // an element that is mid-build slips past the guard above and throws
        // here. Treating that as "no Scaffold below" keeps the caller on its
        // MediaQuery fallback instead of crashing the app.
        try {
          element.visitChildElements((child) {
            if (found != null) return;
            if (child is StatefulElement && child.state is ScaffoldState) {
              found = child.state as ScaffoldState;
              return;
            }
            next.add(child);
          });
        } on FlutterError {
          continue;
        }

        if (found != null) return found;
      }

      frontier = next;
    }

    return null;
  }

  /// Whether [element] is building right now, as opposed to merely having a
  /// rebuild scheduled — only the former makes its child list unsafe to walk.
  ///
  /// `debugDoingBuild` is debug-only; in release it is const false, which the
  /// try/catch around the walk covers.
  static bool _isBuilding(Element element) {
    var building = false;
    assert(() {
      building = element.debugDoingBuild;
      return true;
    }());
    return building;
  }
}
