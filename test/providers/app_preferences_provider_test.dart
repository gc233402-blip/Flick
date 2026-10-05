import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/providers/app_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

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
}
