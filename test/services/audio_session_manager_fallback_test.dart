import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/audio_engine_type.dart';
import 'package:flick/services/audio_session_manager.dart';
import 'package:flick/services/uac2_preferences_service.dart';

void main() {
  group('resolveBluetoothPreferredMode', () {
    test('honors the Rust engine preference with both toggles off', () {
      expect(
        resolveBluetoothPreferredMode(
          enginePreference: AudioEnginePreference.rustOboe,
          lowLatencyEnabled: false,
          hiResDirectEnabled: false,
        ),
        AudioEngineType.rustOboe,
      );
    });

    test('keeps ExoPlayer for the default preference', () {
      expect(
        resolveBluetoothPreferredMode(
          enginePreference: AudioEnginePreference.exoPlayer,
          lowLatencyEnabled: false,
          hiResDirectEnabled: false,
        ),
        AudioEngineType.normalAndroid,
      );
    });

    test('keeps ExoPlayer for the isochronous USB preference', () {
      expect(
        resolveBluetoothPreferredMode(
          enginePreference: AudioEnginePreference.isochronousUsb,
          lowLatencyEnabled: false,
          hiResDirectEnabled: false,
        ),
        AudioEngineType.normalAndroid,
      );
    });

    test('low-latency mode selects the Rust engine regardless of preference', () {
      expect(
        resolveBluetoothPreferredMode(
          enginePreference: AudioEnginePreference.exoPlayer,
          lowLatencyEnabled: true,
          hiResDirectEnabled: false,
        ),
        AudioEngineType.rustOboe,
      );
    });

    test('Hi-Res Direct selects the Rust engine regardless of preference', () {
      expect(
        resolveBluetoothPreferredMode(
          enginePreference: AudioEnginePreference.exoPlayer,
          lowLatencyEnabled: false,
          hiResDirectEnabled: true,
        ),
        AudioEngineType.rustOboe,
      );
    });
  });

  test(
    'Rust fallback remains identifiable while Standard is initialized',
    () async {
      final manager = AudioSessionManager(
        onSwitchEngine:
            ({
              required from,
              required to,
              required initializeNewEngine,
              required reason,
            }) async {},
        isPlaybackActive: () => true,
      );
      addTearDown(manager.dispose);

      await manager.switchMode(
        AudioEngineType.rustOboe,
        initializeNewEngine: true,
      );
      await manager.recordFallback(
        requestedMode: AudioEngineType.rustOboe,
        fallbackMode: AudioEngineType.normalAndroid,
        reason: 'Rust output lost during crossfade',
      );
      await manager.switchMode(
        AudioEngineType.normalAndroid,
        initializeNewEngine: true,
      );
      expect(manager.selectedMode, AudioEngineType.normalAndroid);
      expect(manager.initializedMode, AudioEngineType.normalAndroid);
      expect(manager.fallbackRequestedMode, AudioEngineType.rustOboe);
      expect(manager.fallbackReason, contains('Rust output lost'));

      await manager.switchMode(
        AudioEngineType.rustOboe,
        initializeNewEngine: true,
      );
      expect(manager.initializedMode, AudioEngineType.rustOboe);
      expect(manager.fallbackRequestedMode, isNull);
      expect(manager.fallbackReason, isNull);
    },
  );

  test(
    'failed Rust switch does not report disposed Standard engine as ready',
    () async {
      final manager = AudioSessionManager(
        onSwitchEngine:
            ({
              required from,
              required to,
              required initializeNewEngine,
              required reason,
            }) async {
              if (to == AudioEngineType.rustOboe) {
                throw StateError('Oboe could not open');
              }
            },
        isPlaybackActive: () => true,
      );
      addTearDown(manager.dispose);

      await manager.switchMode(
        AudioEngineType.normalAndroid,
        initializeNewEngine: true,
      );
      await expectLater(
        manager.switchMode(AudioEngineType.rustOboe, initializeNewEngine: true),
        throwsStateError,
      );
      expect(manager.initializedMode, isNull);
      await manager.switchMode(
        AudioEngineType.normalAndroid,
        initializeNewEngine: true,
      );
      expect(manager.initializedMode, AudioEngineType.normalAndroid);
    },
  );
}
