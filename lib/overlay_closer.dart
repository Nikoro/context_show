/// A class that holds the information needed to close an overlay.
class OverlayCloser {
  /// Creates an [OverlayCloser].
  const OverlayCloser(this.function, this.type, this.id);

  /// The function that closes the overlay.
  final Future<void> Function([Object?]) function;

  /// The type of the result that the overlay returns.
  final Type type;

  /// The id of the overlay.
  final String id;
}
