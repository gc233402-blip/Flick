// Technical checks do not certify the Tagalog wording or Baybayin spelling.
// Human approval is recorded separately in the review sheet and ARB metadata.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:flick/core/theme/app_theme.dart';
import 'package:flick/l10n/l10n.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/l10n/$name.arb').readAsStringSync())
        as Map<String, dynamic>;

Map<String, String> _messages(Map<String, dynamic> arb) => {
  for (final entry in arb.entries)
    if (!entry.key.startsWith('@')) entry.key: entry.value as String,
};

Set<String> _placeholders(String message) => RegExp(
  r'\{([A-Za-z_]\w*)\s*[,}]',
).allMatches(message).map((match) => match.group(1)!).toSet();

/// Actual nonzero cmap format-4 glyph mappings, not just segment ranges (which
/// can contain holes). All Tagalog characters are in the BMP. No font-tool dep.
Set<int> _fontCodepoints(ByteData data) {
  int u16(int offset) => data.getUint16(offset);
  int u32(int offset) => data.getUint32(offset);
  for (var table = 0; table < u16(4); table++) {
    final record = 12 + table * 16;
    if (u32(record) != 0x636d6170) continue; // cmap
    final cmap = u32(record + 8);
    final result = <int>{};
    for (var subtable = 0; subtable < u16(cmap + 2); subtable++) {
      final offset = cmap + u32(cmap + 4 + subtable * 8 + 4);
      if (u16(offset) != 4) continue;
      final segments = u16(offset + 6) ~/ 2;
      final ends = offset + 14;
      final starts = ends + segments * 2 + 2;
      final deltas = starts + segments * 2;
      final ranges = deltas + segments * 2;
      for (var segment = 0; segment < segments; segment++) {
        final start = u16(starts + segment * 2);
        final end = u16(ends + segment * 2);
        final delta = data.getInt16(deltas + segment * 2);
        final rangeAddress = ranges + segment * 2;
        final range = u16(rangeAddress);
        for (var char = start; char <= end && char < 0xffff; char++) {
          var glyph = range == 0
              ? char
              : u16(rangeAddress + range + (char - start) * 2);
          if (range == 0 || glyph != 0) glyph = (glyph + delta) & 0xffff;
          if (glyph != 0) result.add(char);
        }
      }
    }
    return result;
  }
  throw StateError('Bundled font has no cmap table');
}

