// Chinese text must not break the layouts that English fits into.
//
// Why this is not a pixel golden
// ------------------------------
// The obvious way to guard "Chinese renders correctly" is `matchesGoldenFile`.
// It cannot work here. Golden PNGs depend on the platform's font rasteriser, so
// an image produced on a developer's Windows box does not match the one Ubuntu
// CI produces, and Flutter's `LocalFileComparator` has no per-platform variant
// of a golden to fall back on. Upstream reached the same conclusion: the recap
// screen's `_snapshot` writes PNGs only when
// `--dart-define=REPLAY_SCREENSHOTS=true` is passed, so they are an opt-in
// review artefact rather than a CI gate.
//
// What this file does instead
// ---------------------------
// It asserts the property the goldens were wanted for: in Chinese, with a narrow
// phone and an accessibility text scale, nothing overflows and nothing throws.
// That is platform independent, so it runs in CI, and it fails loudly rather
// than needing a human to eyeball a diff.
//
// Chinese is the risky locale, not English. This app was written in English, and
// `test/widgets/mini_player_bar_test.dart` already sweeps width and text scale
// -- but only in English. A Chinese nav label ("播放列表") is wider than
// "Playlists" in the same slot, and a nav bar has fixed slots, so the sweep is
// rerun here in zh.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/core/theme/app_theme.dart';
import 'package:flick/features/songs/widgets/metadata_editor_bottom_sheet.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/mini_player_config.dart';
import 'package:flick/models/nav_bar_config.dart';
import 'package:flick/models/song.dart';
import 'package:flick/widgets/common/flick_dialog.dart';
import 'package:flick/widgets/common/mini_player_bar.dart';
import 'package:flick/widgets/navigation/flick_nav_bar.dart';

/// Widths worth testing: a small phone, a common phone, and a wide one.
const List<double> _widths = <double>[320, 375, 600];

/// 1.0 is the default; 2.0 and 3.0 are the accessibility extremes the app
/// already sweeps for in English.
const List<double> _scales = <double>[1.0, 2.0, 3.0];

const Song _song = Song(
  id: 'song-1',
  title: 'Roads',
  artist: 'Portishead',
  album: 'Dummy',
  duration: Duration(minutes: 5),
  fileType: 'flac',
  filePath: '/storage/emulated/0/Music/Dummy/01 Roads.flac',
);

/// Every button the bar can hold. The default config carries only three
/// (菜单 / 歌曲 / 设置), which leaves plenty of slack; nine Chinese labels in the
/// same bar is where the layout is actually at risk.
final NavBarConfig _allButtonsConfig = NavBarConfig(
  enabledButtons: NavBarButton.values,
  showLabels: true,
);

/// Opt-in screenshots, following the recap screen's `REPLAY_SCREENSHOTS`
/// precedent: `flutter test --dart-define=ZH_SCREENSHOTS=true` writes PNGs for a
/// human to look at. They are a review aid, not an assertion -- a stored image
/// would not match between this machine and CI.
const bool _screenshots = bool.fromEnvironment('ZH_SCREENSHOTS');

/// Where `--dart-define=ZH_SCREENSHOTS=true` drops its images.
const String _shotDir = 'build/zh_shots';

/// Repaint boundary around everything the host renders, including any overlay a
/// dialog opens into. Used by `--dart-define=ZH_SCREENSHOTS=true`.
const Key _shotKey = ValueKey('zh_layout_shot');

Future<void> _shoot(WidgetTester tester, String name, {Finder? target}) async {
  if (!_screenshots) return;
  final finder = target ?? find.byKey(_shotKey);
  final boundary = tester.renderObject(finder) as RenderRepaintBoundary;
  // Image encoding is real async work, so it has to run outside the fake clock.
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$_shotDir/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('>>> wrote ${file.path}');
    } finally {
      image.dispose();
    }
  });
}

