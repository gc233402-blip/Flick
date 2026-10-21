import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../core/utils/dev_log.dart';
import '../data/repositories/artist_repository.dart';
import '../models/song.dart';
import 'album_art_service.dart';
import 'sources/network_source_service.dart';

/// Provenance values stored in [ArtistEntity.artSource].
class ArtistArtSource {
  static const embeddedArtist = 'embeddedArtist';
  static const appleMusic = 'appleMusic';
  static const albumCover = 'albumCover';
  static const custom = 'custom';
}

/// Resolves artist pictures, preferring explicitly tagged embedded portraits
/// over album covers and online fallbacks.
class ArtistArtworkService {
  ArtistArtworkService._();

  static final ArtistArtworkService instance = ArtistArtworkService._();

  /// Re-check tags that had no portrait after a week, so a library update can
  /// surface newly added artwork without rescanning on every page open.
  static const Duration _retryAfter = Duration(days: 7);

  /// Tag parsing is I/O heavy; keep background tile lookups from saturating
  /// the disk while the user scrolls.
  static const int _maxConcurrentSearches = 2;

  late final ArtistRepository _artistRepository = ArtistRepository();
  final Map<String, Future<String?>> _inFlight = {};
  final Queue<Completer<void>> _searchQueue = Queue();
  int _activeSearches = 0;

  /// Return the best local artist picture for [artistName].
  ///
  /// Existing embedded/custom/online art short-circuits. Otherwise the songs'
  /// tags are searched for picture types 7, 8 or 10. When [thorough] is false
  /// only the first playable track is checked (used by list tiles); a miss is
  /// not cached so the detail page can still do the exhaustive pass.
  Future<String?> resolveForArtist({
    required String artistName,
    required List<Song> songs,
    bool thorough = true,
  }) async {
    if (artistName.isEmpty) return null;

    final key = '${artistName.toLowerCase()}|$thorough';
    final pending = _inFlight[key];
    if (pending != null) return pending;

    final future =
        _resolveForArtist(
          artistName: artistName,
          songs: songs,
          thorough: thorough,
        ).catchError((Object error) {
          devLog('Artist artwork resolution failed for $artistName: $error');
          return null;
        });
    _inFlight[key] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<String?> _resolveForArtist({
    required String artistName,
    required List<Song> songs,
    required bool thorough,
  }) async {
    final record = await _artistRepository.getByName(artistName);
    final artPath = record?.artPath;
    final source = record?.artSource;
    final hasArt =
        artPath != null &&
        artPath.isNotEmpty &&
        (artPath.startsWith('http') || await File(artPath).exists());

    if (hasArt &&
        (source == ArtistArtSource.embeddedArtist ||
            source == ArtistArtSource.appleMusic ||
            source == ArtistArtSource.custom)) {
      return artPath;
    }

    final checkedAt = record?.artCheckedAt;
    if (checkedAt != null &&
        DateTime.now().difference(checkedAt) < _retryAfter) {
      return hasArt ? artPath : null;
    }

    final resolved = await _withSearchSlot(
      () => _findEmbeddedArtistArt(songs, thorough: thorough),
    );
    if (resolved != null && resolved.isNotEmpty) {
      await _artistRepository.setArt(
        artistName,
        resolved,
        source: ArtistArtSource.embeddedArtist,
        checkedAt: DateTime.now(),
      );
      return resolved;
    }

    if (thorough) {
      // Remember the miss so the next page open does not parse every tag again.
      // The existing path/source is preserved as the album-cover fallback.
      await _artistRepository.setArt(
        artistName,
        hasArt ? artPath : null,
        checkedAt: DateTime.now(),
      );
    }
    return hasArt ? artPath : null;
  }

  Future<String?> _findEmbeddedArtistArt(
    List<Song> songs, {
    required bool thorough,
  }) async {
    final candidates = <String>[];
    final seenPaths = <String>{};

    for (final song in songs) {
      final path = song.filePath;
      if (path == null || path.isEmpty) continue;
      if (!seenPaths.add(path)) continue;

      final scheme = Uri.tryParse(path)?.scheme;
      if (isSupportedNetworkProtocol(scheme)) continue;

      candidates.add(path);
      // List tiles stay cheap; the detail page does the exhaustive pass.
      if (!thorough) break;
    }

    for (final path in candidates) {
      try {
        final art = await AlbumArtService.instance.resolveArtistArtworkPath(
          audioSourcePath: path,
        );
        if (art != null && art.isNotEmpty) return art;
      } catch (error) {
        devLog('Embedded artist artwork failed for $path: $error');
      }
    }
    return null;
  }

  Future<T> _withSearchSlot<T>(Future<T> Function() action) async {
    if (_activeSearches >= _maxConcurrentSearches) {
      final waiter = Completer<void>();
      _searchQueue.add(waiter);
      await waiter.future;
    }

    _activeSearches++;
    try {
      return await action();
    } finally {
      _activeSearches--;
      if (_searchQueue.isNotEmpty) {
        _searchQueue.removeFirst().complete();
      }
    }
  }
}
