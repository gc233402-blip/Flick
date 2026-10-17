import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:flick/core/constants/app_constants.dart';

/// Shared delivery policy for app feedback. Flutter still owns placement,
/// swipe dismissal, live-region semantics, route transitions, and action state.
extension FlickSnackBarMessenger on ScaffoldMessengerState {
  void showFlickSnackBar(SnackBar snackBar, {Object? id}) {
    if (!mounted) return;
    final queue = _queues[this] ??= _SnackBarQueue(this);
    queue.show(_Notice(snackBar, id));
  }

  /// An [id] dismisses only that notice, including any queued update. Without
  /// one, dismisses the current notice, allowing pending feedback to follow.
  void hideFlickSnackBar({Object? id}) => _queues[this]?.hide(id: id);

  void clearFlickSnackBars() => _queues[this]?.clear();
}

final _queues = Expando<_SnackBarQueue>('Flick snackbars');

class _Notice {
  _Notice(this.snackBar, this.id);

  final SnackBar snackBar;
  final Object? id;
  // A snackbar can be mounted in both routes during a Hero transition. Do not
  // give its content a GlobalKey or keep a single route's State alive.
  final lifetimes = <_NoticeLifetimeState>{};
  bool visible = false;

  void start() {
    visible = true;
    for (final lifetime in lifetimes) {
      lifetime.start();
    }
  }

  void refresh() {
    for (final lifetime in lifetimes) {
      lifetime.refresh();
    }
  }

  void stop() {
    visible = false;
    for (final lifetime in lifetimes) {
      lifetime.stop();
    }
  }

  // Long-running status notices and actions keep their native lifetime. Only
  // routine feedback is coalesced and given a refreshable display timer.
  bool get routine =>
      snackBar.action == null &&
      !snackBar.persist &&
      snackBar.duration < const Duration(minutes: 1);

  String? get text => switch (snackBar.content) {
    Text(:final data, :final textSpan) => data ?? textSpan?.toPlainText(),
    _ => null,
  };

  bool sameMessage(_Notice other) =>
      routine &&
      other.routine &&
      id == other.id &&
      text != null &&
      text == other.text &&
      snackBar.backgroundColor == other.snackBar.backgroundColor;
}

class _SnackBarQueue {
  _SnackBarQueue(this.messenger);

  final ScaffoldMessengerState messenger;
  final Queue<_Notice> _protected = Queue<_Notice>();
  _Notice? _latest;
  _Notice? _current;
  bool _closing = false;

  void show(_Notice notice) {
    final current = _current;
    if (current == null) {
      _present(notice);
      return;
    }
    if (!_closing && current.sameMessage(notice)) {
      current.refresh();
      return;
    }

    if (notice.id != null) _removePending(notice.id!);
    if (notice.routine) {
      _latest = notice;
    } else {
      _protected.addLast(notice);
    }

    // Never evict an unrelated Undo/Retry/status notice for routine feedback.
    // A named status may explicitly update itself without a stale backlog.
    if (current.routine || (notice.id != null && current.id == notice.id)) {
      _hideCurrent();
    }
  }

  void hide({Object? id}) {
    if (id != null) _removePending(id);
    if (id == null || _current?.id == id) _hideCurrent();
  }

  void clear() {
    _protected.clear();
    _latest = null;
    _hideCurrent();
  }

  void _removePending(Object id) {
    _protected.removeWhere((notice) => notice.id == id);
    if (_latest?.id == id) _latest = null;
  }

  void _hideCurrent() {
    if (_current == null || _closing || !messenger.mounted) return;
    _closing = true;
    _current!.stop();
    messenger.hideCurrentSnackBar();
  }

  void _present(_Notice notice) {
    if (!messenger.mounted) {
      clear();
      return;
    }
    _current = notice;
    _closing = false;
    final original = notice.snackBar;
    final reducedMotion =
        AppConstants.animationFast == Duration.zero ||
        MediaQuery.disableAnimationsOf(messenger.context) ||
        MediaQuery.accessibleNavigationOf(messenger.context);
    final controller = messenger.showSnackBar(
      _FlickSnackBar(
        SnackBar(
          key: original.key,
          content: notice.routine
              ? _NoticeLifetime(
                  notice: notice,
                  duration: original.duration,
                  onTimeout: _hideCurrent,
                  child: original.content,
                )
              : original.content,
          backgroundColor: original.backgroundColor,
          elevation: original.elevation,
          margin: original.margin,
          padding: original.padding,
          width: original.width,
          shape: original.shape,
          hitTestBehavior: original.hitTestBehavior,
          behavior: original.behavior,
          action: original.action,
          actionOverflowThreshold: original.actionOverflowThreshold,
          showCloseIcon: original.showCloseIcon ?? original.persist,
          closeIconColor: original.closeIconColor,
          duration: original.duration,
          // Routine messages own only their refreshable timer; protected notices
          // retain Flutter's persistence and action handling unchanged.
          persist: notice.routine || original.persist,
          onVisible: () {
            if (!_closing) notice.start();
            original.onVisible?.call();
          },
          dismissDirection: original.dismissDirection,
          clipBehavior: original.clipBehavior,
        ),
      ),
      snackBarAnimationStyle: reducedMotion
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200),
            ),
    );
    unawaited(controller.closed.then((_) => _onClosed(notice)));
  }

  void _onClosed(_Notice notice) {
    if (!identical(_current, notice)) return;
    notice.stop();
    _current = null;
    _closing = false;
    if (!messenger.mounted) {
      _protected.clear();
      _latest = null;
      return;
    }
    if (_protected.isNotEmpty) {
      _present(_protected.removeFirst());
    } else if (_latest case final next?) {
      _latest = null;
      _present(next);
    }
  }
}

