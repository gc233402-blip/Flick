import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Maps the visible square crop viewport back to a rectangle in source-image
/// pixels.
///
/// The image is displayed at [imageSize] scaled by the larger of the viewport's
/// width/height ratios (cover fit), then transformed by [transform]. Only
/// scaling and translation are supported, which is all [InteractiveViewer]
/// produces.
Rect calculatePlaylistCoverCrop({
  required Size viewportSize,
  required Size imageSize,
  required Matrix4 transform,
}) {
  final viewportSide = viewportSize.shortestSide;
  if (viewportSide <= 0 || imageSize.width <= 0 || imageSize.height <= 0) {
    return Rect.zero;
  }

  final coverScale = math.max(
    viewportSide / imageSize.width,
    viewportSide / imageSize.height,
  );
  final scale = transform.getMaxScaleOnAxis();
  if (scale <= 0) return Rect.zero;

  final translation = transform.getTranslation();
  final maxSide = math.min(imageSize.width, imageSize.height);
  final side = math.min(maxSide, viewportSide / (scale * coverScale));
  final left = (-translation.x / scale) / coverScale;
  final top = (-translation.y / scale) / coverScale;

  return Rect.fromLTWH(
    left.clamp(0.0, imageSize.width - side),
    top.clamp(0.0, imageSize.height - side),
    side,
    side,
  );
}

/// Builds the [InteractiveViewer] transform that shows [cropCenter] with
/// [cropSide] filling the square viewport.
///
/// This is the inverse of [calculatePlaylistCoverCrop]. It is used after a
/// rotate/flip so the same framing survives the orientation change instead of
/// snapping back to the centre. The viewport is intentionally clamped to the
/// viewer's 1..4 zoom range.
Matrix4 calculatePlaylistCoverTransform({
  required Size viewportSize,
  required Size imageSize,
  required Offset cropCenter,
  required double cropSide,
}) {
  final viewportSide = viewportSize.shortestSide;
  if (viewportSide <= 0 ||
      imageSize.width <= 0 ||
      imageSize.height <= 0 ||
      cropSide <= 0) {
    return Matrix4.identity();
  }

  final coverScale = math.max(
    viewportSide / imageSize.width,
    viewportSide / imageSize.height,
  );
  final maxSide = math.min(imageSize.width, imageSize.height);
  final requestedSide = cropSide.clamp(1.0, maxSide).toDouble();
  final scale = (viewportSide / (requestedSide * coverScale))
      .clamp(1.0, 4.0)
      .toDouble();
  final effectiveSide = viewportSide / (scale * coverScale);

  final half = effectiveSide / 2;
  final centerX = cropCenter.dx.clamp(half, imageSize.width - half).toDouble();
  final centerY = cropCenter.dy.clamp(half, imageSize.height - half).toDouble();

  final translationX = viewportSide / 2 - centerX * coverScale * scale;
  final translationY = viewportSide / 2 - centerY * coverScale * scale;

  return Matrix4.identity()
    ..setTranslationRaw(translationX, translationY, 0)
    ..scaleByDouble(scale, scale, 1, 1);
}
