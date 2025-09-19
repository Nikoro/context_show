import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:context_show/context_show.dart';

import 'tools.dart';

void main() {
  const text = 'Some text';
  const duration = Duration(milliseconds: 100);

  group('context.show', () {
    testWithContext('shows and hides an overlay', (tester, context) async {
      final future = context.show((_) => Text(text), duration: duration);

      await tester.pump();
      expect(find.text(text), findsOneWidget);

      await tester.pump(duration);

      await future;

      await tester.pumpAndSettle();

      expect(find.text(text), findsNothing);
    });

    testWithContext(
      'closes overlay when dismissible is true and background is tapped',
      (tester, context) async {
        final future = context.show(
          (_) => const Text(text),
          dismissible: true,
          duration: Duration.zero,
        );

        await tester.pump();
        expect(find.text(text), findsOneWidget);

        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();

        await future;

        expect(find.text(text), findsNothing);
      },
    );

    testWithContext(
      'does not close overlay when dismissible is false and background is tapped',
      (tester, context) async {
        final future = context.show(
          (_) => Text(text),
          dismissible: false,
          duration: duration,
        );

        await tester.pump();
        expect(find.text(text), findsOneWidget);

        await tester.tapAt(Offset.zero);
        await tester.pump();

        expect(find.text(text), findsOneWidget);

        await tester.pump(duration);
        await future;

        await tester.pumpAndSettle();
      },
    );

    testWithContext('uses custom transition builder', (tester, context) async {
      final future = context.show(
        (_) => Text(text),
        transition: (controller, child) =>
            ScaleTransition(scale: controller, child: child),
        duration: duration,
      );

      await tester.pump(duration);

      expect(find.byType(ScaleTransition), findsOneWidget);

      await tester.pumpAndSettle();
      await future;
    });

    testWithContext('shows background widget', (tester, context) async {
      final future = context.show(
        (_) => Text(text),
        background: (close) => Container(color: Colors.red),
        duration: duration,
      );

      await tester.pump(duration);

      final container = tester.widgetByType<Container>();
      expect(container.color, equals(Colors.red));

      await tester.pumpAndSettle();
      await future;
    });

    testWithContext('uses custom background transition builder', (
      tester,
      context,
    ) async {
      final future = context.show(
        (_) => Text(text),
        background: (_) => Placeholder(),
        backgroundTransition: (controller, child) =>
            ScaleTransition(scale: controller, child: child),
        duration: duration,
      );

      await tester.pump(duration);

      expect(find.byType(ScaleTransition), findsOneWidget);

      await tester.pumpAndSettle();
      await future;
    });

    testWithContext('close() removes overlay', (tester, context) async {
      final future = context.show(
        (controller) => GestureDetector(
          onTap: () => controller.close(),
          child: const Text('Close'),
        ),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsNothing);

      await future;
    });

    testWithContext('close() returns value', (tester, context) async {
      const resultValue = 'Done!';

      final future = context.show<String>(
        (controller) => GestureDetector(
          onTap: () => controller.close(resultValue),
          child: const Text('Return'),
        ),
        duration: Duration.zero,
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Return'));
      await tester.pumpAndSettle();

      expect(find.text('Return'), findsNothing);

      final result = await future;
      expect(result, equals(resultValue));
    });
  });
}
