// Localization entry point for Flick.
//
// Two accessors are provided, on purpose:
//
//   * `l10n.<key>`     -- a global accessor, usable anywhere, including the
//                         service layer. A large share of this app's
//                         user-visible strings live in services that have no
//                         BuildContext (player_service.dart alone holds ~170),
//                         so a context-only API would not be practical.
//   * `context.l10n`   -- the idiomatic widget-layer accessor.
//
// The global is kept in sync by [LocaleController.bind], which is called from
// MaterialApp.builder on every build, and once from main() before the first
// frame so that strings produced during startup already use the right locale.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flick/l10n/generated/app_localizations.dart';
import 'package:flick/l10n/generated/app_localizations_tl.dart';
import 'package:flick/services/app_preferences_service.dart';

export 'package:flick/l10n/generated/app_localizations.dart';

// 模型层的展示扩展（label / description / menuLabel …）。
//
// 它们放在 lib/l10n/ 而不是 lib/models/，是为了让模型保持与语言无关 —— 上游
// review 明确要求 models 不得依赖 l10n（会破坏分层与可测试性）。这里 re-export，
// 调用方只要 import 本文件就能拿到，无需额外 import。
export 'package:flick/l10n/model_labels.dart';

/// The opt-in Tagalog-in-Baybayin pilot. `Tglg` is a script, not a language.
const Locale kBaybayinLocale = Locale.fromSubtags(
  languageCode: 'tl',
  scriptCode: 'Tglg',
);

/// Locales the app ships translations for (including the partial pilot).
///
/// English is listed first so that a device locale we do not translate falls
/// back to English rather than to Chinese. Chinese devices still resolve to
/// `zh` through the language-code match below.
const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('zh', 'CN'),
  kBaybayinLocale,
];

/// Used when nothing else matches.
const Locale kFallbackLocale = Locale('en');

/// Override only the pilot; keep Flutter's stock delegates for everything else.
/// The first supported delegate of each type wins.
const List<LocalizationsDelegate<dynamic>> kAppLocalizationsDelegates = [
  _BaybayinLocalizationsDelegate(),
  ...AppLocalizations.localizationsDelegates,
];

/// The partial pilot needs English ICU rules for its inherited English text.
/// Otherwise, Tagalog rules make e.g. an untranslated `songUnit(0)` say "song".
/// `localeName` here is the formatting locale; Localizations.localeOf(context)
/// still returns tl_Tglg and Flutter's built-in controls still use Tagalog.
AppLocalizations lookupFlickLocalizations(Locale requested) {
  final locale = resolveSupportedLocale(requested);
  return locale == kBaybayinLocale
      ? _BaybayinWithEnglishFallback()
      : lookupAppLocalizations(locale);
}

class _BaybayinWithEnglishFallback extends AppLocalizationsTlTglg {
  @override
  String get localeName => 'en';
}

class _BaybayinLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _BaybayinLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale == kBaybayinLocale;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(lookupFlickLocalizations(locale));

  @override
  bool shouldReload(_BaybayinLocalizationsDelegate old) => false;
}

/// The current localizations. Initialized to English so that reads before the
/// first frame cannot throw.
AppLocalizations _current = lookupAppLocalizations(kFallbackLocale);

/// Global accessor. Prefer `context.l10n` inside widgets.
AppLocalizations get l10n => _current;

/// Idiomatic widget-layer accessor.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Maps [requested] onto the closest locale we actually support.
Locale resolveSupportedLocale(Locale requested) {
  for (final supported in kSupportedLocales) {
    if (supported == requested) return supported;
  }
  // A script-specific translation must never be selected by language alone.
  // In particular, an ordinary tl/tl_PH device must not opt into Baybayin.
  if (requested.scriptCode != null) {
    for (final supported in kSupportedLocales) {
      if (supported.languageCode == requested.languageCode &&
          supported.scriptCode == requested.scriptCode) {
        return supported;
      }
    }
  }
  for (final supported in kSupportedLocales) {
    if (supported.languageCode == requested.languageCode &&
        supported.scriptCode == null) {
      return supported;
    }
  }
  return kFallbackLocale;
}

/// MaterialApp must use the same script-aware resolution as startup/services.
/// Flutter's default language-only fallback could otherwise select the pilot.
Locale resolveAppLocale(Locale? requested, Iterable<Locale> _) =>
    resolveSupportedLocale(requested ?? kFallbackLocale);

/// Holds the user's language choice and keeps the global [l10n] in sync.
///
/// A `null` [value] means "follow the device locale".
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController._() : super(null);

  static final LocaleController instance = LocaleController._();

  /// Persisted marker for "follow the system locale".
  static const String systemValue = 'system';

  /// True when the app follows the device locale.
  bool get followsSystem => value == null;

  /// The locale to hand to MaterialApp. Never null.
  Locale get effectiveLocale => value ?? _deviceLocale();

  /// Restores the persisted choice. Await this before the first frame.
  Future<void> load() async {
    final stored = await AppPreferencesService().getAppLocale();
    value = _localeFromStored(stored);
  }

  /// Selects [locale], or `null` to follow the device locale.
  Future<void> select(Locale? locale) async {
    locale = locale == null ? null : resolveSupportedLocale(locale);
    if (locale == value) return;
    value = locale;
    await AppPreferencesService().setAppLocale(_storedFromLocale(locale));
  }

  /// Points the global accessor at [localizations]. Called from the app builder.
  void bind(AppLocalizations localizations) {
    _current = localizations;
  }

  /// Points the global accessor at [locale] without a BuildContext. Used during
  /// startup, before any Localizations widget exists.
  void bindLocale(Locale locale) {
    _current = lookupFlickLocalizations(locale);
  }

  Locale _deviceLocale() {
    final binding = WidgetsBinding.instance;
    final locales = binding.platformDispatcher.locales;
    if (locales.isEmpty) return kFallbackLocale;
    return resolveSupportedLocale(locales.first);
  }

  Locale? _localeFromStored(String? stored) {
    if (stored == null || stored.isEmpty || stored == systemValue) return null;
    // Accept both the existing en/zh_CN values and script-aware locale tags.
    final match = RegExp(
      r'^([A-Za-z]{2,3})(?:[_-]([A-Za-z]{4}))?(?:[_-]([A-Za-z]{2}|[0-9]{3}))?$',
    ).firstMatch(stored);
    if (match == null) return kFallbackLocale;
    final script = match.group(2);
    return resolveSupportedLocale(
      Locale.fromSubtags(
        languageCode: match.group(1)!.toLowerCase(),
        scriptCode: script == null
            ? null
            : '${script[0].toUpperCase()}${script.substring(1).toLowerCase()}',
        countryCode: match.group(3)?.toUpperCase(),
      ),
    );
  }

  String _storedFromLocale(Locale? locale) => locale?.toString() ?? systemValue;
}
