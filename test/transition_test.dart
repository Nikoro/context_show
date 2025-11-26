import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:context_show/transition.dart';

void main() {
  late AnimationController controller;
  final child = const Placeholder();

  group('Transition', () {
    setUp(() => controller = AnimationController(vsync: TestVSync()));
    tearDown(() => controller.dispose());

    testWidgets('fade produces FadeTransition', (tester) async {
      final transition = Transition.fade();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: transition(controller, child),
      ));
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('rotation produces RotationTransition', (tester) async {
      final transition = Transition.rotation();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: transition(controller, child),
      ));
      expect(find.byType(RotationTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('scale produces ScaleTransition', (tester) async {
      final transition = Transition.scale();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: transition(controller, child),
      ));
      expect(find.byType(ScaleTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('slideFromTop produces SlideTransition', (tester) async {
      final transition = Transition.slideFromTop();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: transition(controller, child),
      ));
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('and chains multiple transitions', (tester) async {
      final transition = Transition.fade().and(Transition.rotation());
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: transition(controller, child),
      ));
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(RotationTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('all slideFrom variants produce SlideTransition', (
      tester,
    ) async {
      final variants = [
        Transition.slideFromTop(),
        Transition.slideFromTopLeft(),
        Transition.slideFromTopRight(),
        Transition.slideFromBottom(),
        Transition.slideFromBottomLeft(),
        Transition.slideFromBottomRight(),
        Transition.slideFromLeft(),
        Transition.slideFromRight(),
      ];

      for (final t in variants) {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: t(controller, child),
        ));
        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.byType(Placeholder), findsOneWidget);
      }
    });

    testWidgets('call applies transitions in reverse order', (tester) async {
      final transition = Transition.fade().and(Transition.scale());
      final result = transition(controller, child);
      expect(result, isA<FadeTransition>());
      final fade = result as FadeTransition;
      expect(fade.child, isA<ScaleTransition>());
      final scale = fade.child as ScaleTransition;
      expect(scale.child, equals(child));
    });

    testWidgets('fade extension chains correctly', (tester) async {
      final transition = Transition.scale().fade();
      final result = transition(controller, child);
      expect(result, isA<ScaleTransition>());
      final scale = result as ScaleTransition;
      expect(scale.child, isA<FadeTransition>());
      final fade = scale.child as FadeTransition;
      expect(fade.child, equals(child));
    });

    testWidgets('rotation extension chains correctly', (tester) async {
      final transition = Transition.fade().rotation();
      final result = transition(controller, child);
      expect(result, isA<FadeTransition>());
      final fade = result as FadeTransition;
      expect(fade.child, isA<RotationTransition>());
      final rotation = fade.child as RotationTransition;
      expect(rotation.child, equals(child));
    });

    testWidgets('multiple extension chaining works', (tester) async {
      final transition = Transition.rotation().fade().scale().slideFromTop();
      final result = transition(controller, child);
      expect(result, isA<RotationTransition>());
      final rotation = result as RotationTransition;
      expect(rotation.child, isA<FadeTransition>());
      final fade = rotation.child as FadeTransition;
      expect(fade.child, isA<ScaleTransition>());
      final scale = fade.child as ScaleTransition;
      expect(scale.child, isA<SlideTransition>());
      final slide = scale.child as SlideTransition;
      expect(slide.child, equals(child));
    });
  });
}
