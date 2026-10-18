// Switching the language at runtime has to reach the strings.
//
// `l10n` is a global accessor (see lib/l10n/l10n.dart) because a large share of
// this app's user-visible text lives in services with no BuildContext.
// `LocaleController.bind` re-points it from `MaterialApp.builder` on every
// build. Anything that reads `l10n` while building therefore follows a language
// switch -- but anything that *captures* it (a field initialised with
// `l10n.something`, a top-level `final`) keeps the first locale forever. That is
// exactly what shipped once: protocol, crossfade and crossfeed labels were built
// at startup, so changing the language left them in the old one
// (fixed upstream in 1fe3af48).
//
// This test pins the contract: flip the controller, and both the global accessor
// and the rendered text must change.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/l10n/l10n.dart';
import 'package:flick/services/app_preferences_service.dart';

/// The same wiring `lib/app/app.dart` uses: the controller drives `locale`, and
/// the builder keeps the global accessor pointed at the active localizations.
Widget _app() {
  return ValueListenableBuilder<Locale?>(
    valueListenable: LocaleController.instance,
    builder: (context, selectedLocale, _) {
      return MaterialApp(
        localizationsDelegates: kAppLocalizationsDelegates,
        supportedLocales: kSupportedLocales,
        localeResolutionCallback: resolveAppLocale,
        locale: selectedLocale,
        home: Builder(
          builder: (context) {
            LocaleController.instance.bind(AppLocalizations.of(context));
            // Read through the global accessor on purpose: this is what the
            // service layer and the enumerated labels do.
            return Column(
              children: [
                Text(l10n.flickReplay),
                Text(l10n.language),
              ],
            );
          },
        ),
      );
    },
  );
}

