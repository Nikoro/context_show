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

  group('context.close', () {
    testWithContext('closes last overlay by default', (tester, context) async {
      context.show((_) => const Text('First'), duration: Duration.zero);
      final future =
          context.show((_) => const Text('Second'), duration: Duration.zero);

      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      context.close();
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsNothing);

      await future;

      // Cleanup
      context.close(Overlays.all());
      await tester.pumpAndSettle();
    });

    testWithContext('closes overlay with selector', (tester, context) async {
      final future =
          context.show((_) => const Text('First'), duration: Duration.zero);
      context.show((_) => const Text('Second'), duration: Duration.zero);

      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      context.close(Overlays.first());
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);

      await future;

      // Cleanup
      context.close(Overlays.all());
      await tester.pumpAndSettle();
    });

    testWithContext('closes overlay with result', (tester, context) async {
      const resultValue = 'test_result';
      final future = context.show<String>(
        (_) => const Text('Overlay'),
        duration: Duration.zero,
      );

      await tester.pumpAndSettle();
      expect(find.text('Overlay'), findsOneWidget);

      context.close(resultValue);
      await tester.pumpAndSettle();

      expect(find.text('Overlay'), findsNothing);
      expect(await future, equals(resultValue));
    });

    testWithContext(
      'closes overlay with selector and result',
      (tester, context) async {
        const resultValue = 42;
        final future = context.show<int>((_) => const Text('First'),
            duration: Duration.zero);
        context.show<int>(
          (_) => const Text('Second'),
          duration: Duration.zero,
        );

        await tester.pumpAndSettle();
        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsOneWidget);

        context.close(Overlays.first(), resultValue);
        await tester.pumpAndSettle();
        expect(find.text('First'), findsNothing);
        expect(find.text('Second'), findsOneWidget);
        expect(await future, equals(resultValue));

        // Cleanup
        context.close(Overlays.all());
        await tester.pumpAndSettle();
      },
    );

    testWithContext(
      'closes overlay with swapped parameters (result, selector)',
      (tester, context) async {
        const resultValue = 'swapped';
        final future = context.show<String>(
          (_) => const Text('First'),
          duration: Duration.zero,
        );
        context.show<String>(
          (_) => const Text('Second'),
          duration: Duration.zero,
        );

        await tester.pumpAndSettle();
        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsOneWidget);

        // Pass result first, then selector
        context.close(resultValue, Overlays.first());
        await tester.pumpAndSettle();

        expect(find.text('First'), findsNothing);
        expect(find.text('Second'), findsOneWidget);
        expect(await future, equals(resultValue));

        // Cleanup
        context.close(Overlays.all());
        await tester.pumpAndSettle();
      },
    );

    testWithContext('closes overlay by ID', (tester, context) async {
      final future = context.show(
        (_) => const Text('First'),
        id: 'first',
        duration: Duration.zero,
      );
      context.show(
        (_) => const Text('Second'),
        id: 'second',
        duration: Duration.zero,
      );

      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      context.close(Overlays.first(id: 'first'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
      await future;

      // Cleanup
      context.close(Overlays.all());
      await tester.pumpAndSettle();
    });

    testWithContext('closes all overlays', (tester, context) async {
      context.show(
        (_) => const Text('First'),
        duration: Duration.zero,
      );
      context.show(
        (_) => const Text('Second'),
        duration: Duration.zero,
      );
      context.show(
        (_) => const Text('Third'),
        duration: Duration.zero,
      );

      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);

      context.close(Overlays.all());
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsNothing);
      expect(find.text('Third'), findsNothing);
    });

    testWithContext('closes with custom selector', (tester, context) async {
      final future = context.show(
        (_) => const Text('First'),
        id: 'target',
        duration: Duration.zero,
      );
      context.show(
        (_) => const Text('Second'),
        duration: Duration.zero,
      );

      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      context.close((overlays) => overlays.firstWhere((c) => c.id == 'target'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
      await future;

      // Cleanup
      context.close(Overlays.all());
      await tester.pumpAndSettle();
    });
  });
}
