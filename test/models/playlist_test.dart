import 'package:flick/models/playlist.dart';
import 'package:flutter_test/flutter_test.dart';

Playlist _playlist() => Playlist(
  id: 'p1',
  name: 'Test',
  songIds: const ['song-1'],
  createdAt: DateTime(2024),
);

void main() {
  group('Playlist cover', () {
    test('copyWith sets a cover path', () {
      final playlist = _playlist().copyWith(coverPath: '/covers/p1.jpg');

      expect(playlist.coverPath, '/covers/p1.jpg');
    });

    test('copyWith preserves an existing cover path', () {
      final playlist = _playlist().copyWith(coverPath: '/covers/p1.jpg');

      expect(playlist.copyWith(name: 'Renamed').coverPath, '/covers/p1.jpg');
    });

    test('copyWith clearCoverPath removes the cover path', () {
      final playlist = _playlist().copyWith(coverPath: '/covers/p1.jpg');

      expect(playlist.copyWith(clearCoverPath: true).coverPath, isNull);
    });

    test('cover path survives a JSON round trip', () {
      final playlist = _playlist().copyWith(coverPath: '/covers/p1.jpg');
      final decoded = Playlist.fromJson(playlist.toJson());

      expect(decoded.coverPath, '/covers/p1.jpg');
    });

    test('legacy JSON without a cover path reads as null', () {
      final playlist = Playlist.fromJson({
        'id': 'p1',
        'name': 'Legacy',
        'songIds': ['song-1'],
        'createdAt': DateTime(2024).toIso8601String(),
      });

      expect(playlist.coverPath, isNull);
    });
  });
}