void main() {
  setUp(() {
    // `LocaleController.select` persists the choice, so the platform channel has
    // to answer; without this the first await never completes.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    // Singleton: leave it following the device locale for the next test.
    LocaleController.instance.value = null;
    LocaleController.instance.bindLocale(kFallbackLocale);
  });

  testWidgets('a language switch reaches the global l10n accessor', (tester) async {
    await LocaleController.instance.select(const Locale('en'));
    await tester.pumpWidget(_app());
    expect(l10n.flickReplay, 'Flick Replay');
    expect(find.text('Flick Replay'), findsOneWidget);

    await LocaleController.instance.select(const Locale('zh', 'CN'));
    await tester.pumpAndSettle();

    expect(
      l10n.flickReplay,
      'Flick 回顾',
      reason: 'The global accessor still points at the previous locale, so every '
          'string the service layer produces is stale.',
    );
    expect(find.text('Flick 回顾'), findsOneWidget);
    expect(find.text('Flick Replay'), findsNothing);
  });

  testWidgets('a widget reading l10n during build follows the switch', (tester) async {
    // Two switches in a row: a cached value would freeze at the first one.
    await LocaleController.instance.select(const Locale('zh', 'CN'));
    await tester.pumpWidget(_app());
    expect(l10n.flickReplay, 'Flick 回顾');

    await LocaleController.instance.select(const Locale('en'));
    await tester.pumpAndSettle();
    expect(l10n.flickReplay, 'Flick Replay');
    expect(find.text('Flick Replay'), findsOneWidget);
  });

  test('script-specific locales are never matched by language alone', () {
    const cases = <(Locale, Locale)>[
      (Locale('en', 'GB'), Locale('en')),
      (Locale('zh', 'TW'), Locale('zh', 'CN')),
      (Locale('tl'), kFallbackLocale),
      (Locale('tl', 'PH'), kFallbackLocale),
      (Locale('fil', 'PH'), kFallbackLocale),
      (
        Locale.fromSubtags(languageCode: 'tl', scriptCode: 'Latn'),
        kFallbackLocale,
      ),
      (
        Locale.fromSubtags(
          languageCode: 'tl',
          scriptCode: 'Tglg',
          countryCode: 'PH',
        ),
        kBaybayinLocale,
      ),
      (Locale('es'), kFallbackLocale),
    ];
    for (final (requested, expected) in cases) {
      expect(resolveSupportedLocale(requested), expected);
      expect(resolveAppLocale(requested, kSupportedLocales), expected);
    }
    expect(kSupportedLocales, isNot(contains(const Locale('tl'))));
  });

  test('Baybayin retains its script across a persisted reload', () async {
    final controller = LocaleController.instance;
    await controller.select(kBaybayinLocale);
    expect(await AppPreferencesService().getAppLocale(), 'tl_Tglg');

    // Simulate startup: forget the in-memory selection, then load preferences.
    controller.value = null;
    await controller.load();
    expect(controller.value, kBaybayinLocale);
    controller.bindLocale(controller.effectiveLocale);
    expect(l10n.language, 'ᜏᜒᜃ');

    await controller.select(null);
    expect(await AppPreferencesService().getAppLocale(), 'system');
    controller.value = kBaybayinLocale;
    await controller.load();
    expect(controller.followsSystem, isTrue);
  });

  test('stored legacy, script/region and malformed tags resolve safely', () async {
    const cases = <String, Locale?>{
      'en': Locale('en'),
      'en_US': Locale('en'),
      'zh_CN': Locale('zh', 'CN'),
      'zh_TW': Locale('zh', 'CN'),
      'tl_Tglg': kBaybayinLocale,
      'tl-Tglg-PH': kBaybayinLocale,
      'TL_tglg_ph': kBaybayinLocale,
      'tl_PH': kFallbackLocale,
      'tl_Latn_PH': kFallbackLocale,
      'fil': kFallbackLocale,
      'tl_Tglg_broken': kFallbackLocale,
      '_Tglg': kFallbackLocale,
      'system': null,
      '': null,
    };
    for (final entry in cases.entries) {
      await AppPreferencesService().setAppLocale(entry.key);
      await LocaleController.instance.load();
      expect(LocaleController.instance.value, entry.value, reason: entry.key);
    }
  });

  testWidgets('ordinary Filipino device locales do not activate Baybayin', (
    tester,
  ) async {
    final dispatcher = tester.binding.platformDispatcher;
    addTearDown(dispatcher.clearLocalesTestValue);
    for (final deviceLocale in [
      const Locale('tl'),
      const Locale('tl', 'PH'),
      const Locale('fil', 'PH'),
      const Locale.fromSubtags(languageCode: 'tl', scriptCode: 'Latn'),
    ]) {
      dispatcher.localesTestValue = [deviceLocale];
      LocaleController.instance.value = null;
      LocaleController.instance.bindLocale(
        LocaleController.instance.effectiveLocale,
      );
      expect(l10n.language, 'Language');
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(l10n.localeName, 'en');
      expect(find.text('Language'), findsOneWidget);
      expect(
        Localizations.localeOf(tester.element(find.text('Language'))),
        kFallbackLocale,
      );
    }
  });

  testWidgets('English, Baybayin and Chinese switches reach widgets and services', (
    tester,
  ) async {
    await LocaleController.instance.select(const Locale('en'));
    await tester.pumpWidget(_app());
    await LocaleController.instance.select(kBaybayinLocale);
    await tester.pumpAndSettle();
    expect(l10n.language, 'ᜏᜒᜃ');
    expect(find.text('ᜏᜒᜃ'), findsOneWidget);
    expect(
      l10n.flickReplay,
      'Flick Replay',
      reason: 'Intentional English fallback',
    );
    final context = tester.element(find.text('ᜏᜒᜃ'));
    expect(AppLocalizations.of(context).language, l10n.language);
    expect(
      l10n.songUnit(0),
      'songs',
      reason: 'English fallback keeps English plurals.',
    );
    expect(Localizations.localeOf(context), kBaybayinLocale);
    expect(MaterialLocalizations.of(context).cancelButtonLabel, isNotEmpty);
    expect(Directionality.of(context), TextDirection.ltr);

    await LocaleController.instance.select(const Locale('zh', 'CN'));
    await tester.pumpAndSettle();
    expect(l10n.language, '语言');
    expect(find.text('语言'), findsOneWidget);

    await LocaleController.instance.select(const Locale('en'));
    await tester.pumpAndSettle();
    expect(l10n.language, 'Language');
    expect(find.text('Language'), findsOneWidget);
  });
}
