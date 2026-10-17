import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/providers/app_preferences_provider.dart';
import 'package:flick/services/app_preferences_service.dart';
import 'package:flick/services/display_mode_service.dart';
import 'package:flick/widgets/common/display_mode_controller.dart';

class _LoadingPreferencesService extends AppPreferencesService {
  final completion = Completer<AppPreferences>();

  @override
  Future<AppPreferences> getPreferences() => completion.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_display_mode');
  final calls = <int>[];
  late int activeId;
  late int preferredId;

  void pauseApp(WidgetTester tester) {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  }

  void resumeApp(WidgetTester tester) {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    final service = DisplayModeService();
    service.debugReset();
    service.verificationDelay = Duration.zero;
    activeId = 1;
    preferredId = 0;
    const autoMode = {'id': 0, 'width': 0, 'height': 0, 'refreshRate': 0.0};
    const mode60 = {
      'id': 1,
      'width': 1080,
      'height': 2400,
      'refreshRate': 60.0,
    };
    const mode120 = {
      'id': 2,
      'width': 1080,
      'height': 2400,
      'refreshRate': 120.0,
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'getSupportedModes':
              return const [mode60, mode120];
            case 'getActiveMode':
              return activeId == 2 ? mode120 : mode60;
            case 'getPreferredMode':
              if (preferredId == 0) return autoMode;
              return preferredId == 2 ? mode120 : mode60;
            case 'setPreferredMode':
              final id = (call.arguments as Map)['mode'] as int;
              calls.add(id);
              preferredId = id;
              activeId = id == 0 ? 1 : id;
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    DisplayModeService().debugReset();
  });

  testWidgets('applies a refresh-rate change without waiting for a screen', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DisplayModeController(child: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    expect(calls, [
      0,
    ], reason: 'a fresh install clears forced modes and follows the system');

    await container
        .read(appPreferencesProvider.notifier)
        .setRefreshRateMode(DisplayModeService.standard);
    await tester.pumpAndSettle();

    expect(calls, [0, 1]);
  });

  testWidgets('applies a stored forced mode after preferences load', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_completed': true,
      'app_refresh_rate_mode': 'high',
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DisplayModeController(child: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();

    expect(calls, [2]);
  });

  for (final mode in {'high': 2, 'standard': 1, 'adaptive': 0}.entries) {
    testWidgets('restores preloaded ${mode.key} on controller mount', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'app_refresh_rate_mode': mode.key,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appPreferencesProvider);
      await tester.runAsync(() => pumpEventQueue());
      expect(container.read(appPreferencesProvider).refreshRateMode, mode.key);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DisplayModeController(child: SizedBox()),
        ),
      );
      await tester.pumpAndSettle();

      expect(calls, [mode.value]);
    });
  }

  testWidgets('waits for saved preferences before applying any mode', (
    tester,
  ) async {
    final service = _LoadingPreferencesService();
    final container = ProviderContainer(
      overrides: [appPreferencesServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DisplayModeController(child: SizedBox()),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(calls, isEmpty);

    service.completion.complete(
      const AppPreferences(refreshRateMode: DisplayModeService.high),
    );
    await tester.pumpAndSettle();

    expect(calls, [2]);
  });

  testWidgets(
    'reopening a window restores the saved rate without data changes',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'app_refresh_rate_mode': 'high',
        'app_haptics_enabled': false,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DisplayModeController(child: SizedBox()),
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, [2]);

      pauseApp(tester);
      // Android creates a new window, but the cached Dart engine and its last
      // requested mode survive.
      activeId = 1;
      preferredId = 0;
      resumeApp(tester);
      await tester.pumpAndSettle();

      expect(calls, [2, 2]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_refresh_rate_mode'), 'high');
      expect(prefs.getBool('app_haptics_enabled'), isFalse);
      expect(prefs.getBool('onboarding_completed'), isTrue);
    },
  );

  testWidgets('closing before verification does not suppress the saved mode', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_refresh_rate_mode': 'high'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final service = DisplayModeService();
    service.verificationDelay = const Duration(milliseconds: 1500);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DisplayModeController(child: SizedBox()),
      ),
    );
    await tester.pump();
    expect(calls, [2]);

    try {
      pauseApp(tester);
      activeId = 1;
      preferredId = 0;
      await tester.pump(const Duration(seconds: 2));
      expect(calls, [2], reason: 'a background 60 Hz reading is not rejection');
    } finally {
      service.verificationDelay = Duration.zero;
      resumeApp(tester);
      await tester.pumpAndSettle();
    }

    expect(calls, [2, 2]);
  });

  testWidgets('preference changes in the background apply on resume', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_refresh_rate_mode': 'high'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DisplayModeController(child: SizedBox()),
      ),
    );
    await tester.pumpAndSettle();
    expect(calls, [2]);

    try {
      pauseApp(tester);
      await container
          .read(appPreferencesProvider.notifier)
          .setRefreshRateMode(DisplayModeService.standard);
      await tester.pump();
      expect(calls, [2]);
    } finally {
      resumeApp(tester);
      await tester.pumpAndSettle();
    }

    expect(calls, [2, 1]);
  });
}
