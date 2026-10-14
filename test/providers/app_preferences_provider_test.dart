import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/providers/app_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Replay widgets default to Acid when no look was chosen', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(appPreferencesProvider).widgetReplayLook, 'acid');
    await pumpEventQueue();
    expect(container.read(appPreferencesProvider).widgetReplayLook, 'acid');
    expect(
      await container.read(appPreferencesServiceProvider).getWidgetReplayLook(),
      'acid',
    );
  });

  for (final look in ['night', 'signal', 'artwork', 'acid']) {
    test('Replay widgets preserve a saved $look selection', () async {
      SharedPreferences.setMockInitialValues({'widget_replay_look': look});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appPreferencesProvider);
      await pumpEventQueue();
      expect(container.read(appPreferencesProvider).widgetReplayLook, look);
    });
  }

  test('Replay Acid selection persists after changing from Night', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(appPreferencesProvider);
    await pumpEventQueue();
    final notifier = container.read(appPreferencesProvider.notifier);
    await notifier.setWidgetReplayLook('night');
    await notifier.setWidgetReplayLook('acid');
    final restored = ProviderContainer();
    addTearDown(restored.dispose);
    restored.read(appPreferencesProvider);
    await pumpEventQueue();
    expect(restored.read(appPreferencesProvider).widgetReplayLook, 'acid');
  });

  test(
    'visualizer colors default to album art on existing installations',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(appPreferencesProvider).visualizerColorMode,
        'album_art',
      );
      await pumpEventQueue();
      expect(
        container.read(appPreferencesProvider).visualizerColorMode,
        'album_art',
      );
    },
  );

  test(
    'visualizer colors persist independently of shape and movement',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appPreferencesProvider);
      await pumpEventQueue();
      final notifier = container.read(appPreferencesProvider.notifier);
      await notifier.setVisualizerAnimationStyle('blocks');
      await notifier.setVisualizerFrequencyMode('bass');
      await notifier.setVisualizerMovementMode('smooth');

      for (final mode in ['rainbow', 'monochrome', 'album_art']) {
        await notifier.setVisualizerColorMode(mode);
        final restored = ProviderContainer();
        restored.read(appPreferencesProvider);
        await pumpEventQueue();
        final preferences = restored.read(appPreferencesProvider);
        expect(preferences.visualizerColorMode, mode);
        expect(preferences.visualizerAnimationStyle, 'blocks');
        expect(preferences.visualizerFrequencyMode, 'bass');
        expect(preferences.visualizerMovementMode, 'smooth');
        restored.dispose();
      }
    },
  );

  test(
    'connection notices default to enabled for existing installations',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(appPreferencesProvider).connectionNoticesEnabled,
        isTrue,
      );
      await pumpEventQueue();
      expect(
        container.read(appPreferencesProvider).connectionNoticesEnabled,
        isTrue,
      );
    },
  );

  test(
    'connection notice preference survives a new provider container',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(appPreferencesProvider);
      await pumpEventQueue();
      await container
          .read(appPreferencesProvider.notifier)
          .setConnectionNoticesEnabled(false);
      expect(
        container.read(appPreferencesProvider).connectionNoticesEnabled,
        isFalse,
      );

      final restored = ProviderContainer();
      addTearDown(restored.dispose);
      restored.read(appPreferencesProvider);
      await pumpEventQueue();
      expect(
        restored.read(appPreferencesProvider).connectionNoticesEnabled,
        isFalse,
      );
      await restored
          .read(appPreferencesProvider.notifier)
          .setConnectionNoticesEnabled(true);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('app_connection_notices_enabled'), isTrue);
    },
  );

  test('refresh rate defaults to adaptive on new installations', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(appPreferencesProvider);
    await pumpEventQueue();
    expect(container.read(appPreferencesProvider).refreshRateMode, 'adaptive');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_refresh_rate_mode'), 'adaptive');
  });

  test('refresh rate keeps the previous default on existing installations', () async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(appPreferencesProvider);
    await pumpEventQueue();
    expect(container.read(appPreferencesProvider).refreshRateMode, 'high');
  });
}
