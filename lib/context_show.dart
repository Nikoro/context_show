import 'dart:async';

import 'package:context_show/errors/result_type_mismatch_error.dart';
import 'package:context_show/overlay_closer.dart';
import 'package:context_show/overlay_controller.dart';
import 'package:context_show/overlay_safe_area.dart';
import 'package:context_show/overlays.dart';
import 'package:flutter/material.dart';

export 'package:context_show/extensions.dart';
export 'package:context_show/overlays.dart';
export 'package:context_show/transition.dart';
export 'package:context_show/transition_builders.dart';

final _closers = <OverlayCloser>[];

/// An extension on [BuildContext] that provides methods to show and close
/// overlays.
extension ContextShow on BuildContext {
  /// Shows an overlay with the given [builder].
  ///
  /// The overlay is built within a [Material] widget, so you can use widgets
  /// like [Card] and [ListTile] without any extra setup.
  ///
  /// The [builder] is a function that takes an [OverlayController] and returns
  /// a widget. The [OverlayController] can be used to close the overlay and
  /// provides a [SafeArea] that respects the app bar and bottom navigation bar.
  ///
  /// The [duration] is the amount of time the overlay will be shown. If it's
  /// [Duration.zero], the overlay will not be closed automatically.
  ///
  /// The [alignment] determines where the overlay is shown.
  ///
  /// The [animationDuration] is the duration of the show and close animations.
  ///
  /// The [background] is an optional widget that is shown behind the overlay.
  ///
  /// The [transition] is an optional function that builds the transition
  /// for the overlay. See [Transition] for more details.
  ///
  /// The [backgroundTransition] is an optional function that builds the
  /// transition for the background. See [Transition] for more details.
  ///
  /// If [dismissible] is true, the overlay can be dismissed by tapping the
  /// background.
  ///
  /// If [fullScreen] is true, the overlay will be shown in full screen,
  /// ignoring the safe area.
  ///
  /// The [id] is an optional identifier for the overlay. It can be used to
  /// close a specific overlay.
  ///
  /// Example:
  ///
  /// ```dart
  /// context.show(
  ///   (controller) => Card(
  ///     child: ListTile(
  ///       title: const Text('Hello'),
  ///       onTap: () => controller.close('world'),
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<T?> show<T>(
    Widget Function(OverlayController<T> overlay) builder, {
    Duration duration = const Duration(milliseconds: 4000),
    Alignment alignment = Alignment.bottomCenter,
    Duration animationDuration = kThemeAnimationDuration,
    Widget Function(OverlayController<T> overlay)? background,
    Widget Function(AnimationController controller, Widget child)? transition,
    Widget Function(AnimationController controller, Widget child)?
        backgroundTransition,
    bool dismissible = false,
    bool fullScreen = false,
    String? id,
  }) {
    final completer = Completer<T?>();
    final navigator = Navigator.of(this, rootNavigator: fullScreen);

    late final OverlayEntry entry;
    late final OverlayCloser closer;

    final controller = AnimationController(
      vsync: navigator,
      duration: animationDuration,
      reverseDuration: animationDuration,
    );

    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween(
      begin: Offset(alignment.x, alignment.y),
      end: Offset.zero,
    ).animate(fade);

    Future<void> close([T? result]) async {
      if (completer.isCompleted) return;
      await controller.reverse();
      if (entry.mounted) entry.remove();
      completer.complete(result);
      controller.dispose();
      _closers.remove(closer);
    }

    final overlaySafeArea = OverlaySafeArea.fromContext(this);
    final overlayController = OverlayController<T>(close, overlaySafeArea);

    entry = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Padding(
          padding:
              fullScreen ? EdgeInsetsGeometry.zero : overlaySafeArea.insets,
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: dismissible ? close : null,
                child: background != null
                    ? backgroundTransition != null
                        ? backgroundTransition(
                            controller,
                            background(overlayController),
                          )
                        : FadeTransition(
                            opacity: fade,
                            child: background(overlayController),
                          )
                    : const SizedBox.expand(),
              ),
              Align(
                alignment: alignment,
                child: transition != null
                    ? transition(controller, builder(overlayController))
                    : alignment == Alignment.center
                        ? FadeTransition(
                            opacity: fade,
                            child: builder(overlayController),
                          )
                        : SlideTransition(
                            position: slide,
                            child: builder(overlayController),
                          ),
              ),
            ],
          ),
        ),
      ),
    );

    closer = OverlayCloser(
      ([Object? result]) => close(result is T ? result : null),
      T,
      id ?? completer.hashCode.toString(),
    );
    _closers.add(closer);

    navigator.overlay?.insert(entry);
    controller.forward();
    if (duration > Duration.zero) {
      Future.delayed(duration, close);
    }
    return completer.future;
  }

  Future<void> close([
    dynamic Function(Iterable<OverlayCloser> overlays)? selector,
    Object? result,
  ]) async {
    if (_closers.isEmpty) return;

    final selected = (selector ?? Overlays.last())(List.unmodifiable(_closers));

    final selectedClosers = selected is OverlayCloser
        ? [selected]
        : selected is Iterable<OverlayCloser>
            ? selected
            : throw ArgumentError(
                'Selector must return an OverlayCloser or Iterable<OverlayCloser>',
              );

    for (final closer in selectedClosers) {
      if (!_isTypeCompatible(closer.type, result.runtimeType, result)) {
        throw ResultTypeMismatchError(
          id: closer.id,
          expected: closer.type,
          actual: result.runtimeType,
          result: result,
        );
      }
    }
    await selectedClosers.map((closer) => closer.function(result)).wait;
  }

  bool _isTypeCompatible(Type expected, Type actual, Object? result) {
    if (result == null) return true;
    if (expected == dynamic) return true;
    return expected == actual;
  }
}
