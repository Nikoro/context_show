import 'package:context_show/context_show.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts the closers currently registered, by selecting them all and closing
/// none of them.
int _registered(BuildContext context) {
  var count = 0;
  context.close((overlays) {
    count = overlays.length;
    return const <OverlayCloser>[];
  });
  return count;
}

Future<BuildContext> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Placeholder()));
  return tester.element(find.byType(Placeholder));
}

void main() {
  group('closer lifecycle', () {
    testWidgets('a closer is registered while its overlay is open', (
      tester,
    ) async {
      final context = await _pumpApp(tester);
      context.show(
        (_) => const Text('a', textDirection: TextDirection.ltr),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      expect(_registered(context), 1);
    });

    testWidgets('closing removes the closer', (tester) async {
      final context = await _pumpApp(tester);
      context.show(
        (_) => const Text('a', textDirection: TextDirection.ltr),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      // Not awaited: close() drives the exit animation, which only advances
      // while the test clock is pumped. Awaiting it here would deadlock.
      context.close();
      await tester.pumpAndSettle();

      expect(_registered(context), 0);
    });

    testWidgets('closing a torn-down overlay does not hang', (tester) async {
      final context = await _pumpApp(tester);
      context.show(
        (_) => const Text('doomed', textDirection: TextDirection.ltr),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      // Destroy the app outright, so the Overlay itself goes away.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      final next = await _pumpApp(tester);

      // The exit animation cannot run without a ticker, so close() has to skip
      // it. Awaiting with no pumping at all would otherwise never return.
      await next.close(Overlays.all());

      expect(_registered(next), 0);
    });

    testWidgets('a stale closer is pruned by the next show', (tester) async {
      final context = await _pumpApp(tester);
      context.show(
        (_) => const Text('doomed', textDirection: TextDirection.ltr),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      final next = await _pumpApp(tester);
      expect(_registered(next), 1, reason: 'stale closer still lingers');

      next.show(
        (_) => const Text('fresh', textDirection: TextDirection.ltr),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      // Only the live one survives — the dead one was dropped, not counted.
      expect(_registered(next), 1);

      next.close();
      await tester.pumpAndSettle();
      expect(find.text('fresh'), findsNothing);
      expect(_registered(next), 0);
    });

    testWidgets('an overlay outliving its route is not treated as stale', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('home')),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Placeholder()),
        ),
      );
      await tester.pumpAndSettle();

      tester.element(find.byType(Placeholder)).show(
            (_) => const Text('banner', textDirection: TextDirection.ltr),
            duration: Duration.zero,
          );
      await tester.pumpAndSettle();

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      // Routes are entries in the one root Overlay, not Overlays of their own,
      // so an overlay shown from a page deliberately outlives it. Callers that
      // want it gone call close() themselves.
      expect(find.text('banner'), findsOneWidget);

      final home = tester.element(find.text('home'));
      home.show(
        (_) => const Text('second', textDirection: TextDirection.ltr),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      // Pruning must not mistake the survivor for a dead closer.
      expect(find.text('banner'), findsOneWidget);
      expect(_registered(home), 2);
    });

    testWidgets('auto-dismiss cleans up even after the tree is gone', (
      tester,
    ) async {
      final context = await _pumpApp(tester);
      context.show(
        (_) => const Text('toast', textDirection: TextDirection.ltr),
        duration: const Duration(seconds: 1),
      );

      // Settle first: a controller still animating when its vsync is disposed
      // trips Flutter's own "disposed with an active Ticker" assert, which
      // happens for a bare AnimationController too and is not something this
      // package can intercept.
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final next = await _pumpApp(tester);
      expect(_registered(next), 0);
    });
  });
}
