import 'package:context_show/transition_builders.dart'; // replace with your import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnimationController controller;

  group('TransitionBuilders', () {
    setUp(() => controller = AnimationController(vsync: const TestVSync()));
    tearDown(() => controller.dispose());

    testWidgets('fade returns FadeTransition', (tester) async {
      final widget = TransitionBuilders.fade(controller, const Placeholder());
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('rotation returns RotationTransition', (tester) async {
      final widget = TransitionBuilders.rotation(
        controller,
        const Placeholder(),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(RotationTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('scale returns ScaleTransition', (tester) async {
      final widget = TransitionBuilders.scale(controller, const Placeholder());
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(ScaleTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('size returns SizeTransition', (tester) async {
      final widget = TransitionBuilders.size(controller, const Placeholder());
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(SizeTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('slideFromTop returns SlideTransition', (tester) async {
      final widget = TransitionBuilders.slideFromTop(
        controller,
        const Placeholder(),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('slideFromBottomRight returns SlideTransition', (tester) async {
      final widget = TransitionBuilders.slideFromBottomRight(
        controller,
        const Placeholder(),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('slideFromLeft returns SlideTransition', (tester) async {
      final widget = TransitionBuilders.slideFromLeft(
        controller,
        const Placeholder(),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });

    testWidgets('slideFromRight returns SlideTransition', (tester) async {
      final widget = TransitionBuilders.slideFromRight(
        controller,
        const Placeholder(),
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });
  });
}
