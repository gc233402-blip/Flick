import 'package:isar_community/isar.dart';

import '../database.dart';

/// Repository for cached per-artist metadata.
class ArtistRepository {
  final Isar _isar;

  ArtistRepository({Isar? isar}) : _isar = isar ?? Database.instance;

  /// Look up an artist record by name (case-insensitive).
  Future<ArtistEntity?> getByName(String name) async {
    if (name.isEmpty) return null;
    return _isar.artistEntitys
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
  }

  /// Set or clear the cached art path for an artist.
  ///
  /// [source] and [checkedAt] are only written when provided, so callers that
  /// only refresh the path do not erase provenance.
  Future<void> setArt(
    String name,
    String? artPath, {
    String? source,
    DateTime? checkedAt,
  }) async {
    if (name.isEmpty) return;
    await _isar.writeTxn(() async {
      final existing = await _isar.artistEntitys
          .filter()
          .nameEqualTo(name, caseSensitive: false)
          .findFirst();

      if (existing != null) {
        final pathChanged = existing.artPath != artPath;
        final sourceChanged = source != null && existing.artSource != source;
        final checkedChanged =
            checkedAt != null && existing.artCheckedAt != checkedAt;
        if (!pathChanged && !sourceChanged && !checkedChanged) return;

        if (pathChanged) {
          existing.artPath = artPath;
          // A missing file is no longer a usable fallback; drop its stale
          // provenance unless the caller is explicitly assigning a new one.
          if (artPath == null && source == null) existing.artSource = null;
        }
        if (source != null) existing.artSource = source;
        if (checkedAt != null) existing.artCheckedAt = checkedAt;
        await _isar.artistEntitys.put(existing);
        return;
      }

      final entity = ArtistEntity()
        ..name = name
        ..artPath = artPath
        ..artSource = source
        ..artCheckedAt = checkedAt;
      await _isar.artistEntitys.put(entity);
    });
  }

  /// Artwork paths still referenced by artist records. The artwork cache uses
  /// this so embedded portraits are not pruned as unreferenced files.
  Future<Set<String>> getReferencedArtPaths() async {
    final entities = await _isar.artistEntitys.where().findAll();
    return entities
        .map((entity) => entity.artPath)
        .whereType<String>()
        .where((path) => path.isNotEmpty)
        .toSet();
  }

  Future<void> clearArt(String name) async {
    if (name.isEmpty) return;
    await _isar.writeTxn(() async {
      final existing = await _isar.artistEntitys
          .filter()
          .nameEqualTo(name, caseSensitive: false)
          .findFirst();
      if (existing == null) return;
      existing.artPath = null;
      existing.artSource = null;
      existing.artCheckedAt = null;
      await _isar.artistEntitys.put(existing);
    });
  }
}
