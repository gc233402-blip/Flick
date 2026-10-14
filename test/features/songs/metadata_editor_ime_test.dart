// The metadata editor's IME "next" action must survive localization.
//
// `_buildField` used to decide the keyboard action from the *label text*:
//
//     textInputAction: label == 'Title' ? TextInputAction.next : null,
//
// Callers pass `l10n.title` in, so this worked in English and broke in every
// other locale: the label became 标题, the comparison failed, and the Title
// field silently lost its "next" key -- tabbing from Title to Artist stopped
// working (fixed upstream in d6a69757, shipped as #297).
//
// This is the class A trap from source_guard_test.dart, and the source guard
// cannot see it: the localized string enters `_buildField` through a parameter,
// so the evidence is at the call site and no single-file data-flow rule reaches
// it. Verified by restoring the line above and watching source_guard_test.dart
// stay green. A widget test is the only cheap check that does catch it, so this
// file pins the behaviour rather than the source text.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flick/features/songs/widgets/metadata_editor_bottom_sheet.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/song.dart';

/// An editable song: `filePath != null`, no cue offsets, not external -- the
/// three things `_isEditable` checks before it enables the fields.
const Song _editableSong = Song(
  id: 'song-1',
  title: 'Roads',
  artist: 'Portishead',
  album: 'Dummy',
  duration: Duration(minutes: 5),
  fileType: 'flac',
  filePath: '/storage/emulated/0/Music/Dummy/01 Roads.flac',
);

/// The app wiring `lib/app/app.dart` uses, so `l10n` follows the locale.
Widget _app(Locale locale) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: kSupportedLocales,
    locale: locale,
    home: Builder(
      builder: (context) {
        LocaleController.instance.bind(AppLocalizations.of(context));
        return const ProviderScope(
          child: Scaffold(
            body: SingleChildScrollView(
              child: MetadataEditorBottomSheet(song: _editableSong),
            ),
          ),
        );
      },
    ),
  );
}

/// The TextField that sits under the field labelled [label].
///
/// `_buildField` renders `Padding > Column > [Text(label), SizedBox, TextField]`,
/// so the innermost Column ancestor of the label owns exactly one TextField.
TextField _fieldUnder(WidgetTester tester, String label) {
  final column = find.ancestor(
    of: find.text(label),
    matching: find.byType(Column),
  );
  expect(column, findsWidgets, reason: 'no field is labelled "$label"');
  return tester.widget<TextField>(
    find.descendant(of: column.first, matching: find.byType(TextField)).first,
  );
}

/// Pump the editor in [locale] and hand back the localizations it rendered with.
Future<AppLocalizations> _pump(WidgetTester tester, Locale locale) async {
  await LocaleController.instance.select(locale);
  await tester.pumpWidget(_app(locale));
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(MetadataEditorBottomSheet)));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    // Singleton: leave it following the device locale for the next test.
    LocaleController.instance.value = null;
  });

  testWidgets('zh: the Title field keeps its IME next-action', (tester) async {
    final l10n = await _pump(tester, const Locale('zh', 'CN'));

    // We are really in Chinese -- otherwise the assertion below is vacuous,
    // because the buggy `label == 'Title'` happens to be correct in English.
    expect(l10n.title, isNot('Title'));
    expect(find.text(l10n.title), findsOneWidget);

    expect(
      _fieldUnder(tester, l10n.title).textInputAction,
      TextInputAction.next,
      reason: 'The Title field lost its "next" action, so the IME key does '
          'nothing and the user cannot advance from Title to Artist. That is '
          'the d6a69757 regression: the action was chosen by comparing the '
          'label against the English literal "Title".',
    );
  });

  testWidgets('en: the Title field keeps its IME next-action', (tester) async {
    final l10n = await _pump(tester, const Locale('en'));
    expect(_fieldUnder(tester, l10n.title).textInputAction, TextInputAction.next);
  });

  testWidgets('zh: the other fields do not claim the next-action', (tester) async {
    final l10n = await _pump(tester, const Locale('zh', 'CN'));

    // Artist is where "next" leads; it must not advertise the same action, or
    // the chain the Title field promises is a lie.
    expect(
      _fieldUnder(tester, l10n.artist).textInputAction,
      isNot(TextInputAction.next),
    );
  });
}
