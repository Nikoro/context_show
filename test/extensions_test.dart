import 'package:context_show/context_show.dart';
import 'package:context_show/overlay_closer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayCloserIterableExtensions', () {
    test('byId returns matching OverlayCloser', () {
      final closers = [
        OverlayCloser(([_]) async {}, Object, 'one'),
        OverlayCloser(([_]) async {}, Object, 'two'),
        OverlayCloser(([_]) async {}, Object, 'three'),
      ];

      final result = closers.byId('two').toList();

      expect(result.length, 1);
      expect(result.first.id, 'two');
    });

    test('byId returns empty iterable if no match', () {
      final closers = [
        OverlayCloser(([_]) async {}, Object, 'one'),
        OverlayCloser(([_]) async {}, Object, 'two'),
      ];

      final result = closers.byId('unknown').toList();
      expect(result, isEmpty);
    });

    test('byId returns multiple if multiple have same id', () {
      final closers = [
        OverlayCloser(([_]) async {}, Object, 'dup'),
        OverlayCloser(([_]) async {}, Object, 'dup'),
        OverlayCloser(([_]) async {}, Object, 'unique'),
      ];

      final result = closers.byId('dup').toList();
      expect(result.length, 2);
      expect(result.every((c) => c.id == 'dup'), isTrue);
    });
  });
}
