import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/app_theme.dart';
import 'package:flick/widgets/common/flick_snackbar.dart';

Future<GlobalKey<ScaffoldMessengerState>> _host(
  WidgetTester tester, {
  MediaQueryData mediaQuery = const MediaQueryData(),
  GlobalKey<NavigatorState>? navigatorKey,
  double? clearance,
}) async {
  final key = GlobalKey<ScaffoldMessengerState>();
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(
    MediaQuery(
      data: mediaQuery.copyWith(size: const Size(400, 800)),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        scaffoldMessengerKey: key,
        navigatorKey: navigatorKey,
        home: SnackBarTheme(
          data: AppTheme.darkTheme.snackBarTheme.copyWith(
            insetPadding: clearance == null
                ? null
                : EdgeInsets.fromLTRB(16, 8, 16, clearance),
          ),
          child: const Scaffold(body: SizedBox.expand()),
        ),
      ),
    ),
  );
  return key;
}

SnackBar _message(
  String text, {
  Duration duration = const Duration(seconds: 2),
}) => SnackBar(content: Text(text), duration: duration);

Future<void> _enter(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 281));
}

Future<void> _replace(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 201));
  await _enter(tester);
}

// Measure the transition around the actual Material surface, not merely the
// messenger's controller. A long controller can still produce a near-instant
// visible fade when the native snackbar applies its own interval curve.
double _surfaceOpacity(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(SnackBar),
            matching: find.byType(FadeTransition),
          )
          .first,
    )
    .opacity
    .value;

