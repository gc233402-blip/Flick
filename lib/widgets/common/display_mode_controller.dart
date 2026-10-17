import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flick/core/utils/dev_log.dart';
import 'package:flick/providers/app_preferences_provider.dart';
import 'package:flick/services/display_mode_service.dart';

/// Applies the refresh-rate preference for the whole app.
///
/// The preference used to be applied by a wrapper on every screen, which meant
/// a change made in Settings had no effect until a wrapped screen mounted and
/// that many screens kept poking the display driver. Applying it here also
/// keeps the mode in sync after the stored preference finishes loading and
/// when the app returns to the foreground.
class DisplayModeController extends ConsumerStatefulWidget {
  final Widget child;

  const DisplayModeController({super.key, required this.child});

  @override
  ConsumerState<DisplayModeController> createState() =>
      _DisplayModeControllerState();
}

class _DisplayModeControllerState extends ConsumerState<DisplayModeController>
    with WidgetsBindingObserver {
  final DisplayModeService _displayModeService = DisplayModeService();
  bool _preferencesLoaded = false;

  bool get _isForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _displayModeService.setForeground(_isForeground);
    ref.listenManual<String>(
      appPreferencesProvider.select(
        (preferences) => preferences.refreshRateMode,
      ),
      (previous, next) {
        if (!_preferencesLoaded || !_isForeground || previous == next) return;
        _applyRefreshRate(next, 'preference');
      },
    );
    _restoreRefreshRate();
  }

  Future<void> _restoreRefreshRate() async {
    try {
      // A change-only listener misses a stored value that loaded before this
      // controller mounted, including when a cached engine recreates its UI.
      await ref.read(appPreferencesProvider.notifier).loaded;
      if (!mounted) return;
      _preferencesLoaded = true;
      if (!_isForeground) return;
      await _applyRefreshRate(
        ref.read(appPreferencesProvider).refreshRateMode,
        'startup',
      );
    } catch (e) {
      devLog('DisplayMode[controller]: failed to restore refresh rate: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _displayModeService.setForeground(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _displayModeService.setForeground(state == AppLifecycleState.resumed);
    if (state != AppLifecycleState.resumed || !_preferencesLoaded) return;
    _applyRefreshRate(
      ref.read(appPreferencesProvider).refreshRateMode,
      'resume',
    );
  }

  Future<void> _applyRefreshRate(String mode, String reason) async {
    devLog('DisplayMode[controller]: apply refreshRateMode=$mode ($reason)');
    await _displayModeService.applyRefreshRateMode(mode, reason: reason);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
