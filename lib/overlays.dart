import 'package:context_show/context_show.dart';
import 'package:context_show/overlay_closer.dart';

/// A utility class to select overlays to close.
///
/// It is used in `context.close()` to select which overlays to close.
abstract class Overlays {
  Overlays._();

  /// A selector that returns the first overlay that matches the given [id].
  ///
  /// If [id] is null, it returns the first overlay.
  ///
  /// Example:
  ///
  /// ```dart
  /// context.close(Overlays.first(id: 'my-id'));
  /// ```
  static OverlayCloser? Function(Iterable<OverlayCloser> closers) first({
    String? id,
  }) {
    return (Iterable<OverlayCloser> closers) {
      final filtered = id != null ? closers.byId(id) : closers;
      return filtered.isEmpty ? null : filtered.first;
    };
  }

  /// A selector that returns the last overlay that matches the given [id].
  ///
  /// If [id] is null, it returns the last overlay.
  ///
  /// This is the default selector for `context.close()`.
  ///
  /// Example:
  ///
  /// ```dart
  /// context.close(Overlays.last(id: 'my-id'));
  /// ```
  static OverlayCloser? Function(Iterable<OverlayCloser> closers) last({
    String? id,
  }) {
    return (Iterable<OverlayCloser> closers) {
      final filtered = id != null ? closers.byId(id) : closers;
      return filtered.isEmpty ? null : filtered.last;
    };
  }

  /// A selector that returns all overlays that match the given [id].
  ///
  /// If [id] is null, it returns all overlays.
  ///
  /// Example:
  ///
  /// ```dart
  /// context.close(Overlays.all(id: 'my-id'));
  /// ```
  static Iterable<OverlayCloser> Function(Iterable<OverlayCloser> closers) all({
    String? id,
  }) {
    return (Iterable<OverlayCloser> closers) =>
        id != null ? closers.byId(id) : closers;
  }
}
