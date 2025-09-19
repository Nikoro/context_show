import 'package:context_show/overlay_safe_area.dart';

/// A controller that is passed to the overlay builder.
///
/// It can be used to close the overlay and provides a [safeArea] that
/// respects the app bar and bottom navigation bar.
class OverlayController<T> {
  /// Creates an [OverlayController].
  const OverlayController(this.close, this.safeArea);

  /// Closes the overlay and returns the [result].
  ///
  /// Example:
  ///
  /// ```dart
  /// context.show(
  ///   (controller) => Card(
  ///     child: ListTile(
  ///       title: const Text('Hello'),
  ///       onTap: () => controller.close('world'),
  ///     ),
  ///   ),
  /// );
  /// ```
  final Future<void> Function([T? result]) close;

  /// The safe area for the overlay.
  ///
  /// It can be used to avoid the status bar, app bar, and bottom navigation bar.
  ///
  /// Example:
  ///
  /// ```dart
  /// context.show(
  ///  (controller) => Padding(
  ///    padding: controller.safeArea.insets,
  ///    child: const Text('Hello'),
  ///  ),
  /// );
  /// ```
  final OverlaySafeArea safeArea;
}
