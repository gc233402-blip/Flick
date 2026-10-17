import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flick/services/display_mode_service.dart';

/// One resolution across all fakes; refresh rates vary to model panels with
/// low-power modes alongside the usual 60/120 Hz modes (see issue #210).
const int _width = 1080;
const int _height = 2400;

Map<String, Object> _mode(int id, double refreshRate) => {
  'id': id,
  'width': _width,
  'height': _height,
  'refreshRate': refreshRate,
};

final List<Map<String, Object>> _lowPowerModes = [
  _mode(1, 10),
  _mode(2, 30),
  _mode(3, 60),
  _mode(4, 120),
];

const Map<String, Object> _autoMode = {
  'id': 0,
  'width': 0,
  'height': 0,
  'refreshRate': 0.0,
};

/// Fake of the `flutter_display_mode` platform channel.
///
/// With [rejectForcedModes] a non-zero mode request is acknowledged but the
/// active mode never changes. With [settleForcedToId] the request is accepted
/// but the panel settles on another mode, mirroring firmware that drops into a
/// low-power state after a forced request.
class _FakeDisplay {
  _FakeDisplay({List<Map<String, Object>>? modes, this.initialActiveId = 1})
    : modes = modes ?? [_mode(1, 60), _mode(2, 120)];

  final List<Map<String, Object>> modes;
  final int initialActiveId;
  final List<int> setPreferredCalls = [];

  bool rejectForcedModes = false;
  int? settleForcedToId;

  late int _activeId = initialActiveId;
  int _preferredId = 0;

  void recreateWindow() {
    _activeId = initialActiveId;
    _preferredId = 0;
  }

