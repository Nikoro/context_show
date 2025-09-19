import 'package:context_show/overlay_controller.dart';
import 'package:context_show/overlay_safe_area.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayController', () {
    test('stores safeArea correctly', () async {
      final safeArea = const OverlaySafeArea(
        top: 10,
        bottom: 20,
        left: 5,
        right: 5,
      );

      final controller = OverlayController<void>(([_]) async {}, safeArea);

      expect(controller.safeArea, equals(safeArea));
    });

    test('close function can be called without result', () async {
      var called = false;

      final controller = OverlayController<void>(([_]) async {
        called = true;
      }, const OverlaySafeArea(top: 0, bottom: 0, left: 0, right: 0));

      await controller.close();
      expect(called, isTrue);
    });

    test('close function can be called with result', () async {
      String? resultReceived;

      final controller = OverlayController<String>(([res]) async {
        resultReceived = res;
      }, const OverlaySafeArea(top: 0, bottom: 0, left: 0, right: 0));

      const value = 'Hello';
      await controller.close(value);
      expect(resultReceived, equals(value));
    });
  });
}
