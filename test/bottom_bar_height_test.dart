import 'package:context_show/bottom_bar_height.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BottomBarHeight', () {
    testWidgets('maybeOf returns null if no Scaffold', (tester) async {
      await tester.pumpWidget(const Placeholder());
      final context = tester.element(find.byType(Placeholder));
      expect(BottomBarHeight.maybeOf(context), isNull);
    });

    testWidgets('maybeOf returns null if Scaffold has no bottom bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const Placeholder())),
      );
      final context = tester.element(find.byType(Placeholder));
      expect(BottomBarHeight.maybeOf(context), isNull);
    });

    testWidgets('maybeOf returns BottomAppBar height from theme', (
      tester,
    ) async {
      const themeHeight = 90.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            bottomAppBarTheme: const BottomAppBarThemeData(height: themeHeight),
          ),
          home: Scaffold(
            body: const Placeholder(),
            bottomNavigationBar: BottomAppBar(),
          ),
        ),
      );

      final context = tester.element(find.byType(Placeholder));
      expect(BottomBarHeight.maybeOf(context), equals(themeHeight));
    });

    testWidgets('maybeOf returns NavigationBar height from theme', (
      tester,
    ) async {
      const themeHeight = 85.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationBarTheme: const NavigationBarThemeData(
              height: themeHeight,
            ),
          ),
          home: Scaffold(
            body: const Placeholder(),
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(Placeholder));
      expect(BottomBarHeight.maybeOf(context), equals(themeHeight));
    });

    testWidgets(
      'maybeOf returns kBottomNavigationBarHeight for BottomNavigationBar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Placeholder(),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(Placeholder));
        expect(
          BottomBarHeight.maybeOf(context),
          equals(kBottomNavigationBarHeight),
        );
      },
    );

    testWidgets('maybeOf returns _fallbackHeight for unknown bottom widget', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Placeholder(),
            bottomNavigationBar: Container(height: 42),
          ),
        ),
      );

      final context = tester.element(find.byType(Placeholder));
      final height = BottomBarHeight.maybeOf(context);
      expect(height, isNonZero);
    });
  });
}
