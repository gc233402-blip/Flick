import 'package:isar_community/isar.dart';

part 'artist_entity.g.dart';

/// Database entity for caching per-artist metadata.
@collection
class ArtistEntity {
  Id id = Isar.autoIncrement;

  /// Canonical artist name. Case-insensitive unique.
  @Index(unique: true, caseSensitive: false)
  late String name;

  /// Path to a local image file used as the artist's picture. Null when no
  /// artist-specific image has been found.
  String? artPath;

  /// Where [artPath] came from: 'embeddedArtist', 'appleMusic', 'albumCover',
  /// or 'custom'. Null on records written before source tracking existed.
  ///
  /// The Isar name sorts after existing properties so their schema ids stay
  /// stable when this field is added to an existing database.
  @Name('zArtSource')
  String? artSource;

  /// When embedded artist artwork was last searched for. Prevents rescanning
  /// every track of an artist on each page open when the tags have no portrait.
  @Name('zArtCheckedAt')
  DateTime? artCheckedAt;
}
