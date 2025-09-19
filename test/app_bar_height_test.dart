import 'package:context_show/app_bar_height.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBarHeight', () {
    testWidgets('maybeOf returns null if no Scaffold', (tester) async {
      await tester.pumpWidget(const Placeholder());
      final context = tester.element(find.byType(Placeholder));
      expect(AppBarHeight.maybeOf(context), isNull);
    });

    testWidgets('maybeOf returns null if Scaffold has no AppBar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const Placeholder())),
      );

      final context = tester.element(find.byType(Placeholder));
      expect(AppBarHeight.maybeOf(context), isNull);
    });

    testWidgets('maybeOf returns AppBar default height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Placeholder(),
          ),
        ),
      );

      final context = tester.element(find.byType(Placeholder));
      expect(AppBarHeight.maybeOf(context), equals(kToolbarHeight));
    });

    testWidgets('maybeOf returns custom AppBar height', (tester) async {
      const customHeight = 100.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(customHeight),
              child: AppBar(title: const Text('Custom')),
            ),
            body: const Placeholder(),
          ),
        ),
      );

      final context = tester.element(find.byType(Placeholder));
      expect(AppBarHeight.maybeOf(context), equals(customHeight));
    });
  });
}