  Map<String, Object> _modeById(int id) {
    if (id == 0) return _autoMode;
    return modes.firstWhere((mode) => mode['id'] == id);
  }

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'getSupportedModes':
        return modes;
      case 'getActiveMode':
        return _modeById(_activeId);
      case 'getPreferredMode':
        return _modeById(_preferredId);
      case 'setPreferredMode':
        final id = (call.arguments as Map)['mode'] as int;
        setPreferredCalls.add(id);
        _preferredId = id;
        if (id == 0) {
          _activeId = initialActiveId;
        } else if (!rejectForcedModes) {
          _activeId = settleForcedToId ?? id;
        }
        return null;
      default:
        return null;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_display_mode');
  late _FakeDisplay fake;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    fake = _FakeDisplay();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) => fake.handle(call));
    final service = DisplayModeService();
    service.debugReset();
    service.verificationDelay = Duration.zero;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    DisplayModeService().debugReset();
  });

  test(
    'high requests the highest refresh rate at the current resolution',
    () async {
      final service = DisplayModeService();
      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'preference',
      );
      expect(fake.setPreferredCalls, [2]);

      await pumpEventQueue();
      expect(fake.setPreferredCalls, [
        2,
      ], reason: 'an accepted mode is not requested again');

      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'resume',
      );
      expect(fake.setPreferredCalls, [2], reason: 'a repeat resume is skipped');
    },
  );

  test(
    'restores the forced mode when a new window loses the old request',
    () async {
      final service = DisplayModeService();
      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'preference',
      );
      await pumpEventQueue();

      fake.recreateWindow();
      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'resume',
      );
      await pumpEventQueue();

      expect(fake.setPreferredCalls, [2, 2]);
    },
  );

  test(
    'backgrounding cancels verification without suppressing a later restore',
    () async {
      fake.rejectForcedModes = true;
      final service = DisplayModeService();
      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'preference',
      );
      service.setForeground(false);
      await pumpEventQueue();
      expect(fake.setPreferredCalls, [2]);

      await service.applyRefreshRateMode(
        DisplayModeService.standard,
        reason: 'resume',
      );
      expect(fake.setPreferredCalls, [2]);

      fake.rejectForcedModes = false;
      fake.recreateWindow();
      service.setForeground(true);
      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'resume',
      );
      await pumpEventQueue();
      expect(fake.setPreferredCalls, [2, 2]);
    },
  );

  test('standard targets 60 Hz instead of the lowest low-power mode', () async {
    fake = _FakeDisplay(modes: _lowPowerModes, initialActiveId: 2);
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.standard,
      reason: 'preference',
    );

    expect(fake.setPreferredCalls, [3]);
    await pumpEventQueue();
    expect(fake.setPreferredCalls, [3]);
  });

  test('standard accepts a 59.94 Hz mode as 60 Hz', () async {
    fake = _FakeDisplay(
      modes: [_mode(1, 30), _mode(2, 59.94), _mode(3, 120)],
      initialActiveId: 1,
    );
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.standard,
      reason: 'preference',
    );

    expect(fake.setPreferredCalls, [2]);
    await pumpEventQueue();
  });

  test('standard follows the system when no 60 Hz mode exists', () async {
    fake = _FakeDisplay(
      modes: [_mode(1, 10), _mode(2, 30), _mode(3, 120)],
      initialActiveId: 2,
    );
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.standard,
      reason: 'preference',
    );

    expect(fake.setPreferredCalls, [
      0,
    ], reason: 'the lowest mode is never used as a 60 Hz substitute');
  });

  test('adaptive clears the forced mode instead of requesting one', () async {
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.adaptive,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [0]);

    await service.applyRefreshRateMode(
      DisplayModeService.adaptive,
      reason: 'resume',
    );
    expect(fake.setPreferredCalls, [0], reason: 'already auto is skipped');
  });

  test(
    'a rejected forced mode falls back to auto and stays suppressed',
    () async {
      fake.rejectForcedModes = true;
      final service = DisplayModeService();
      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'preference',
      );
      expect(fake.setPreferredCalls, [2]);

      await pumpEventQueue();
      expect(fake.setPreferredCalls, [
        2,
        0,
      ], reason: 'the rejected request is followed by a reset to auto');

      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'resume',
      );
      await pumpEventQueue();
      expect(fake.setPreferredCalls, [
        2,
        0,
      ], reason: 'automatic applies stop forcing after a rejection');
    },
  );

  test('a forced mode that settles on a low-power rate is reverted', () async {
    fake = _FakeDisplay(modes: _lowPowerModes, initialActiveId: 3);
    fake.settleForcedToId = 2;
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [4]);

    await pumpEventQueue();
    expect(fake.setPreferredCalls, [
      4,
      0,
    ], reason: 'firmware that drops to 30 Hz is reverted to auto');

    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'resume',
    );
    expect(fake.setPreferredCalls, [4, 0]);
  });

  test(
    'an explicit preference change still attempts forcing when suppressed',
    () async {
      fake.rejectForcedModes = true;
      final service = DisplayModeService();
      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'preference',
      );
      await pumpEventQueue();
      expect(fake.setPreferredCalls, [2, 0]);

      await service.applyRefreshRateMode(
        DisplayModeService.high,
        reason: 'preference',
      );
      expect(fake.setPreferredCalls, [2, 0, 2]);
      await pumpEventQueue();
    },
  );

  test('rapid changes do not trigger a stale fallback', () async {
    fake = _FakeDisplay(modes: _lowPowerModes, initialActiveId: 3);
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.standard,
      reason: 'preference',
    );
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, [3, 4]);

    await pumpEventQueue();
    expect(fake.setPreferredCalls, [
      3,
      4,
    ], reason: 'the superseded verification must not revert');
  });

  test('a superseded mode lookup cannot overwrite a newer selection', () async {
    final lookup = Completer<void>();
    var delayFirstLookup = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getSupportedModes' && delayFirstLookup) {
            delayFirstLookup = false;
            await lookup.future;
          }
          return fake.handle(call);
        });

    final service = DisplayModeService();
    final outdated = service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    await pumpEventQueue();
    try {
      await service.applyRefreshRateMode(
        DisplayModeService.standard,
        reason: 'preference',
      );
    } finally {
      lookup.complete();
      await outdated;
    }
    await pumpEventQueue();

    expect(fake.setPreferredCalls, [1]);
  });

  test('a successful explicit retry can be restored on later reopening', () async {
    final service = DisplayModeService();
    fake.rejectForcedModes = true;
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    await pumpEventQueue();
    expect(fake.setPreferredCalls, [2, 0]);

    fake.rejectForcedModes = false;
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    await pumpEventQueue();
    fake.recreateWindow();
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'resume',
    );
    await pumpEventQueue();

    expect(fake.setPreferredCalls, [2, 0, 2, 2]);
  });

  test('an unknown mode falls back to the high behaviour', () async {
    final service = DisplayModeService();
    await service.applyRefreshRateMode('bogus', reason: 'preference');
    expect(fake.setPreferredCalls, [2]);
    await pumpEventQueue();
  });

  test('does nothing on non-Android platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final service = DisplayModeService();
    await service.applyRefreshRateMode(
      DisplayModeService.high,
      reason: 'preference',
    );
    expect(fake.setPreferredCalls, isEmpty);
  });
}
