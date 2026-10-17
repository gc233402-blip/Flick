import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flick/core/utils/dev_log.dart';

/// Applies the user's refresh-rate preference to the current window.
///
/// The preference values mirror the `refreshRateMode` app preference:
///  * `adaptive` — leave the mode to the system (no preferred mode set);
///  * `standard` — request the advertised mode closest to 60 Hz at the
///    current resolution;
///  * `high` — request the highest refresh rate at the current resolution.
///
/// `standard` deliberately avoids the lowest advertised rate: panels with
/// 10/20/30 Hz low-power modes would otherwise cap at 10 Hz. When no mode
/// within 5 Hz of 60 Hz exists, the system keeps control instead.
///
/// Forced modes are verified shortly after they are requested. Some firmware
/// acknowledges the request and then drops the panel into a low-power state
/// (reported on the Fairphone 6, see moss-apps/Flick#210); when the active
/// mode does not match the request the service falls back to `auto` and stops
/// forcing for the rest of the session, so later screens and resumes do not
/// keep poking the display driver.
class DisplayModeService {
  /// Preference value: follow the system refresh rate.
  static const String adaptive = 'adaptive';

  /// Preference value: prefer 60 Hz at the current resolution.
  static const String standard = 'standard';

  /// Preference value: prefer the highest refresh rate at the current
  /// resolution.
  static const String high = 'high';

  static final DisplayModeService _instance = DisplayModeService._internal();
  factory DisplayModeService() => _instance;
  DisplayModeService._internal();

  List<DisplayMode> _availableModes = [];
  DisplayMode? _currentMode;
  DisplayMode? _preferredMode;

  List<DisplayMode> get availableModes => _availableModes;
  DisplayMode? get currentMode => _currentMode;
  DisplayMode? get preferredMode => _preferredMode;

  bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

  /// How long to wait before checking that a forced mode was accepted.
  @visibleForTesting
  Duration verificationDelay = const Duration(milliseconds: 1500);

  /// Last requested mode. The current window's preference must still match
  /// before skipping: Android can recreate a window without restarting Dart.
  int? _lastRequestedModeId;

  /// True once a forced mode was rejected. Automatic applies then leave the
  /// system alone until the app restarts or the user picks a mode explicitly.
  bool _forceSuppressed = false;

  /// Invalidates a pending verification when a newer request takes over.
  int _verificationToken = 0;
  Timer? _verificationTimer;
  bool _isForeground = true;

  /// Background/closing windows can run at a lower rate without rejecting the
  /// preference. Only verify requests while the app is in the foreground.
  void setForeground(bool isForeground) {
    _isForeground = isForeground;
    if (!isForeground) _cancelVerification();
  }

