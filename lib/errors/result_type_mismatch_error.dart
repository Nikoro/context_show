/// An error that is thrown when `context.close()` is called with a result
/// of a different type than the one that was expected by `context.show()`.
class ResultTypeMismatchError extends Error {
  /// Creates a [ResultTypeMismatchError].
  ResultTypeMismatchError({
    required this.id,
    required this.expected,
    required this.actual,
    required this.result,
  });

  /// The id of the overlay.
  final String id;

  /// The expected type of the result.
  final Type expected;

  /// The actual type of the result.
  final Type actual;

  /// The result that was passed to `context.close()`.
  final Object? result;

  @override
  String toString() => _formatTypeMismatch(
        id: id,
        expected: expected,
        actual: actual,
        result: result,
      );

  String _formatTypeMismatch({
    required String id,
    required Type expected,
    required Type actual,
    required Object? result,
  }) {
    // Left parts of the lines
    final showLine = "context.show<$expected>()";
    final closeLine = "context.close(result: $result)";

    // Type parts
    final expectedStr = expected.toString();
    final actualStr = actual.toString();

    // Determine padding for <- alignment
    final leftWidth = [
      showLine.length,
      closeLine.length,
    ].reduce((a, b) => a > b ? a : b);
    final paddedShowLine = "${showLine.padRight(leftWidth)} <- $expectedStr";
    final paddedCloseLine = "${closeLine.padRight(leftWidth)} <- $actualStr";

    // Determine center column for arrows based on the longest type
    final typeMaxLength = [
      expectedStr.length,
      actualStr.length,
    ].reduce((a, b) => a > b ? a : b);
    final arrowColumn =
        leftWidth + 3 + typeMaxLength ~/ 2; // 4 = length of " <- "

    final mismatch = "mismatch";
    final mismatchStart = arrowColumn - (mismatch.length ~/ 2) + 1;

    final upArrowLine = ' ' * arrowColumn + '↑';
    final mismatchLine = ' ' * mismatchStart + mismatch;
    final downArrowLine = ' ' * arrowColumn + '↓';

    return [
      "\n",
      "Tried to close overlay with id '$id' using a value of type $actual,",
      "but context.show() for this overlay expected a result of type $expected:",
      "\n",
      paddedShowLine,
      upArrowLine,
      mismatchLine,
      downArrowLine,
      paddedCloseLine,
      "\n",
    ].join("\n");
  }
}
