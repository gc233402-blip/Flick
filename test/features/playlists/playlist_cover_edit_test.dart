import 'package:image/image.dart' as img;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flick/features/playlists/utils/playlist_cover_edit.dart';
import 'package:flick/features/playlists/utils/playlist_cover_render.dart';
import 'package:flick/features/playlists/utils/playlist_cover_vignette.dart';

void main() {
  group('PlaylistCoverEdit', () {
    test('starts without edits', () {
      const edit = PlaylistCoverEdit();

      expect(edit.hasEdits, isFalse);
      expect(edit.colorMatrix.isIdentity, isTrue);
      expect(edit.manualColorMatrix.isIdentity, isTrue);
    });

    test('reports every kind of edit', () {
      expect(const PlaylistCoverEdit(quarterTurns: 1).hasEdits, isTrue);
      expect(const PlaylistCoverEdit(mirrored: true).hasEdits, isTrue);
      expect(const PlaylistCoverEdit(brightness: 0.1).hasEdits, isTrue);
      expect(const PlaylistCoverEdit(contrast: 0.1).hasEdits, isTrue);
      expect(const PlaylistCoverEdit(saturation: 0.1).hasEdits, isTrue);
      expect(const PlaylistCoverEdit(warmth: 0.1).hasEdits, isTrue);
      expect(const PlaylistCoverEdit(vignette: 0.1).hasEdits, isTrue);
      expect(
        const PlaylistCoverEdit(filter: PlaylistCoverFilter.mono).hasEdits,
        isTrue,
      );
    });

    test('swaps dimensions for odd quarter turns', () {
      const size = Size(100, 50);

      expect(const PlaylistCoverEdit().orientedSize(size), size);
      expect(
        const PlaylistCoverEdit(quarterTurns: 1).orientedSize(size),
        const Size(50, 100),
      );
      expect(const PlaylistCoverEdit(quarterTurns: 2).orientedSize(size), size);
      expect(
        const PlaylistCoverEdit(quarterTurns: 3).orientedSize(size),
        const Size(50, 100),
      );
    });

    test('four clockwise turns return to the original orientation', () {
      var edit = const PlaylistCoverEdit(
        filter: PlaylistCoverFilter.warm,
      ).rotateClockwise().rotateClockwise().rotateClockwise().rotateClockwise();

      expect(edit.quarterTurns, 0);
      expect(edit.mirrored, isFalse);
      expect(edit.filter, PlaylistCoverFilter.warm);
    });

    test('horizontal then vertical flip equals a 180 degree rotation', () {
      final edit = const PlaylistCoverEdit().flipHorizontal().flipVertical();

      expect(edit.quarterTurns, 2);
      expect(edit.mirrored, isFalse);
    });

    test('copyWith preserves unspecified values', () {
      const original = PlaylistCoverEdit(
        quarterTurns: 3,
        mirrored: true,
        brightness: 0.2,
        contrast: -0.1,
        saturation: 0.3,
        warmth: -0.4,
        vignette: 0.5,
        filter: PlaylistCoverFilter.noir,
      );

      final copy = original.copyWith(brightness: 0);

      expect(copy.quarterTurns, 3);
      expect(copy.mirrored, isTrue);
      expect(copy.brightness, 0);
      expect(copy.contrast, -0.1);
      expect(copy.saturation, 0.3);
      expect(copy.warmth, -0.4);
      expect(copy.vignette, 0.5);
      expect(copy.filter, PlaylistCoverFilter.noir);
    });
  });

  group('colour matrix', () {
    double channel(List<double> matrix, int row, double r, double g, double b) {
      return matrix[row * 5] * r +
          matrix[row * 5 + 1] * g +
          matrix[row * 5 + 2] * b +
          matrix[row * 5 + 3] * 255 +
          matrix[row * 5 + 4];
    }

    test('identity leaves colours untouched', () {
      final matrix = CoverColorMatrix.identity.values;

      expect(channel(matrix, 0, 12, 34, 56), closeTo(12, 0.0001));
      expect(channel(matrix, 1, 12, 34, 56), closeTo(34, 0.0001));
      expect(channel(matrix, 2, 12, 34, 56), closeTo(56, 0.0001));
    });

    test('brightness offsets all channels', () {
      final matrix = const PlaylistCoverEdit(brightness: 1).colorMatrix.values;

      expect(channel(matrix, 0, 100, 100, 100), closeTo(145.9, 0.0001));
      expect(channel(matrix, 1, 100, 100, 100), closeTo(145.9, 0.0001));
      expect(channel(matrix, 2, 100, 100, 100), closeTo(145.9, 0.0001));
    });

    test('warmth shifts red up and blue down', () {
      final matrix = const PlaylistCoverEdit(warmth: 1).colorMatrix.values;

      expect(channel(matrix, 0, 100, 100, 100), closeTo(112, 0.0001));
      expect(channel(matrix, 1, 100, 100, 100), closeTo(100, 0.0001));
      expect(channel(matrix, 2, 100, 100, 100), closeTo(88, 0.0001));
    });

    test('manual adjustments compose warmth then brightness', () {
      final matrix = const PlaylistCoverEdit(
        warmth: 1,
        brightness: 1,
      ).colorMatrix.values;

      expect(channel(matrix, 0, 100, 100, 100), closeTo(157.9, 0.0001));
      expect(channel(matrix, 1, 100, 100, 100), closeTo(145.9, 0.0001));
      expect(channel(matrix, 2, 100, 100, 100), closeTo(133.9, 0.0001));
    });

    test('full desaturation uses Rec. 709 luma', () {
      final matrix = const PlaylistCoverEdit(saturation: -1).colorMatrix.values;
      final luma = 0.2126 * 200 + 0.7152 * 100 + 0.0722 * 50;

      expect(channel(matrix, 0, 200, 100, 50), closeTo(luma, 0.0001));
      expect(channel(matrix, 1, 200, 100, 50), closeTo(luma, 0.0001));
      expect(channel(matrix, 2, 200, 100, 50), closeTo(luma, 0.0001));
    });

    test('mono filter produces equal channels', () {
      final matrix = const PlaylistCoverEdit(
        filter: PlaylistCoverFilter.mono,
      ).colorMatrix.values;
      final red = channel(matrix, 0, 200, 100, 50);
      final green = channel(matrix, 1, 200, 100, 50);
      final blue = channel(matrix, 2, 200, 100, 50);

      expect(red, closeTo(116.83, 0.1));
      expect(green, closeTo(red, 0.0001));
      expect(blue, closeTo(red, 0.0001));
    });

    test('filters stack with manual adjustments', () {
      final monoOnly = const PlaylistCoverEdit(
        filter: PlaylistCoverFilter.mono,
      ).colorMatrix;
      final withBrightness = const PlaylistCoverEdit(
        filter: PlaylistCoverFilter.mono,
        brightness: 1,
      ).colorMatrix;

      expect(withBrightness.values[0], closeTo(monoOnly.values[0], 0.0001));
      // Brightness is applied after the filter, so it adds to the filter's
      // own -10.24 offset (contrast 1.08 around 128) rather than replacing it.
      expect(
        withBrightness.values[4],
        closeTo(monoOnly.values[4] + 45.9, 0.0001),
      );
    });

    test('original filter is identity', () {
      expect(
        const PlaylistCoverEdit(
          filter: PlaylistCoverFilter.original,
        ).colorMatrix.isIdentity,
        isTrue,
      );
    });
  });

  group('orientation state', () {
    img.Image baseImage() {
      final image = img.Image(width: 3, height: 2);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          image.setPixelRgb(x, y, 20 + x * 10, 40 + y * 10, 60 + x + y);
        }
      }
      return image;
    }

    void expectSamePixels(img.Image actual, img.Image expected) {
      expect(actual.width, expected.width);
      expect(actual.height, expected.height);
      for (var y = 0; y < actual.height; y++) {
        for (var x = 0; x < actual.width; x++) {
          final actualPixel = actual.getPixel(x, y);
          final expectedPixel = expected.getPixel(x, y);
          expect(actualPixel.r.toInt(), expectedPixel.r.toInt());
          expect(actualPixel.g.toInt(), expectedPixel.g.toInt());
          expect(actualPixel.b.toInt(), expectedPixel.b.toInt());
        }
      }
    }

    test('rotate and flip operations match direct image transforms', () {
      for (var quarterTurns = 0; quarterTurns < 4; quarterTurns++) {
        for (final mirrored in [false, true]) {
          final edit = PlaylistCoverEdit(
            quarterTurns: quarterTurns,
            mirrored: mirrored,
          );

          final oldImage = applyPlaylistCoverOrientation(
            baseImage(),
            quarterTurns: quarterTurns,
            mirrored: mirrored,
          );

          void check(PlaylistCoverEdit next, img.Image direct) {
            final actual = applyPlaylistCoverOrientation(
              baseImage(),
              quarterTurns: next.quarterTurns,
              mirrored: next.mirrored,
            );
            expectSamePixels(actual, direct);
          }

          check(edit.rotateClockwise(), img.copyRotate(oldImage, angle: 90));
          check(
            edit.rotateCounterClockwise(),
            img.copyRotate(oldImage, angle: 270),
          );
          check(edit.flipHorizontal(), img.flipHorizontal(oldImage.clone()));
          check(edit.flipVertical(), img.flipVertical(oldImage.clone()));
        }
      }
    });

    test('orientation is applied before the crop in the editor contract', () {
      final edit = const PlaylistCoverEdit(quarterTurns: 1);
      final oriented = applyPlaylistCoverOrientation(
        baseImage(),
        quarterTurns: edit.quarterTurns,
        mirrored: edit.mirrored,
      );

      expect(edit.orientedSize(const Size(3, 2)), const Size(2, 3));
      expect(oriented.width, 2);
      expect(oriented.height, 3);
    });
  });

  group('vignette curve', () {
    test('is zero at the centre and outside the start radius', () {
      expect(playlistCoverVignetteFactor(normalizedDistance: 0, amount: 1), 0);
      expect(
        playlistCoverVignetteFactor(normalizedDistance: 0.2, amount: 1),
        0,
      );
      expect(
        playlistCoverVignetteFactor(
          normalizedDistance: playlistCoverVignetteStart,
          amount: 1,
        ),
        0,
      );
    });

    test('reaches the requested amount at the end radius and corners', () {
      expect(
        playlistCoverVignetteFactor(
          normalizedDistance: playlistCoverVignetteEnd,
          amount: 0.8,
        ),
        closeTo(0.8, 0.0001),
      );
      expect(
        playlistCoverVignetteFactor(normalizedDistance: 1, amount: 0.8),
        closeTo(0.8, 0.0001),
      );
    });

    test('uses a smoothstep between start and end', () {
      final midpoint =
          (playlistCoverVignetteStart + playlistCoverVignetteEnd) / 2;

      expect(
        playlistCoverVignetteFactor(normalizedDistance: midpoint, amount: 1),
        closeTo(0.5, 0.0001),
      );
    });

    test('zero amount disables the effect', () {
      expect(playlistCoverVignetteFactor(normalizedDistance: 1, amount: 0), 0);
    });
  });
}