  void _cancelVerification() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
    _verificationToken++;
  }

  bool _isCurrentRequest(int token) =>
      token == _verificationToken && _isForeground && isSupported;

  static String _describe(DisplayMode? mode) {
    if (mode == null) return 'unknown';
    if (mode.id == 0) return 'auto';
    return '#${mode.id} ${mode.width}x${mode.height}@${mode.refreshRate}Hz';
  }

  Future<void> _logState(String tag) async {
    try {
      _currentMode = await FlutterDisplayMode.active;
      _preferredMode = await FlutterDisplayMode.preferred;
    } catch (e) {
      devLog('DisplayMode[$tag]: failed to read state: $e');
      return;
    }
    devLog(
      'DisplayMode[$tag]: active=${_describe(_currentMode)} '
      'preferred=${_describe(_preferredMode)}',
    );
  }

  Future<void> initialize() async {
    if (!isSupported) return;
    try {
      _availableModes = await FlutterDisplayMode.supported;
      _currentMode = await FlutterDisplayMode.active;
      _preferredMode = await FlutterDisplayMode.preferred;
      devLog(
        'DisplayMode[init]: supported='
        '${_availableModes.map(_describe).join(', ')}',
      );
      devLog(
        'DisplayMode[init]: active=${_describe(_currentMode)} '
        'preferred=${_describe(_preferredMode)}',
      );
    } catch (e) {
      devLog('Failed to initialize display modes: $e');
    }
  }

  /// Applies the refresh-rate [mode] preference.
  ///
  /// [reason] is used for logging and to distinguish automatic applies
  /// ('startup', 'resume') from an explicit user selection ('preference').
  Future<void> applyRefreshRateMode(
    String mode, {
    String reason = 'apply',
  }) async {
    if (!isSupported || !_isForeground) return;

    _cancelVerification();
    final token = _verificationToken;

    final requested = await _resolveTargetMode(mode);
    if (requested == null || !_isCurrentRequest(token)) return;

    final isForced = requested.id != DisplayMode.auto.id;
    if (reason == 'preference') _forceSuppressed = false;
    if (isForced && _forceSuppressed && reason != 'preference') {
      devLog(
        'DisplayMode[apply]: forced modes suppressed for this session, '
        'skipping $mode ($reason)',
      );
      return;
    }

    final alreadyPreferred = await _hasCurrentRequest(requested);
    if (!_isCurrentRequest(token)) return;
    if (alreadyPreferred) {
      devLog(
        'DisplayMode[apply]: ${_describe(requested)} already preferred by '
        'the current window, '
        'skipping ($reason)',
      );
      if (isForced) _scheduleVerification(requested, token);
      return;
    }

    try {
      await FlutterDisplayMode.setPreferredMode(requested);
    } catch (e) {
      devLog('DisplayMode[apply]: failed to set ${_describe(requested)}: $e');
      return;
    }
    if (!_isCurrentRequest(token)) return;
    _lastRequestedModeId = requested.id;
    await _logState('apply $mode ($reason)');
    if (isForced && _isCurrentRequest(token)) {
      _scheduleVerification(requested, token);
    }
  }

  Future<bool> _hasCurrentRequest(DisplayMode requested) async {
    if (_lastRequestedModeId != requested.id) return false;
    try {
      _preferredMode = await FlutterDisplayMode.preferred;
      return _preferredMode?.id == requested.id;
    } catch (e) {
      devLog('DisplayMode[apply]: failed to check the current window: $e');
      return false;
    }
  }

  /// Clears any forced display mode so the system decides again.
  Future<void> resetToAuto({String reason = 'resetAuto'}) =>
      applyRefreshRateMode(adaptive, reason: reason);

  /// The refresh rate that the `standard` preference aims for.
  static const double _standardRefreshRate = 60;

  /// How far a mode may be from [_standardRefreshRate] and still count as
  /// "60 Hz" (covers panels that report 59.94 Hz).
  static const double _standardTolerance = 5;

  /// Picks the platform mode matching [mode] at the current resolution.
  Future<DisplayMode?> _resolveTargetMode(String mode) async {
    if (mode == adaptive) return DisplayMode.auto;

    var effectiveMode = mode;
    if (effectiveMode != standard && effectiveMode != high) {
      devLog(
        'DisplayMode[apply]: unknown refreshRateMode "$mode", '
        'falling back to $high',
      );
      effectiveMode = high;
    }

    try {
      final modes = await FlutterDisplayMode.supported;
      final active = await FlutterDisplayMode.active;
      if (effectiveMode == standard) {
        return _closestToStandard(active, modes);
      }

      var target = active;
      for (final candidate in modes) {
        if (candidate.width != active.width ||
            candidate.height != active.height) {
          continue;
        }
        if (candidate.refreshRate > target.refreshRate) {
          target = candidate;
        }
      }
      return target;
    } catch (e) {
      devLog('DisplayMode[apply]: failed to resolve the $mode mode: $e');
      return null;
    }
  }

  /// Returns the mode closest to 60 Hz at [active]'s resolution, or `auto`
  /// when the panel has no such mode.
  DisplayMode _closestToStandard(DisplayMode active, List<DisplayMode> modes) {
    DisplayMode? best;
    var bestDistance = double.infinity;
    for (final candidate in modes) {
      if (candidate.width != active.width ||
          candidate.height != active.height) {
        continue;
      }
      final distance = (candidate.refreshRate - _standardRefreshRate).abs();
      if (distance <= _standardTolerance && distance < bestDistance) {
        best = candidate;
        bestDistance = distance;
      }
    }
    if (best == null) {
      devLog(
        'DisplayMode[resolve]: no mode within '
        '${_standardTolerance.toStringAsFixed(0)} Hz of '
        '${_standardRefreshRate.toStringAsFixed(0)} Hz at '
        '${active.width}x${active.height}; following the system',
      );
      return DisplayMode.auto;
    }
    return best;
  }

  void _scheduleVerification(DisplayMode requested, int token) {
    _verificationTimer = Timer(verificationDelay, () async {
      _verificationTimer = null;
      if (!_isCurrentRequest(token)) return;
      final DisplayMode active;
      try {
        active = await FlutterDisplayMode.active;
      } catch (e) {
        devLog('DisplayMode[verify]: failed to read the active mode: $e');
        return;
      }
      if (!_isCurrentRequest(token)) return;
      _currentMode = active;
      if (active.id == requested.id) {
        devLog('DisplayMode[verify]: ${_describe(requested)} is active');
        return;
      }
      devLog(
        'DisplayMode[verify]: requested ${_describe(requested)} but '
        '${_describe(active)} is active; reverting to auto and suppressing '
        'forced modes for this session',
      );
      _forceSuppressed = true;
      await resetToAuto(reason: 'verifyFallback');
    });
  }

  /// Clears session state; call between tests.
  @visibleForTesting
  void debugReset() {
    _cancelVerification();
    _availableModes = [];
    _currentMode = null;
    _preferredMode = null;
    _lastRequestedModeId = null;
    _forceSuppressed = false;
    _isForeground = true;
    verificationDelay = const Duration(milliseconds: 1500);
  }

  DisplayMode? get highestRefreshRateMode {
    if (_availableModes.isEmpty) return null;
    return _availableModes.reduce(
      (a, b) => a.refreshRate > b.refreshRate ? a : b,
    );
  }

  DisplayMode? get highestResolutionMode {
    if (_availableModes.isEmpty) return null;
    return _availableModes.reduce((a, b) {
      final aPixels = (a.width * a.height);
      final bPixels = (b.width * b.height);
      return aPixels > bPixels ? a : b;
    });
  }

  DisplayMode? get optimalMode {
    if (_availableModes.isEmpty) return null;
    return _availableModes.reduce((a, b) {
      final aScore = a.refreshRate * (a.width * a.height);
      final bScore = b.refreshRate * (b.width * b.height);
      return aScore > bScore ? a : b;
    });
  }
}
