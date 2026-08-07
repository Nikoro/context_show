import 'package:context_show/context_show.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Height a real [AppBar] reports when the status bar is [_statusBar] tall:
/// [kToolbarHeight] plus the status bar, which the app bar draws under.
const _statusBar = 100.0;
const _appBar = kToolbarHeight + _statusBar; // 156
const _banner = 'banner';

/// Gives the test view a status bar, so an inset that wrongly falls back to
/// `padding.top` is distinguishable from one that correctly reads the app bar.
/// Without this the status bar is 0 and every broken case looks correct.
void _useStatusBar(WidgetTester tester) {
  tester.view.padding = const FakeViewPadding(top: _statusBar);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<double> _showBannerFrom(
  WidgetTester tester,
  BuildContext context, {
  bool? safeArea,
  EdgeInsets? margin,
}) async {
  context.show(
    (_) => const Text(_banner, textDirection: TextDirection.ltr),
    alignment: Alignment.topCenter,
    duration: Duration.zero,
    safeArea: safeArea,
    margin: margin,
  );
  await tester.pumpAndSettle();
  return tester.getTopLeft(find.text(_banner)).dy;
}

Widget _page({Widget? body, PreferredSizeWidget? appBar, Widget? bottomBar}) =>
    MaterialApp(
      home: Scaffold(
        appBar: appBar,
        body: body ?? const Placeholder(),
        bottomNavigationBar: bottomBar,
      ),
    );

void main() {
  // Group A — drawing over the chrome is a supported, first-class use case.
  // These lock in the escape hatches so a safe-area fix cannot quietly remove
  // the ability to paint over the app bar and status bar.
  group('drawing over the chrome', () {
    testWidgets('safeArea: false spans app bar and status bar', (tester) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));

      expect(await _showBannerFrom(tester, context, safeArea: false), 0);
    });

    testWidgets('the overlay itself always spans the full screen', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));
      await _showBannerFrom(tester, context, safeArea: false);

      // The app bar is inside the overlay's bounds, so content is free to be
      // placed over it — nothing clips at the safe area.
      final overlay = tester.getRect(find.byType(Overlay).last);
      expect(overlay.top, 0);
      expect(tester.getRect(find.byType(AppBar)).bottom, _appBar);
      expect(overlay.bottom, greaterThan(_appBar));
    });

    testWidgets('explicit margin clears the status bar but not the app bar', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));

      final top = await _showBannerFrom(
        tester,
        context,
        margin: const EdgeInsets.only(top: _statusBar),
      );

      expect(top, _statusBar);
      expect(top, lessThan(_appBar), reason: 'deliberately over the app bar');
    });

    testWidgets('safeArea reports the status bar MediaQuery cannot', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));

      // Documents why the README steers users to overlay.safeArea: once an
      // app bar has consumed the padding, building a margin from MediaQuery
      // silently yields zero and the overlay lands at the very top.
      expect(MediaQuery.paddingOf(context).top, 0);
      expect(MediaQuery.viewPaddingOf(context).top, 0);
      expect(OverlaySafeArea.of(context).top, _appBar);
    });

    testWidgets('explicit margin wins over safeArea', (tester) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));

      expect(
        await _showBannerFrom(
          tester,
          context,
          safeArea: true,
          margin: EdgeInsets.zero,
        ),
        0,
      );
    });

    testWidgets('background can be full bleed while content stays inset', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));

      const backdropKey = Key('backdrop');
      context.show(
        (_) => const Text(_banner, textDirection: TextDirection.ltr),
        // Expanded on purpose: the background is placed by an Align, so an
        // unsized child collapses to a point instead of filling the screen.
        background: (_) => const SizedBox.expand(
          child: ColoredBox(key: backdropKey, color: Color(0x55FF0000)),
        ),
        alignment: Alignment.topCenter,
        backgroundMargin: EdgeInsets.zero,
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(backdropKey)).top, 0);
      expect(tester.getTopLeft(find.text(_banner)).dy, _appBar);
    });

    testWidgets('builder receives insets to apply per edge', (tester) async {
      _useStatusBar(tester);
      late OverlaySafeArea captured;
      await tester.pumpWidget(
        _page(
          appBar: AppBar(title: const Text('title')),
          bottomBar: const SizedBox(height: 60),
        ),
      );
      final context = tester.element(find.byType(Placeholder));

      context.show((overlay) {
        captured = overlay.safeArea;
        return const Text(_banner, textDirection: TextDirection.ltr);
      }, safeArea: false, duration: Duration.zero);
      await tester.pumpAndSettle();

      // Available even with safeArea: false — opting out of the automatic
      // margin must not hide the numbers needed to apply it selectively.
      expect(captured.top, _appBar);
      expect(captured.bottom, 60);
    });

    testWidgets('asserts when margins and safeArea are all provided', (
      tester,
    ) async {
      await tester.pumpWidget(_page());
      final context = tester.element(find.byType(Placeholder));

      expect(
        () => context.show(
          (_) => const Text(_banner, textDirection: TextDirection.ltr),
          safeArea: true,
          margin: EdgeInsets.zero,
          backgroundMargin: EdgeInsets.zero,
        ),
        throwsAssertionError,
      );
    });
  });

  // Group B — when safeArea: true is asked for, the inset must be right.
  group('safe area inset resolution', () {
    testWidgets('context inside the body reads the app bar height', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));

      // Exactly the app bar height: the app bar already contains the status
      // bar, so anything adding padding.top on top of it double-counts.
      expect(OverlaySafeArea.of(context).top, _appBar);
    });

    testWidgets('context above the Scaffold still reads the app bar height', (
      tester,
    ) async {
      _useStatusBar(tester);
      late BuildContext above;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              above = context;
              return Scaffold(
                appBar: AppBar(title: const Text('title')),
                body: const Placeholder(),
              );
            },
          ),
        ),
      );

      // Regression test: a page showing a banner from its own build context
      // used to get the status bar only, painting over the back button.
      expect(OverlaySafeArea.of(above).top, _appBar);
      expect(await _showBannerFrom(tester, above), _appBar);
    });

    testWidgets('context above the Scaffold reads the bottom bar height', (
      tester,
    ) async {
      _useStatusBar(tester);
      late BuildContext above;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              above = context;
              return const Scaffold(
                body: Placeholder(),
                bottomNavigationBar: BottomAppBar(),
              );
            },
          ),
        ),
      );

      // A recognised bar type is measured from its widget, so it resolves from
      // above the Scaffold too. An unrecognised one falls back to measuring
      // the body's render box, which only works from inside the body.
      expect(OverlaySafeArea.of(above).bottom, 80);
    });

    testWidgets('an unrecognised bottom bar never reports a negative inset', (
      tester,
    ) async {
      _useStatusBar(tester);
      late BuildContext above;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              above = context;
              return const Scaffold(
                body: Placeholder(),
                bottomNavigationBar: SizedBox(height: 60),
              );
            },
          ),
        ),
      );

      // From above the Scaffold the fallback measures the whole screen, so the
      // subtraction goes negative. Clamped to 0 rather than shifting content
      // off screen with a negative margin.
      expect(OverlaySafeArea.of(above).bottom, 0);
    });

    testWidgets('resolving insets during build does not crash', (tester) async {
      _useStatusBar(tester);
      late double insetDuringBuild;

      // visitChildElements is illegal while the element is building, so the
      // downward search has to bow out instead of throwing. (Inserting the
      // entry itself is still illegal during build — that is a framework rule
      // about markNeedsBuild, not something this package can lift — so this
      // covers the inset lookup, which a builder may legitimately reach.)
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              insetDuringBuild = OverlaySafeArea.of(context).top;
              return Scaffold(
                appBar: AppBar(title: const Text('title')),
                body: const Placeholder(),
              );
            },
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // The downward search is unavailable mid-build, so it falls back to the
      // status bar rather than crashing.
      expect(insetDuringBuild, _statusBar);
    });

    testWidgets('a rebuild scheduled before showing still reads the app bar', (
      tester,
    ) async {
      _useStatusBar(tester);

      // A page that changes state and shows an overlay in the same turn — a
      // dialog flipping a flag, a provider landing — is *dirty* but not
      // building: the rebuild is scheduled, and the previous children are
      // still there to walk. Bowing out here (as the mid-build case above
      // must) costs the app bar height and drops the banner on the status bar.
      late StateSetter markDirty;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              markDirty = setState;
              return Scaffold(
                appBar: AppBar(title: const Text('title')),
                body: const Placeholder(),
              );
            },
          ),
        ),
      );
      final context = tester.element(find.byType(StatefulBuilder));

      markDirty(() {});
      expect(
        context.dirty,
        isTrue,
        reason: 'the regression needs a dirty, not-yet-rebuilt element',
      );

      expect(await _showBannerFrom(tester, context), _appBar);
    });

    testWidgets('nested Scaffolds resolve to the outer chrome', (tester) async {
      _useStatusBar(tester);
      late BuildContext above;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              above = context;
              return Scaffold(
                appBar: AppBar(title: const Text('title')),
                body: const Scaffold(body: Placeholder()),
              );
            },
          ),
        ),
      );

      // The outer Scaffold owns the chrome the overlay appears over, so its
      // app bar is what has to be cleared. The inner, app-bar-less Scaffold
      // reports nothing and must not win.
      expect(OverlaySafeArea.of(above).top, _appBar);
    });

    testWidgets('no Scaffold falls back to the status bar', (tester) async {
      _useStatusBar(tester);
      await tester.pumpWidget(const MaterialApp(home: Placeholder()));
      final context = tester.element(find.byType(Placeholder));

      expect(OverlaySafeArea.of(context).top, _statusBar);
    });

    testWidgets('Scaffold without an app bar falls back to the status bar', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(_page());
      final context = tester.element(find.byType(Placeholder));

      expect(OverlaySafeArea.of(context).top, _statusBar);
    });

    testWidgets('a nested Overlay below the app bar is not cleared twice', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('title')),
            body: Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute<void>(builder: (_) => const Placeholder()),
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(Placeholder));

      // The nested Navigator's overlay already starts below the app bar, so
      // its own origin clears the chrome. Adding the screen-measured inset on
      // top of that would drop the banner a second app bar's worth down.
      expect(tester.getRect(find.byType(Overlay).last).top, _appBar);
      expect(await _showBannerFrom(tester, context), _appBar);
    });

    testWidgets('a root Overlay still gets the full inset', (tester) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        _page(appBar: AppBar(title: const Text('title'))),
      );
      final context = tester.element(find.byType(Placeholder));

      // Guard for the surface adjustment: the root overlay starts at the top
      // of the screen, so nothing may be subtracted here.
      expect(tester.getRect(find.byType(Overlay).last).top, 0);
      expect(await _showBannerFrom(tester, context), _appBar);
    });

    testWidgets('the bottom inset is measured against the surface too', (
      tester,
    ) async {
      _useStatusBar(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: const BottomAppBar(),
            body: Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute<void>(builder: (_) => const Placeholder()),
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(Placeholder));

      context.show(
        (overlay) => Text(
          '${overlay.safeArea.bottom}',
          textDirection: TextDirection.ltr,
        ),
        duration: Duration.zero,
      );
      await tester.pumpAndSettle();

      // The nested overlay already ends above the bottom bar, so the inset it
      // reports must not include that bar a second time.
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('an app bar taller than the toolbar is followed', (
      tester,
    ) async {
      _useStatusBar(tester);
      const tabBar = TabBar(tabs: [Tab(text: 'a'), Tab(text: 'b')]);
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(title: const Text('title'), bottom: tabBar),
              body: const Placeholder(),
            ),
          ),
        ),
      );
      final context = tester.element(find.byType(Placeholder));

      final inset = OverlaySafeArea.of(context).top;
      expect(inset, greaterThan(_appBar));
      expect(inset, _appBar + tabBar.preferredSize.height);
    });
  });
}
