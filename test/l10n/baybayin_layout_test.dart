// Real bundled fonts and layout assertions, not platform-dependent pixel goldens.
// Enable BAYBAYIN_SCREENSHOTS for images a human can review for mark placement.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/core/theme/app_theme.dart';
import 'package:flick/features/settings/widgets/language_settings_card.dart';
import 'package:flick/features/settings/widgets/settings_widgets.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/mini_player_config.dart';
import 'package:flick/models/nav_bar_config.dart';
import 'package:flick/widgets/common/mini_player_bar.dart';
import 'package:flick/widgets/navigation/flick_nav_bar.dart';

const _shotKey = ValueKey('baybayin_layout_shot');
const _screenshots = bool.fromEnvironment('BAYBAYIN_SCREENSHOTS');

Future<void> _shoot(WidgetTester tester, String name) async {
  if (!_screenshots) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_shotKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/baybayin_shots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Widget _app(Widget child, {double scale = 1}) => ProviderScope(
  child: RepaintBoundary(
    key: _shotKey,
    child: ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance,
      builder: (context, selectedLocale, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        locale: selectedLocale,
        supportedLocales: kSupportedLocales,
        localizationsDelegates: kAppLocalizationsDelegates,
        localeResolutionCallback: resolveAppLocale,
        builder: (context, child) {
          LocaleController.instance.bind(AppLocalizations.of(context));
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: true,
            ),
            child: child!,
          );
        },
        home: Scaffold(body: child),
      ),
    ),
  ),
);

Widget _languagePage() => SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Builder(
        builder: (context) => SettingsSectionHeader(context.l10n.language),
      ),
      const LanguageSettingsCard(),
    ],
  ),
);

Finder _option(String autonym) => find.byWidgetPredicate(
  (widget) => widget is SelectionSetting && widget.title == autonym,
);

void _setSize(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader('GoogleSansFlex')
          ..addFont(rootBundle.load('assets/fonts/GoogleSansFlex-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/GoogleSansFlex-Bold.ttf')))
        .load();
    await (FontLoader('NotoSansSC')
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Bold.ttf')))
        .load();
    await (FontLoader(
          'NotoSansTagalog',
        )..addFont(rootBundle.load('assets/fonts/NotoSansTagalog-Regular.ttf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
          rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
        ))
        .load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    LocaleController.instance.value = null;
    LocaleController.instance.bindLocale(kFallbackLocale);
  });

  testWidgets('language choices survive narrow screens and enlarged text', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in kSupportedLocales) {
      for (final width in [320.0, 375.0, 600.0]) {
        for (final scale in [1.0, 2.0, 3.0]) {
          _setSize(tester, width);
          LocaleController.instance.value = locale;
          // Reset the page/scroll position between sweep cases.
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(_app(_languagePage(), scale: scale));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$locale width=$width scale=$scale',
          );
          expect(_option('Tagalog (Baybayin)'), findsOneWidget);
          expect(_option('English'), findsOneWidget);
          if (width == 320 && scale == 1 && locale.languageCode != 'zh') {
            await _shoot(tester, 'language-${locale.toString()}-320');
          }
          await tester.ensureVisible(_option('English'));
          await tester.pumpAndSettle();
          expect(
            _option('English').hitTestable(),
            findsOneWidget,
            reason: 'The escape option must remain reachable.',
          );
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  testWidgets('the actual selector can enter Baybayin and escape to English', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    _setSize(tester, 320);
    LocaleController.instance.value = const Locale('en');
    await tester.pumpWidget(_app(_languagePage(), scale: 2));
    await tester.pumpAndSettle();
    await tester.ensureVisible(_option('Tagalog (Baybayin)'));
    await tester.tap(_option('Tagalog (Baybayin)'));
    await tester.pumpAndSettle();
    expect(LocaleController.instance.value, kBaybayinLocale);
    expect(
      tester.widget<SelectionSetting>(_option('Tagalog (Baybayin)')).selected,
      isTrue,
    );
    expect(l10n.language, 'ᜏᜒᜃ');
    await tester.ensureVisible(_option('English'));
    await tester.pumpAndSettle();
    await _shoot(tester, 'language-tl_Tglg-320-large-escape');
    await tester.tap(_option('English'));
    await tester.pumpAndSettle();
    expect(LocaleController.instance.value, const Locale('en'));
    expect(l10n.language, 'Language');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Baybayin navigation fits without changing music metadata', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LocaleController.instance.value = kBaybayinLocale;
    for (final width in [320.0, 375.0, 600.0]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        for (final allButtons in [false, true]) {
          _setSize(tester, width);
          await tester.pumpWidget(
            _app(
              Align(
                alignment: Alignment.bottomCenter,
                child: FlickNavBar(
                  config: allButtons
                      ? NavBarConfig(
                          enabledButtons: NavBarButton.values,
                          showLabels: true,
                        )
                      : NavBarConfig.defaultConfig,
                  currentIndex: 1,
                  onTap: (_) {},
                  showMiniPlayer: true,
                  miniPlayerWidget: MiniPlayerBar(
                    config: MiniPlayerConfig.defaultConfig,
                    songId: 'test-song',
                    title: 'Jóga',
                    artist: 'Björk',
                    progress: 0.42,
                    enableHero: false,
                    onPlayPause: () {},
                    onPrevious: () {},
                    onNext: () {},
                  ),
                ),
              ),
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'width=$width scale=$scale allButtons=$allButtons',
          );
          expect(find.text('Jóga'), findsOneWidget);
          expect(find.text('Björk'), findsOneWidget);
          if (width == 375 && scale == 1 && !allButtons) {
            await _shoot(tester, 'navigation-tl_Tglg-375');
          }
        }
      }
    }
  });
}
