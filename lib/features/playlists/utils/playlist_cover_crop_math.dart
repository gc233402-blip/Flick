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