void main() {
  setUp(() => AppConstants.setAnimationsEnabled(true));
  tearDown(() => AppConstants.setAnimationsEnabled(true));

  testWidgets(
    'the whole surface fades and rises over 280ms, exits over 200ms',
    (tester) async {
      final host = await _host(tester, clearance: 162);
      host.currentState!.showFlickSnackBar(_message('Saved'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));
      expect(_surfaceOpacity(tester), closeTo(0.25, 0.01));
      final enteringTop = tester.getTopLeft(find.text('Saved')).dy;
      final enteringHeight = tester.getSize(find.byType(SnackBar)).height;
      await tester.pump(const Duration(milliseconds: 70));
      expect(_surfaceOpacity(tester), closeTo(0.5, 0.01));
      final midpointTop = tester.getTopLeft(find.text('Saved')).dy;
      expect(midpointTop, lessThan(enteringTop));
      await tester.pump(const Duration(milliseconds: 70));
      expect(_surfaceOpacity(tester), closeTo(0.75, 0.01));
      await tester.pump(const Duration(milliseconds: 71));
      expect(_surfaceOpacity(tester), 1);
      expect(tester.getTopLeft(find.text('Saved')).dy, lessThan(midpointTop));
      expect(tester.getSize(find.byType(SnackBar)).height, enteringHeight);
      host.currentState!.hideFlickSnackBar();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(_surfaceOpacity(tester), closeTo(0.75, 0.01));
      await tester.pump(const Duration(milliseconds: 50));
      expect(_surfaceOpacity(tester), closeTo(0.5, 0.01));
      await tester.pump(const Duration(milliseconds: 50));
      expect(_surfaceOpacity(tester), closeTo(0.25, 0.01));
      await tester.pump(const Duration(milliseconds: 51));
      expect(find.text('Saved'), findsNothing);
    },
  );

  testWidgets('replacement during entry reverses without flashing opaque', (
    tester,
  ) async {
    final host = await _host(tester);
    host.currentState!.showFlickSnackBar(_message('First'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    expect(_surfaceOpacity(tester), closeTo(0.25, 0.01));
    host.currentState!.showFlickSnackBar(_message('Next'));
    await tester.pump();
    expect(_surfaceOpacity(tester), closeTo(0.25, 0.01));
    await tester.pump(const Duration(milliseconds: 25));
    expect(_surfaceOpacity(tester), closeTo(0.125, 0.01));
    await tester.pump(const Duration(milliseconds: 26));
    await tester.pump();
    expect(find.text('First'), findsNothing);
    expect(find.text('Next'), findsOneWidget);
    expect(_surfaceOpacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 140));
    expect(_surfaceOpacity(tester), closeTo(0.5, 0.01));
  });

  testWidgets('duplicate text refreshes its timer without re-entry', (
    tester,
  ) async {
    final host = await _host(tester);
    var visibleCount = 0;
    host.currentState!.showFlickSnackBar(
      SnackBar(
        content: const Text('Saved'),
        duration: const Duration(seconds: 2),
        onVisible: () => visibleCount++,
      ),
    );
    await _enter(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    host.currentState!.showFlickSnackBar(_message('Saved'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Saved'), findsOneWidget);
    expect(visibleCount, 1);
    expect(_surfaceOpacity(tester), 1);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 201));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('a rapid burst keeps only the latest routine message', (
    tester,
  ) async {
    final host = await _host(tester);
    host.currentState!.showFlickSnackBar(_message('First'));
    await _enter(tester);
    host.currentState!.showFlickSnackBar(_message('Stale'));
    host.currentState!.showFlickSnackBar(_message('Latest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Latest'), findsNothing);
    await tester.pump(const Duration(milliseconds: 101));
    await _enter(tester);
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('Stale'), findsNothing);
  });

  testWidgets('Undo survives routine feedback and retains its callback', (
    tester,
  ) async {
    final host = await _host(tester);
    var undone = false;
    host.currentState!.showFlickSnackBar(
      SnackBar(
        content: const Text('Removed'),
        action: SnackBarAction(label: 'Undo', onPressed: () => undone = true),
      ),
    );
    await _enter(tester);
    host.currentState!.showFlickSnackBar(_message('Stale'));
    host.currentState!.showFlickSnackBar(_message('Latest'));
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Latest'), findsNothing);
    await tester.tap(find.text('Undo'));
    await _replace(tester);
    expect(undone, isTrue);
    expect(find.text('Latest'), findsOneWidget);
  });

  testWidgets('queued actions are not coalesced with routine messages', (
    tester,
  ) async {
    final host = await _host(tester);
    for (final name in ['First', 'Second']) {
      host.currentState!.showFlickSnackBar(
        SnackBar(
          content: Text(name),
          action: SnackBarAction(label: 'Undo $name', onPressed: () {}),
        ),
      );
    }
    host.currentState!.showFlickSnackBar(_message('Latest'));
    await _enter(tester);
    await tester.tap(find.text('Undo First'));
    await _replace(tester);
    expect(find.text('Undo Second'), findsOneWidget);
    await tester.tap(find.text('Undo Second'));
    await _replace(tester);
    expect(find.text('Latest'), findsOneWidget);
  });

  testWidgets('targeted status dismissal leaves unrelated Undo untouched', (
    tester,
  ) async {
    final host = await _host(tester);
    host.currentState!.showFlickSnackBar(
      SnackBar(
        content: const Text('Removed'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
    await _enter(tester);
    host.currentState!.showFlickSnackBar(
      const SnackBar(content: Text('Working'), duration: Duration(days: 1)),
      id: 'warmup',
    );
    host.currentState!.hideFlickSnackBar(id: 'warmup');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await _replace(tester);
    expect(find.text('Working'), findsNothing);
  });

  testWidgets('named status updates replace only that status', (tester) async {
    final host = await _host(tester);
    host.currentState!.showFlickSnackBar(
      const SnackBar(content: Text('Working 1'), duration: Duration(days: 1)),
      id: 'warmup',
    );
    await _enter(tester);
    host.currentState!.showFlickSnackBar(
      const SnackBar(content: Text('Working 2'), duration: Duration(days: 1)),
      id: 'warmup',
    );
    await _replace(tester);
    expect(find.text('Working 1'), findsNothing);
    expect(find.text('Working 2'), findsOneWidget);
    host.currentState!.hideFlickSnackBar(id: 'warmup');
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('swiping a notice dismisses it and advances the queue', (
    tester,
  ) async {
    final host = await _host(tester);
    host.currentState!.showFlickSnackBar(
      SnackBar(
        content: const Text('Removed'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
    await _enter(tester);
    host.currentState!.showFlickSnackBar(_message('Next'));
    await tester.drag(find.byType(SnackBar), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Remove animations and the app preference skip motion', (
    tester,
  ) async {
    final host = await _host(
      tester,
      mediaQuery: const MediaQueryData(disableAnimations: true),
    );
    host.currentState!.showFlickSnackBar(_message('System'));
    await tester.pump();
    expect(_surfaceOpacity(tester), 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
    final preferenceHost = await _host(tester);
    AppConstants.setAnimationsEnabled(false);
    preferenceHost.currentState!.showFlickSnackBar(_message('Preference'));
    await tester.pump();
    expect(_surfaceOpacity(tester), 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('backgrounding pauses the lifetime until resumed', (
    tester,
  ) async {
    final host = await _host(tester);
    host.currentState!.showFlickSnackBar(_message('Saved'));
    await _enter(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Saved'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 201));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets(
    'screen-reader feedback has more reading time and a live region',
    (tester) async {
      final host = await _host(
        tester,
        mediaQuery: const MediaQueryData(accessibleNavigation: true),
      );
      final semantics = tester.ensureSemantics();
      host.currentState!.showFlickSnackBar(_message('Saved'));
      await _enter(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Saved'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.liveRegion == true,
        ),
        findsWidgets,
      );
      semantics.dispose();
    },
  );

  testWidgets('keyboard, RTL and large multiline text retain safe layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    final host = await _host(
      tester,
      mediaQuery: const MediaQueryData(
        viewInsets: EdgeInsets.only(bottom: 280),
        padding: EdgeInsets.only(bottom: 24),
        textScaler: TextScaler.linear(2),
      ),
      clearance: 100,
    );
    host.currentState!.showFlickSnackBar(
      const SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text('تم حفظ التغييرات بنجاح. يمكنك متابعة الاستماع الآن.'),
        ),
      ),
    );
    await _enter(tester);
    expect(tester.takeException(), isNull);
    expect(
      tester.getRect(find.byType(SnackBar)).bottom,
      lessThanOrEqualTo(520),
    );
  });

  testWidgets('route transitions keep feedback alive without duplicate keys', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final host = await _host(tester, navigatorKey: navigator);
    host.currentState!.showFlickSnackBar(_message('Saved'));
    await _enter(tester);
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Detail')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Saved'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 201));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('disposing the host cancels timers and pending feedback', (
    tester,
  ) async {
    final host = await _host(tester);
    host.currentState!.showFlickSnackBar(_message('First'));
    await _enter(tester);
    host.currentState!.showFlickSnackBar(_message('Next'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
  });
}
