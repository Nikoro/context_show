import 'package:flutter/material.dart';

/// A utility class that provides a set of transition builders.
///
/// It can be used to create custom transitions for the overlay.
///
/// See also:
/// - [Transition], which uses these builders to create transitions.
abstract class TransitionBuilders {
  const TransitionBuilders._();

  /// A transition that fades the child in and out.
  static Widget fade(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeInOut,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: curve),
      child: child,
    );
  }

  /// A transition that rotates the child.
  static Widget rotation(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeInOut,
  }) {
    return RotationTransition(
      turns: CurvedAnimation(parent: controller, curve: curve),
      child: child,
    );
  }

  /// A transition that scales the child.
  static Widget scale(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeInOut,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: controller, curve: curve),
      child: child,
    );
  }

  /// A transition that animates the size of the child.
  static Widget size(
    AnimationController controller,
    Widget child, {
    Axis axis = Axis.vertical,
    Curve curve = Curves.easeInOut,
    double axisAlignment = 0.0,
    double? fixedCrossAxisSizeFactor,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: controller, curve: curve),
      axis: axis,
      axisAlignment: axisAlignment,
      fixedCrossAxisSizeFactor: fixedCrossAxisSizeFactor,
      child: child,
    );
  }

  /// A transition that slides the child from the top.
  static Widget slideFromTop(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.topCenter,
    );
  }

  /// A transition that slides the child from the top left.
  static Widget slideFromTopLeft(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.topLeft,
    );
  }

  /// A transition that slides the child from the top right.
  static Widget slideFromTopRight(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.topRight,
    );
  }

  /// A transition that slides the child from the bottom.
  static Widget slideFromBottom(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.bottomCenter,
    );
  }

  /// A transition that slides the child from the bottom left.
  static Widget slideFromBottomLeft(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.bottomLeft,
    );
  }

  /// A transition that slides the child from the bottom right.
  static Widget slideFromBottomRight(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.bottomRight,
    );
  }

  /// A transition that slides the child from the left.
  static Widget slideFromLeft(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.centerLeft,
    );
  }

  /// A transition that slides the child from the right.
  static Widget slideFromRight(
    AnimationController controller,
    Widget child, {
    Curve curve = Curves.easeOut,
  }) {
    return _slideFrom(
      controller,
      child,
      curve: curve,
      alignment: Alignment.centerRight,
    );
  }

  static Widget _slideFrom(
    AnimationController controller,
    Widget child, {
    required Alignment alignment,
    Curve curve = Curves.easeOut,
  }) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: Offset(alignment.x, alignment.y),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: curve)),
        child: child,
      );
}