/// Keeps the native snackbar intact, but animates its entire surface rather
/// than Material 3's narrow fade interval (only 20% of the controller timeline).
/// The messenger still supplies the sole animation controller and owns layout.
class _FlickSnackBar extends SnackBar {
  _FlickSnackBar(this.bar, {Key? key, super.animation})
    : super(
        key: key ?? bar.key,
        content: bar.content,
        behavior: bar.behavior,
        margin: bar.margin,
        width: bar.width,
        duration: bar.duration,
        persist: bar.persist,
      );

  final SnackBar bar;

  @override
  SnackBar withAnimation(Animation<double> newAnimation, {Key? fallbackKey}) =>
      _FlickSnackBar(bar, key: key ?? fallbackKey, animation: newAnimation);

  @override
  State<SnackBar> createState() => _FlickSnackBarState();
}

class _FlickSnackBarState extends State<_FlickSnackBar> {
  late CurvedAnimation _movement;
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    _attachAnimation();
  }

  void _attachAnimation() {
    _movement = CurvedAnimation(
      parent: widget.animation!,
      curve: Curves.easeOutCubic,
    );
    widget.animation!.addStatusListener(_onStatusChanged);
    // Zero-duration motion can finish before the widget mounts. Notify after
    // layout so refreshable timers start in reduced-motion mode as well.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.animation!.isCompleted) _notifyVisible();
    });
  }

  void _notifyVisible() {
    if (_wasVisible) return;
    _wasVisible = true;
    widget.bar.onVisible?.call();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) _notifyVisible();
  }

  @override
  void didUpdateWidget(_FlickSnackBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation!.removeStatusListener(_onStatusChanged);
      _movement.dispose();
      _attachAnimation();
    }
  }

  @override
  void dispose() {
    widget.animation!.removeStatusListener(_onStatusChanged);
    _movement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: widget.animation!,
    child: AnimatedBuilder(
      animation: _movement,
      // Disable only the native visual transition, not the user's semantics,
      // action behavior, theme, or media-query accessibility preferences.
      child: widget.bar.withAnimation(kAlwaysCompleteAnimation),
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - _movement.value)),
        child: child,
      ),
    ),
  );
}

/// A timer scoped to the mounted content, not an app-wide polling loop. Pauses
/// while the app is backgrounded or the notice is being read/interacted with.
class _NoticeLifetime extends StatefulWidget {
  const _NoticeLifetime({
    required this.notice,
    required this.duration,
    required this.onTimeout,
    required this.child,
  });

  final _Notice notice;
  final Duration duration;
  final VoidCallback onTimeout;
  final Widget child;

  @override
  State<_NoticeLifetime> createState() => _NoticeLifetimeState();
}

class _NoticeLifetimeState extends State<_NoticeLifetime>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _visible = false;
  bool _foreground = true;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.notice.lifetimes.add(this);
    _visible = widget.notice.visible;
    _foreground = switch (WidgetsBinding.instance.lifecycleState) {
      null || AppLifecycleState.resumed => true,
      _ => false,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refresh();
  }

  void start() {
    _visible = true;
    refresh();
  }

  void stop() {
    _visible = false;
    _timer?.cancel();
  }

  void refresh() {
    _timer?.cancel();
    if (!_visible || !_foreground || _hovered || _focused) return;
    // Give screen-reader users more time for non-actionable feedback too.
    final duration =
        MediaQuery.accessibleNavigationOf(context) &&
            widget.duration < const Duration(seconds: 8)
        ? const Duration(seconds: 8)
        : widget.duration;
    _timer = Timer(duration, widget.onTimeout);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.notice.lifetimes.remove(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) {
      _hovered = true;
      refresh();
    },
    onExit: (_) {
      _hovered = false;
      refresh();
    },
    child: Focus(
      canRequestFocus: false,
      onFocusChange: (focused) {
        _focused = focused;
        refresh();
      },
      child: widget.child,
    ),
  );
}
