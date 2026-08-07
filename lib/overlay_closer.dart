/// A class that holds the information needed to close an overlay.
class OverlayCloser {
  /// Creates an [OverlayCloser].
  const OverlayCloser(this.function, this.type, this.id, [this._isStale]);

  /// The function that closes the overlay.
  final Future<void> Function([Object?]) function;

  /// The type of the result that the overlay returns.
  final Type type;

  /// The id of the overlay.
  final String id;

  /// Reports whether the overlay this closer belongs to is already gone.
  final bool Function()? _isStale;

  /// Whether the overlay has been torn down without [function] being called.
  ///
  /// A route pop or a disposed app removes the [OverlayEntry] without going
  /// through the normal close path, which would otherwise leave this closer
  /// registered — and selectable — forever.
  bool isStale() => _isStale?.call() ?? false;
}
