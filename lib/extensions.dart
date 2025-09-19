import 'package:context_show/overlay_closer.dart';

/// An extension on `Iterable<OverlayCloser>` that provides a `byId` method.
extension OverlayCloserIterableExtensions on Iterable<OverlayCloser> {
  /// Returns an iterable of [OverlayCloser]s that have the given [id].
  ///
  /// Example:
  ///
  /// ```dart
  /// context.close((overlays) => overlays.byId('my-id'));
  /// ```
  Iterable<OverlayCloser> byId(String id) => where((c) => c.id == id);
}
