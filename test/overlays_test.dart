import 'package:flutter_test/flutter_test.dart';
import 'package:context_show/overlay_closer.dart';
import 'package:context_show/overlays.dart';

void main() {
  group('Overlays', () {
    final closers = [
      OverlayCloser(([_]) async {}, Object, 'one'),
      OverlayCloser(([_]) async {}, Object, 'two'),
      OverlayCloser(([_]) async {}, Object, 'three'),
      OverlayCloser(([_]) async {}, Object, 'two'),
    ];

    test('first() returns first overlay without id', () {
      final selector = Overlays.first();
      final result = selector(closers);
      expect(result, equals(closers.first));
    });

    test('first(id: "two") returns first overlay with matching id', () {
      final selector = Overlays.first(id: 'two');
      final result = selector(closers);
      expect(result?.id, equals('two'));
      expect(result, equals(closers[1]));
    });

    test('first(id: "unknown") returns null', () {
      final selector = Overlays.first(id: 'unknown');
      final result = selector(closers);
      expect(result, isNull);
    });

    test('last() returns last overlay without id', () {
      final selector = Overlays.last();
      final result = selector(closers);
      expect(result, equals(closers.last));
    });

    test('last(id: "two") returns last overlay with matching id', () {
      final selector = Overlays.last(id: 'two');
      final result = selector(closers);
      expect(result?.id, equals('two'));
      expect(result, equals(closers[3]));
    });

    test('last(id: "unknown") returns null', () {
      final selector = Overlays.last(id: 'unknown');
      final result = selector(closers);
      expect(result, isNull);
    });

    test('all() returns all overlays without id', () {
      final selector = Overlays.all();
      final result = selector(closers).toList();
      expect(result, equals(closers));
    });

    test('all(id: "two") returns all overlays with matching id', () {
      final selector = Overlays.all(id: 'two');
      final result = selector(closers).toList();
      expect(result.length, 2);
      expect(result.every((c) => c.id == 'two'), isTrue);
    });

    test('all(id: "unknown") returns empty iterable', () {
      final selector = Overlays.all(id: 'unknown');
      final result = selector(closers).toList();
      expect(result, isEmpty);
    });
  });
}