/// The app wiring `lib/app/app.dart` uses, in [locale], at a fixed [width] and
/// [textScale]. `l10n` is a global accessor, so it has to be bound the same way
/// the real app binds it or the widgets under test would render English.
Widget _host(
  Widget child, {
  required Locale locale,
  double width = 375,
  double textScale = 1,
  EdgeInsets padding = EdgeInsets.zero,
  bool wrapInScope = true,
}) {
  Widget body = MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: kSupportedLocales,
    locale: locale,
    home: Builder(
      builder: (context) {
        LocaleController.instance.bind(AppLocalizations.of(context));
        return MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            padding: padding,
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(width: width, child: child),
            ),
          ),
        );
      },
    ),
  );
  // The boundary wraps the MaterialApp, not the body: a dialog renders into the
  // app's overlay, so a boundary around the page would not capture it.
  final wrapped = RepaintBoundary(key: _shotKey, child: body);
  return wrapInScope ? ProviderScope(child: wrapped) : wrapped;
}

MiniPlayerConfig _miniConfig() => MiniPlayerConfig.defaultConfig.copyWith(
      widthMode: MiniPlayerWidthMode.custom,
      widthFraction: 0.7,
      height: 48,
      cornerRadius: 32,
      navigationGap: 24,
      showPrevious: true,
      showNext: true,
      textScale: 1.3,
    );

/// Key for the button that opens the dialog, so the test never has to find it
/// by a string that the locale could change.
const Key _openDialogKey = ValueKey('open_dialog');

/// A host whose trigger sits in the middle of a fixed-size box. Aligning it to
/// the bottom (as the nav-bar host does) lets a large text scale push it off
/// screen, and `tap` then misses without failing the test -- which would leave
/// the dialog unopened and the overflow assertion meaningless.
Widget _dialogHost({
  required Locale locale,
  required double width,
  required double textScale,
}) {
  return _host(
    Builder(
      builder: (context) => Center(
        child: FilledButton(
          key: _openDialogKey,
          onPressed: () => FlickDialogs.confirm(
            context,
            title: l10n.discardChanges2,
            message: l10n.youHaveUnsavedChangesAreYou,
            confirmLabel: l10n.discard,
            destructive: true,
          ),
          child: const Text('open'),
        ),
      ),
    ),
    locale: locale,
    width: width,
    textScale: textScale,
  );
}

Widget _navBar({required bool collapsed, required bool separated}) => FlickNavBar(
      config: _allButtonsConfig,
      currentIndex: 1,
      onTap: (_) {},
      collapsed: collapsed,
      separateMiniPlayer: separated,
      showMiniPlayer: true,
      miniPlayerWidget: MiniPlayerBar(
        config: _miniConfig(),
        songId: 'test',
        title: '很长的歌曲标题用来测试小屏幕上的可读性',
        artist: '一位名字很长的艺术家',
        progress: 0.42,
        enableHero: false,
        separated: separated,
        collapsed: collapsed,
        onPlayPause: () {},
        onPrevious: () {},
        onNext: () {},
      ),
    );