void main() {
  final en = _messages(_arb('app_en'));
  final arb = _arb('app_tl_Tglg');
  final pilot = _messages(arb);

  test('the partial pilot is explicit and every draft has review context', () {
    expect(arb['@@locale'], 'tl_Tglg');
    expect(pilot.length, inInclusiveRange(40, 60));
    expect(
      _messages(_arb('app_tl')),
      isEmpty,
      reason:
          'Generator-only base must keep English fallback, not Latin Tagalog.',
    );
    expect(pilot.keys.toSet().difference(en.keys.toSet()), isEmpty);
    final review = File('docs/BAYBAYIN_REVIEW.md').readAsStringSync();
    for (final entry in pilot.entries) {
      final metadata = arb['@${entry.key}'] as Map<String, dynamic>;
      expect(metadata['description'], isNotEmpty, reason: entry.key);
      expect(metadata['x-latin'], isNotEmpty, reason: entry.key);
      expect(
        metadata['x-review-status'],
        isIn(['draft', 'needs-change', 'approved']),
      );
      expect(
        review,
        contains(
          '| `${entry.key}` | ${en[entry.key]} | ${metadata['description']} '
          '| ${metadata['x-latin']} | ${entry.value} | ${metadata['x-review-status']} |',
        ),
        reason: 'Keep the review row in sync with ${entry.key}.',
      );
    }
  });

  test('both scripts preserve every source placeholder', () {
    for (final entry in pilot.entries) {
      final latin =
          (arb['@${entry.key}'] as Map<String, dynamic>)['x-latin'] as String;
      expect(
        _placeholders(entry.value),
        _placeholders(en[entry.key]!),
        reason: entry.key,
      );
      expect(
        _placeholders(latin),
        _placeholders(en[entry.key]!),
        reason: entry.key,
      );
    }
  });

  test('reviewer corrections reach the pilot labels and related forms', () {
    final strings = lookupFlickLocalizations(kBaybayinLocale);
    expect(strings.songs14, 'ᜋᜅ ᜃᜈ᜔ᜆ');
    expect(strings.artists, 'ᜋᜅ ᜃᜓᜋᜈ᜔ᜆ');
    expect(strings.artist, 'ᜃᜓᜋᜈ᜔ᜆ');
    expect(strings.playlists, 'ᜋᜅ ᜆᜎᜀᜈ᜔ ᜈᜅ᜔ ᜃᜈ᜔ᜆ');
    expect(strings.playlist2, 'ᜆᜎᜀᜈ᜔ ᜈᜅ᜔ ᜃᜈ᜔ᜆ');
    expect(strings.nextSong, 'ᜐᜓᜐᜓᜈᜓᜇ᜔ ᜈ ᜃᜈ᜔ᜆ');
    expect(strings.previousSong, 'ᜈᜃᜇᜀᜅ᜔ ᜃᜈ᜔ᜆ');
    expect(strings.previousSong2, strings.previousSong);
    expect(strings.lyrics, 'ᜎᜒᜇᜒᜃ');
    expect(strings.allSongs, 'ᜎᜑᜆ᜔ ᜈᜅ᜔ ᜃᜈ᜔ᜆ');
    expect(strings.noSongsFound, 'ᜏᜎᜅ᜔ ᜈᜑᜈᜉ᜔ ᜈ ᜃᜈ᜔ᜆ');
    // The correction is for Next song, not onboarding's separate Next label.
    expect(strings.next, 'ᜐᜓᜐᜓᜈᜓᜇ᜔');
  });

  test('translated and fallback plurals and arguments survive generation', () {
    final strings = lookupFlickLocalizations(kBaybayinLocale);
    for (final count in [0, 1, 2, 101]) {
      expect(strings.songsCount(count), '$count ᜃᜈ᜔ᜆ');
      expect(strings.tracks(count), '$count ᜃᜈ᜔ᜆ');
      expect(strings.songUnit(count), count == 1 ? 'song' : 'songs');
    }
    expect(strings.songs('3:25', 7), '3:25 • 7 ᜃᜈ᜔ᜆ');
    expect(strings.repeat('MODE'), 'ᜂᜎᜒᜆ᜔: MODE');
    expect(strings.shuffle2('MODE'), 'ᜉᜄ᜔ᜑᜎᜓ: MODE');
    expect(strings.baybayinPilotDescription, en['baybayinPilotDescription']);
    expect(strings.flickReplay, en['flickReplay']);
    expect(strings.unknownArtist, en['unknownArtist']);
  });

  test(
    'the bundled fallback covers the script and its combining/final marks',
    () {
      final bytes = File(
        'assets/fonts/NotoSansTagalog-Regular.ttf',
      ).readAsBytesSync();
      final supported = _fontCodepoints(ByteData.sublistView(bytes));
      final required = <int>{
        // Complete modern Tagalog alphabet, not just this pilot's current glyphs.
        for (var char = 0x1700; char <= 0x1715; char++) char,
        0x171f, // archaic ra
        0x1735, 0x1736, // Philippine punctuation
        for (final message in pilot.values)
          ...message.runes.where((char) => char >= 0x1700 && char <= 0x1736),
      };
      expect(required.difference(supported), isEmpty);
      expect(AppTheme.fontFamilyFallback, contains('NotoSansTagalog'));
      expect(
        AppTheme.darkTheme.textTheme.bodyMedium!.fontFamilyFallback,
        contains('NotoSansTagalog'),
      );
      expect(
        File('assets/fonts/NotoSansTagalog-OFL.txt').readAsStringSync(),
        contains('SIL OPEN FONT LICENSE Version 1.1'),
      );
    },
  );
}
