import 'package:flutter/material.dart';

import 'transition_builders.dart';

/// An extension that provides a set of transition methods on a [Transition].
///
/// It can be used to chain transitions together.
extension TransitionExtensions on Transition {
  /// Chains a fade transition.
  Transition fade({Curve curve = Curves.easeInOut}) =>
      and(Transition.fade(curve: curve));

  /// Chains a rotation transition.
  Transition rotation({Curve curve = Curves.easeInOut}) =>
      and(Transition.rotation(curve: curve));

  /// Chains a scale transition.
  Transition scale({Curve curve = Curves.easeInOut}) =>
      and(Transition.scale(curve: curve));

  /// Chains a slide from top transition.
  Transition slideFromTop({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromTop(curve: curve));

  /// Chains a slide from top left transition.
  Transition slideFromTopLeft({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromTopLeft(curve: curve));

  /// Chains a slide from top right transition.
  Transition slideFromTopRight({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromTopRight(curve: curve));

  /// Chains a slide from bottom transition.
  Transition slideFromBottom({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromBottom(curve: curve));

  /// Chains a slide from bottom left transition.
  Transition slideFromBottomLeft({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromBottomLeft(curve: curve));

  /// Chains a slide from bottom right transition.
  Transition slideFromBottomRight({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromBottomRight(curve: curve));

  /// Chains a slide from left transition.
  Transition slideFromLeft({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromLeft(curve: curve));

  /// Chains a slide from right transition.
  Transition slideFromRight({Curve curve = Curves.easeOut}) =>
      and(Transition.slideFromRight(curve: curve));
}

/// A class that represents a transition.
///
/// It can be used to create custom transitions for the overlay.
///
/// It can be chained with other transitions using the [and] method or the
/// extension methods.
///
/// Example:
///
/// ```dart
/// context.show(
///   (_) => const Text('Hello'),
///   transition: Transition.fade().and(Transition.scale()),
/// );
/// ```
///
/// or
///
/// ```dart
/// context.show(
///   (_) => const Text('Hello'),
///   transition: Transition.fade().scale(),
/// );
/// ```
class Transition {
  const Transition._(this._transitions);

  final List<Widget Function(AnimationController, Widget)> _transitions;

  /// A transition that fades the child in and out.
  factory Transition.fade({Curve curve = Curves.easeInOut}) => Transition._([
        (controller, child) =>
            TransitionBuilders.fade(controller, child, curve: curve),
      ]);

  /// A transition that rotates the child.
  factory Transition.rotation({Curve curve = Curves.easeInOut}) =>
      Transition._([
        (controller, child) =>
            TransitionBuilders.rotation(controller, child, curve: curve),
      ]);

  /// A transition that scales the child.
  factory Transition.scale({Curve curve = Curves.easeInOut}) => Transition._([
        (controller, child) =>
            TransitionBuilders.scale(controller, child, curve: curve),
      ]);

  /// A transition that slides the child from the top.
  factory Transition.slideFromTop({Curve curve = Curves.easeOut}) =>
      Transition._([
        (controller, child) =>
            TransitionBuilders.slideFromTop(controller, child, curve: curve),
      ]);

  /// A transition that slides the child from the top left.
  factory Transition.slideFromTopLeft({Curve curve = Curves.easeOut}) =>
      Transition._([
        (controller, child) => TransitionBuilders.slideFromTopLeft(
              controller,
              child,
              curve: curve,
            ),
      ]);

  /// A transition that slides the child from the top right.
  factory Transition.slideFromTopRight({Curve curve = Curves.easeOut}) =>
      Transition._([
        (controller, child) => TransitionBuilders.slideFromTopRight(
              controller,
              child,
              curve: curve,
            ),
      ]);

  /// A transition that slides the child from the bottom.
  factory Transition.slideFromBottom({Curve curve = Curves.easeOut}) =>
      Transition._([
        (controller, child) =>
            TransitionBuilders.slideFromBottom(controller, child, curve: curve),
      ]);

  /// A transition that slides the child from the bottom left.
  factory Transition.slideFromBottomLeft({Curve curve = Curves.easeOut}) =>
      Transition._([
        (controller, child) => TransitionBuilders.slideFromBottomLeft(
              controller,
              child,
              curve: curve,
            ),
      ]);

  /// A transition that slides the child from the bottom right.
  factory Transition.slideFromBottomRight({Curve curve = Curves.easeOut}) =>
      Transition._([
        (controller, child) => TransitionBuilders.slideFromBottomRight(
              controller,
              child,
              curve: curve,
            ),
      ]);

  /// A transition that slides the child from the left.
  factory Transition.slideFromLeft({Curve curve = Curves.easeOut}) =>
      Transition._from(TransitionBuilders.slideFromLeft, curve);

  /// A transition that slides the child from the right.
  factory Transition.slideFromRight({Curve curve = Curves.easeOut}) =>
      Transition._from(TransitionBuilders.slideFromRight, curve);

  static Transition _from(
    Widget Function(AnimationController, Widget, {Curve curve}) builder,
    Curve curve,
  ) =>
      Transition._([
        (controller, child) => builder(controller, child, curve: curve),
      ]);

  /// Chains another transition to this transition.
  Transition and(Transition other) =>
      Transition._([..._transitions, ...other._transitions]);

  /// Builds the transition.
  Widget call(AnimationController controller, Widget child) {
    Widget current = child;
    for (final t in _transitions.reversed) {
      current = t(controller, current);
    }
    return current;
  }
}
