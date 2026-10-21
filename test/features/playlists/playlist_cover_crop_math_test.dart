import 'package:flick/features/playlists/utils/playlist_cover_crop_math.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculatePlaylistCoverCrop', () {
    test('centered landscape image crops a centered square', () {
      final crop = calculatePlaylistCoverCrop(
        viewportSize: const Size(300, 300),
        imageSize: const Size(2000, 1000),
        transform: Matrix4.identity()..setTranslationRaw(-150, 0, 0),
      );

      expect(crop, const Rect.fromLTWH(500, 0, 1000, 1000));
    });

    test('portrait image crops a centered square', () {
      final crop = calculatePlaylistCoverCrop(
        viewportSize: const Size(300, 300),
        imageSize: const Size(1000, 2000),
        transform: Matrix4.identity()..setTranslationRaw(0, -150, 0),
      );

      expect(crop, const Rect.fromLTWH(0, 500, 1000, 1000));
    });

    test('zooming in reduces the source crop size', () {
      final transform = Matrix4.diagonal3Values(2.0, 2.0, 1.0)
        ..setTranslationRaw(-150, 0, 0);

      final crop = calculatePlaylistCoverCrop(
        viewportSize: const Size(300, 300),
        imageSize: const Size(2000, 1000),
        transform: transform,
      );

      expect(crop.left, closeTo(250, 0.001));
      expect(crop.top, 0);
      expect(crop.width, closeTo(500, 0.001));
      expect(crop.height, closeTo(500, 0.001));
    });

    test('returns zero for empty dimensions', () {
      expect(
        calculatePlaylistCoverCrop(
          viewportSize: Size.zero,
          imageSize: const Size(1000, 1000),
          transform: Matrix4.identity(),
        ),
        Rect.zero,
      );
    });
  });
}
