import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import 'package:flick/core/utils/dev_log.dart';

class WidgetIntentHandler {
  WidgetIntentHandler(
    this._ref, {
    VoidCallback? onOpenQueue,
    VoidCallback? onOpenRecap,
  }) : _onOpenQueue = onOpenQueue,
       _onOpenRecap = onOpenRecap;

  final WidgetRef _ref;
  final VoidCallback? _onOpenQueue;
  final VoidCallback? _onOpenRecap;
  MethodChannel? _channel;
  int _generation = 0;

  Future<void> attach() async {
    await detach();

    final generation = ++_generation;
    _channel = const MethodChannel('com.mossapps.flick/widget');
    _channel!.setMethodCallHandler((call) async {
      if (generation != _generation) return;
      if (call.method == 'dispatch') {
        final uriStr = call.arguments as String?;
        if (uriStr != null) {
          final uri = Uri.tryParse(uriStr);
          if (uri != null) _dispatch(uri);
        }
      } else if (call.method == 'channelReady') {
        await _drainInitialWidgetUri(generation);
      }
    });

    if (await _drainInitialWidgetUri(generation)) return;
    if (generation != _generation) return;
    // Compatibility for launch intents created by the home_widget plugin.
    // Flick's custom WIDGET_LAUNCH action is drained by the native handshake.
    final launchUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (generation == _generation && launchUri != null) {
      _dispatch(launchUri);
    }
  }

  Future<bool> _drainInitialWidgetUri(int generation) async {
    try {
      final raw = await _channel?.invokeMethod<String>('widgetHandlerReady');
      if (generation != _generation || raw == null) return false;
      final uri = Uri.tryParse(raw);
      if (uri == null) return false;
      _dispatch(uri);
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      devLog('WidgetIntentHandler: launch handshake failed: $e');
      return false;
    }
  }

  Future<void> detach() async {
    ++_generation;
    final channel = _channel;
    _channel = null;
    channel?.setMethodCallHandler(null);
    if (channel == null) return;
    try {
      await channel.invokeMethod<void>('widgetHandlerDetached');
    } on MissingPluginException {
      // The Activity/channel can already be gone during app disposal.
    } on PlatformException catch (e) {
      devLog('WidgetIntentHandler: detach failed: $e');
    }
  }

  void _dispatch(Uri? uri) {
    if (uri == null || uri.scheme != 'flickwidget') return;
    try {
      final segments = uri.pathSegments;
      if (uri.host == 'player') {
        _handlePlayer(segments.isEmpty ? '' : segments.first);
      } else if (uri.host == 'queue' && uri.path == '/open') {
        _onOpenQueue?.call();
      } else if (uri.host == 'recap' && uri.path == '/open') {
        _onOpenRecap?.call();
      } else {
        devLog('WidgetIntentHandler: unknown host ${uri.host}');
      }
    } catch (e, st) {
      devLog('WidgetIntentHandler dispatch error: $e\n$st');
    }
  }

  void _handlePlayer(String action) {
    if (action == 'open' || action.isEmpty) return;
    final notifier = _ref.read(playerProvider.notifier);
    switch (action) {
      case 'play_pause':
        unawaited(notifier.togglePlayPause().then((_) => _pushWidgetState()));
        break;
      case 'next':
        unawaited(notifier.next().then((_) => _pushWidgetState()));
        break;
      case 'previous':
        unawaited(notifier.previous().then((_) => _pushWidgetState()));
        break;
      case 'shuffle':
        unawaited(notifier.toggleShuffle().then((_) => _pushWidgetState()));
        break;
      case 'repeat':
        notifier.toggleLoopMode();
        unawaited(_pushWidgetState());
        break;
      default:
        devLog('WidgetIntentHandler: unknown player action $action');
    }
  }

  static const _provider = 'com.mossapps.flick.widgets.MiniPlayerWidgetProvider';
  static const _flagshipProvider = 'com.mossapps.flick.widgets.FlagshipWidgetProvider';
  static const _compactProvider = 'com.mossapps.flick.widgets.CompactWidgetProvider';
  static const _replayProvider = 'com.mossapps.flick.widgets.ReplayWidgetProvider';

  Future<void> _pushWidgetState() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final state = _ref.read(playerProvider);
      final Song? song = state.currentSong;
      await HomeWidget.saveWidgetData('flick_widget_is_playing', state.isPlaying);
      await HomeWidget.saveWidgetData('flick_widget_has_song', song != null);
      if (song != null) {
        await HomeWidget.saveWidgetData('flick_widget_title', song.title);
        await HomeWidget.saveWidgetData('flick_widget_artist', song.artist);
        await HomeWidget.saveWidgetData('flick_widget_album_art', song.albumArt ?? '');
      }
      await HomeWidget.saveWidgetData('flick_widget_is_shuffle', state.isShuffle);
      await HomeWidget.saveWidgetData('flick_widget_loop_mode', state.loopMode.index);
      await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
      await HomeWidget.updateWidget(qualifiedAndroidName: _flagshipProvider);
      await HomeWidget.updateWidget(qualifiedAndroidName: _compactProvider);
      await HomeWidget.updateWidget(qualifiedAndroidName: _replayProvider);
    } catch (e) {
      devLog('WidgetIntentHandler: failed to push widget state: $e');
    }
  }
}
