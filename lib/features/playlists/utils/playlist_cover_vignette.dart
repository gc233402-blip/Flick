/// Shared vignette curve for the cover editor preview and the exported image.
///
/// The radius is normalized so the corners of a square sit at exactly 1.0.
/// The preview builds a radial gradient from [playlistCoverVignetteFactor] and
/// the export applies the same function per pixel, so what the user sees is
/// what gets written.
const double playlistCoverVignetteStart = 0.3;
const double playlistCoverVignetteEnd = 0.85;
const double playlistCoverVignetteRadius = 0.7071067811865476;

/// Returns how strongly a pixel at [normalizedDistance] is darkened.
///
/// [normalizedDistance] is 0 at the center and 1 at the corners of the square.
/// [amount] is the 0..1 vignette slider value.
double playlistCoverVignetteFactor({
  required double normalizedDistance,
  required double amount,
}) {
  if (amount <= 0) return 0;

  final t =
      ((normalizedDistance - playlistCoverVignetteStart) /
              (playlistCoverVignetteEnd - playlistCoverVignetteStart))
          .clamp(0.0, 1.0);
  final smooth = t * t * (3 - 2 * t);
  return smooth * amount.clamp(0.0, 1.0);
}
