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

    // visitChildElements throws while the element is building, because the
    // child list is still being assembled. Callers that show an overlay
    // straight from build() would otherwise crash, so give up on the downward
    // search and let the caller fall back to MediaQuery.
    //
    // `dirty` is the load-bearing check: it is a real field, so it also holds
    // in release builds. `debugDoingBuild` is debug-only and merely catches
    // anything `dirty` misses while asserts are enabled.
    if (context.dirty) return null;
    assert(!context.debugDoingBuild, 'still building with a clean element');

    var frontier = <Element>[context];

    while (frontier.isNotEmpty) {
      final next = <Element>[];

      for (final element in frontier) {
        ScaffoldState? found;

        element.visitChildElements((child) {
          if (found != null) return;
          if (child is StatefulElement && child.state is ScaffoldState) {
            found = child.state as ScaffoldState;
            return;
          }
          next.add(child);
        });

        if (found != null) return found;
      }

      frontier = next;
    }

    return null;
  }
}