void main() {
  setUpAll(() async {
    // Without this every glyph is a tofu box: the widget test environment has no
    // system fonts, so text would be measured against a fallback with different
    // metrics than the real typeface and the overflow assertions would be
    // measuring the wrong layout. The bundled Latin face carries no CJK, so the
    // Noto Sans SC fallback has to be registered too -- that is the face that
    // actually draws the Chinese the app ships.
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader('GoogleSansFlex')
          ..addFont(rootBundle.load('assets/fonts/GoogleSansFlex-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/GoogleSansFlex-Bold.ttf')))
        .load();
    await (FontLoader('NotoSansSC')
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Bold.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    await (FontLoader('packages/lucide_icons_flutter/Lucide')
          ..addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf')))
        .load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    LocaleController.instance.value = null;
  });

  testWidgets('zh: the navigation bar survives small phones and large text', (
    tester,
  ) async {
    for (final width in _widths) {
      for (final scale in _scales) {
        for (final collapsed in [false, true]) {
          for (final separated in [false, true]) {
            await tester.pumpWidget(
              _host(
                _navBar(collapsed: collapsed, separated: separated),
                locale: const Locale('zh', 'CN'),
                width: width,
                textScale: scale,
                padding: const EdgeInsets.only(left: 20, right: 10, bottom: 24),
              ),
            );
            await tester.pumpAndSettle();
            if (width == 320 && scale == 1.0 && !collapsed && !separated) {
              await _shoot(tester, 'zh-navbar-320');
            }
            expect(
              tester.takeException(),
              isNull,
              reason: 'the zh navigation bar overflowed at '
                  'width=$width scale=$scale collapsed=$collapsed '
                  'separated=$separated',
            );
          }
        }
      }
    }
  });

  testWidgets('zh: the metadata editor survives small phones and large text', (
    tester,
  ) async {
    for (final width in _widths) {
      for (final scale in _scales) {
        await tester.pumpWidget(
          _host(
            const SingleChildScrollView(
              child: MetadataEditorBottomSheet(song: _song),
            ),
            locale: const Locale('zh', 'CN'),
            width: width,
            textScale: scale,
          ),
        );
        await tester.pumpAndSettle();
        if (width == 320 && scale == 1.0) {
          await _shoot(tester, 'zh-metadata-editor-320');
        }
        expect(
          tester.takeException(),
          isNull,
          reason: 'the zh metadata editor overflowed at '
              'width=$width scale=$scale',
        );
      }
    }
  });

  testWidgets('zh: the labels really are Chinese, so the sweeps mean something', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _navBar(collapsed: false, separated: false),
        locale: const Locale('zh', 'CN'),
        width: 375,
      ),
    );
    await tester.pumpAndSettle();

    // If the locale wiring ever breaks, the sweeps above would quietly test
    // English and pass for the wrong reason.
    expect(NavBarButton.songs.label, '歌曲');
    expect(NavBarButton.menu.label, '菜单');
    expect(find.text('歌曲'), findsWidgets);
  });

  testWidgets('zh: the two-button dialog row survives narrow phones', (
    tester,
  ) async {
    // `FlickDialog` puts two actions side by side in a `Row` of `Expanded`s.
    // Chinese labels are wider than their English counterparts in the same
    // slot, so this is the shape most likely to overflow.
    for (final width in _widths) {
      for (final scale in _scales) {
        // The trigger is centred in its own box rather than aligned to the
        // bottom, so a large text scale cannot push it out of hit-test range
        // and silently leave the dialog unopened.
        await tester.pumpWidget(
          _dialogHost(
            locale: const Locale('zh', 'CN'),
            width: width,
            textScale: scale,
          ),
        );
        await tester.tap(find.byKey(_openDialogKey), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Prove the dialog actually opened before trusting the overflow check.
        // This is the real guard on the tap: with no tap this finds nothing, so
        // a missed tap fails here instead of silently testing an empty tree.
        expect(
          find.text(l10n.discardChanges2),
          findsOneWidget,
          reason: 'the confirm dialog did not open at '
              'width=$width scale=$scale',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'the zh confirm dialog overflowed at '
              'width=$width scale=$scale',
        );
        expect(find.text(l10n.discard), findsOneWidget);

        // The cancel button used to be the library's own English default,
        // because `FlickDialogs.confirm` defaulted `cancelLabel` to the literal
        // 'Cancel' and 17 of its 18 call sites pass no `cancelLabel`.
        expect(
          find.text(l10n.cancel),
          findsOneWidget,
          reason: 'the cancel button is not localized at '
              'width=$width scale=$scale',
        );
        expect(find.text('Cancel'), findsNothing);

        if (width == 320 && scale == 1.0) {
          await _shoot(tester, 'zh-confirm-dialog-320');
        }
      }
    }
  });

  testWidgets('zh: the input dialog cancels in Chinese too', (tester) async {
    // `FlickDialogs.input` carried the same hardcoded 'Cancel' default as
    // `confirm`, and all 7 of its call sites omit `cancelLabel`.
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => Center(
            child: FilledButton(
              key: _openDialogKey,
              onPressed: () => FlickDialogs.input(
                context,
                title: l10n.rename,
                hintText: l10n.playlistName,
                confirmLabel: l10n.saveChanges,
              ),
              child: const Text('open'),
            ),
          ),
        ),
        locale: const Locale('zh', 'CN'),
      ),
    );
    await tester.tap(find.byKey(_openDialogKey), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text(l10n.saveChanges), findsOneWidget,
        reason: 'the input dialog did not open');
    expect(
      find.text(l10n.cancel),
      findsOneWidget,
      reason: 'the input dialog cancel button is not localized',
    );
    expect(find.text('Cancel'), findsNothing);
  });
}
