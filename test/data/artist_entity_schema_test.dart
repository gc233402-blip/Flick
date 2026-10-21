import 'package:flick/data/entities/artist_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ArtistEntity keeps existing Isar property ids stable', () {
    // Isar identifies persisted properties by numeric id, not by name. New
    // fields must be named (via @Name) so they sort after these two, otherwise
    // an existing library would be read with shifted columns.
    expect(ArtistEntitySchema.properties['artPath']?.id, 0);
    expect(ArtistEntitySchema.properties['name']?.id, 1);
    expect(ArtistEntitySchema.properties['zArtCheckedAt']?.id, 2);
    expect(ArtistEntitySchema.properties['zArtSource']?.id, 3);
  });
}
