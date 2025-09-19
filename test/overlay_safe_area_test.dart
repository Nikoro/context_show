import 'package:context_show/overlay_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlaySafeArea', () {
    testWidgets('calculates safe area using MediaQuery when no Scaffold', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.fromLTRB(10, 20, 30, 40),
          ),
          child: const Placeholder(),
        ),
      );

      final context = tester.element(find.byType(Placeholder));
      final safeArea = OverlaySafeArea.fromContext(context);

      expect(safeArea.top, 20);
      expect(safeArea.bottom, 40);
      expect(safeArea.left, 10);
      expect(safeArea.right, 30);
    });

    testWidgets('uses AppBarHeight and BottomBarHeight if available', (
      tester,
    ) async {
      const customAppBarHeight = 50.0;
      const customBottomBarHeight = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(customAppBarHeight),
              child: AppBar(title: const Text('AppBar')),
            ),
            body: const Placeholder(),
            bottomNavigationBar: SizedBox(height: customBottomBarHeight),
          ),
        ),
      );

      final context = tester.element(find.byType(Placeholder));
      final safeArea = OverlaySafeArea.fromContext(context);

      expect(safeArea.top, customAppBarHeight);
      expect(safeArea.bottom, customBottomBarHeight);
    });

    testWidgets('insets returns correct EdgeInsets', (tester) async {
      const safeArea = OverlaySafeArea(
        top: 10,
        bottom: 20,
        left: 30,
        right: 40,
      );

      final insets = safeArea.insets;
      expect(insets.top, 10);
      expect(insets.bottom, 20);
      expect(insets.left, 30);
      expect(insets.right, 40);
    });
  });
}
