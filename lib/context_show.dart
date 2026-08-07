import 'dart:async';

import 'package:context_show/errors/result_type_mismatch_error.dart';
import 'package:context_show/overlay_closer.dart';
import 'package:context_show/overlay_controller.dart';
import 'package:context_show/overlay_safe_area.dart';
import 'package:context_show/overlays.dart';
import 'package:flutter/material.dart';

export 'package:context_show/extensions.dart';
export 'package:context_show/overlay_closer.dart';
export 'package:context_show/overlay_controller.dart';
export 'package:context_show/overlay_safe_area.dart';
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
  /// The overlay always spans the whole screen — the app bar and status bar
  /// included. [safeArea], [margin] and [backgroundMargin] only decide where
  /// the content is placed inside it:
  ///
  /// - [safeArea] defaults to true, insetting the content so it clears the
  ///   status bar, app bar and bottom bar.
  /// - `safeArea: false` draws edge to edge, over the app bar and status bar.
  /// - [margin] overrides both with an explicit inset, so you can clear the
  ///   status bar but deliberately paint over the app bar.
  ///
  /// [margin] applies to the content and [backgroundMargin] to the
  /// [background], so a full-bleed backdrop can sit under inset content.
  /// `overlay.safeArea` is passed to [builder], letting you apply the insets
  /// yourself — per edge, if you want.
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
    Alignment alignment = Alignment.center,
    Alignment backgroundAlignment = Alignment.center,
    Duration animationDuration = kThemeAnimationDuration,
    bool dismissible = false,
    bool rootOverlay = false,
    Widget Function(OverlayController<T> overlay)? background,
    Widget Function(Widget child)? clipper,
    Widget Function(Widget child)? backgroundClipper,
    Widget Function(AnimationController controller, Widget child)? transition,
    Widget Function(AnimationController controller, Widget child)?
        backgroundTransition,
    bool? safeArea,
    EdgeInsets? margin,
    EdgeInsets? backgroundMargin,
    String? id,
  }) {
    assert(
      !(margin != null && backgroundMargin != null && safeArea != null),
      '⚠️ ContextShow: margin, backgroundMargin, and safeArea were all provided.\n'
      'When both margins are set, the safeArea flag is ignored.\n'
      'To avoid confusion, omit safeArea or one of the margins.',
    );

    safeArea = safeArea ?? true;

    final completer = Completer<T?>();
    final navigator = Navigator.of(this, rootNavigator: rootOverlay);

    late final OverlayEntry entry;
    late final OverlayCloser closer;

    // Latched once the entry is actually on screen. Guards the staleness check
    // below, since an entry reports mounted == false both before it is
    // inserted and after it is torn down.
    var wasMounted = false;

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

      // Play the exit animation only while the entry is still on screen. Once
      // the tree is gone the ticker no longer fires, so awaiting reverse()
      // would never return — leaving the closer registered and the controller
      // undisposed for the rest of the process.
      if (entry.mounted) {
        await controller.reverse();
        if (entry.mounted) entry.remove();
      } else {
        // The vsync's tree may already be gone, in which case the controller
        // is still running its entry animation and would be disposed with an
        // active ticker.
        controller.stop();
      }

      completer.complete(result);
      controller.dispose();
      _closers.remove(closer);
    }

    // The entry is positioned against the overlay it lands in, so the insets
    // have to be measured against that same surface — not against the context
    // show() happened to be called from.
    final overlay = navigator.overlay;
    final overlaySafeArea = OverlaySafeArea.of(
      rootOverlay ? navigator.context : this,
      surface: overlay?.context,
    );
    final overlayController = OverlayController<T>(close, overlaySafeArea);

    Widget backgroundContent =
        background?.call(overlayController) ?? const SizedBox.expand();

    if (background != null) {
      if (backgroundTransition != null) {
        backgroundContent = backgroundTransition(controller, backgroundContent);
      } else {
        backgroundContent = FadeTransition(
          opacity: fade,
          child: backgroundContent,
        );
      }
    }

    backgroundContent = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: dismissible ? close : null,
      child: backgroundContent,
    );

    if (backgroundClipper != null) {
      backgroundContent = backgroundClipper(backgroundContent);
    }

    backgroundMargin = backgroundMargin ??
        (safeArea ? overlaySafeArea.insets : EdgeInsets.zero);

    if (backgroundMargin != EdgeInsets.zero) {
      backgroundContent =
          Padding(padding: backgroundMargin, child: backgroundContent);
    }

    backgroundContent = Align(
      alignment: backgroundAlignment,
      child: backgroundContent,
    );

    Widget content = builder(overlayController);

    if (transition != null) {
      content = transition(controller, content);
    } else {
      content = alignment == Alignment.center
          ? FadeTransition(
              opacity: fade,
              child: content,
            )
          : SlideTransition(
              position: slide,
              child: content,
            );
    }

    if (clipper != null) {
      content = clipper(content);
    }

    margin = margin ?? (safeArea ? overlaySafeArea.insets : EdgeInsets.zero);

    if (margin != EdgeInsets.zero) {
      content = Padding(padding: margin, child: content);
    }

    content = Align(
      alignment: alignment,
      child: content,
    );

    entry = OverlayEntry(
      builder: (context) {
        // Reached only when the Overlay actually builds this entry, which is
        // the evidence the staleness check needs.
        wasMounted = true;
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [backgroundContent, content],
          ),
        );
      },
    );

    closer = OverlayCloser(
      ([Object? result]) => close(result is T ? result : null),
      T,
      id ?? completer.hashCode.toString(),
      // `mounted` only flips true once the Overlay rebuilds, which is a frame
      // after insert(). Treating "not mounted yet" as stale would drop a
      // closer that was created earlier in the same frame, so staleness needs
      // evidence that the entry was live at some point — see `wasMounted`.
      () => wasMounted && !entry.mounted,
    );

    // Drop closers whose overlay was torn down without close() being called —
    // a popped route or a disposed app. Nothing else prunes them, so without
    // this they stay selectable by Overlays.all() for the rest of the process
    // and keep their AnimationController alive.
    _closers.removeWhere((c) => c.isStale());

    _closers.add(closer);

    overlay?.insert(entry);
    controller.forward();
    if (duration > Duration.zero) {
      Future.delayed(duration, close);
    }
    return completer.future;
  }

  /// Closes overlays shown via [show] in this context.
  ///
  /// This method supports flexible parameter ordering and multiple use cases:
  ///
  /// **Default behavior:**
  ///   - If called with no arguments, closes the last overlay.
  ///
  /// **Selectors:**
  ///   - You can pass a selector function to choose which overlay(s) to close.
  ///     The selector receives an iterable of all active [OverlayCloser]s and should
  ///     return either a single [OverlayCloser] or an iterable of them.
  ///     Example:
  ///     ```dart
  ///     // Close all overlays
  ///     context.close((overlays) => overlays);
  ///     // or
  ///     context.close(Overlays.all());
  ///     // Close the first overlay
  ///     context.close((overlays) => overlays.first);
  ///     // or
  ///     context.close(Overlays.first());
  ///     ```
  ///
  /// **Passing results:**
  ///   - You can pass a result to overlays, which will be delivered to their
  ///     completers/futures.
  ///     Example:
  ///     ```dart
  ///     context.close('my result');
  ///     ```
  ///
  /// **Flexible parameter ordering:**
  ///   - You can pass both a selector and a result, in any order:
  ///     - `context.close(selector, result)`
  ///     - `context.close(result, selector)`
  ///     The method will detect which argument is the selector and which is the result.
  ///     Example:
  ///     ```dart
  ///     context.close((overlays) => overlays.first, 'my result');
  ///     context.close('my result', (overlays) => overlays.first);
  ///     // or
  ///     context.close(Overlays.first(), 'my result');
  ///     context.close('my result', Overlays.first());
  ///     ```
  ///
  /// **Common use cases:**
  ///   - Close the last overlay: `context.close();`
  ///   - Close all overlays: `context.close((overlays) => overlays);` or `context.close(Overlays.all());`
  ///   - Close the last overlay with a result: `context.close('result');`
  ///   - Close a specific overlay with a result: `context.close((overlays) => overlays.first, 'result');` or `context.close(Overlays.first(), 'result');`
  ///
  /// Throws [ResultTypeMismatchError] if the result type does not match the expected type.
  Future<void> close(
      [dynamic selectorOrResult, dynamic resultOrSelector]) async {
    if (_closers.isEmpty) return;

    final isFirstSelector =
        selectorOrResult is Function(Iterable<OverlayCloser>);
    final isSecondSelector =
        resultOrSelector is Function(Iterable<OverlayCloser>);

    // Validate that both parameters are not selectors
    if (isFirstSelector && isSecondSelector) {
      throw ArgumentError(
        'Cannot pass two selector functions. Expected (selector, result) or (result, selector).',
      );
    }

    final selector = isFirstSelector
        ? selectorOrResult
        : (isSecondSelector ? resultOrSelector : null);
    final finalResult = isFirstSelector ? resultOrSelector : selectorOrResult;

    final selected = (selector ?? Overlays.last())(List.unmodifiable(_closers));

    final selectedClosers = selected is OverlayCloser
        ? [selected]
        : selected is Iterable<OverlayCloser>
            ? selected
            : throw ArgumentError(
                'Selector must return an OverlayCloser or Iterable<OverlayCloser>',
              );

    for (final closer in selectedClosers) {
      if (!_isTypeCompatible(
          closer.type, finalResult.runtimeType, finalResult)) {
        throw ResultTypeMismatchError(
          id: closer.id,
          expected: closer.type,
          actual: finalResult.runtimeType,
          result: finalResult,
        );
      }
    }
    await selectedClosers.map((closer) => closer.function(finalResult)).wait;
  }

  bool _isTypeCompatible(Type expected, Type actual, Object? result) {
    if (result == null) return true;
    if (expected == dynamic) return true;
    return expected == actual;
  }
}
