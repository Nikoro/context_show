import 'package:context_show/overlay_closer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayCloser', () {
    test('stores id and type correctly', () async {
      const id = 'testId';
      const type = String;

      final closer = OverlayCloser(([_]) async {}, type, id);

      expect(closer.id, equals(id));
      expect(closer.type, equals(type));
    });

    test('function can be called without a result', () async {
      var called = false;

      final closer = OverlayCloser(
        ([_]) async {
          called = true;
        },
        String,
        'id',
      );

      await closer.function();
      expect(called, isTrue);
    });

    test('function can be called with a result', () async {
      Object? received;

      final closer = OverlayCloser(
        ([result]) async {
          received = result;
        },
        String,
        'id',
      );

      const value = 'hello';
      await closer.function(value);
      expect(received, equals(value));
    });
  });
}
