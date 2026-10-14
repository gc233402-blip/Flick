import 'dart:io';

/// Value helpers for the Flick Replay widget sync path, independent of the
/// library database.
class WidgetReplaySnapshot {
  WidgetReplaySnapshot._();

  /// Stored delta value that marks the previous day as not comparable.
  static const int unknownDelta = -1000;

  /// Native widgets can only load files, not remote/SAF URIs or directories.
  static String localCover(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final uri = Uri.parse(raw);
      if (uri.hasScheme && uri.scheme != 'file') return '';
      final file = uri.scheme == 'file' ? File.fromUri(uri) : File(raw);
      return FileSystemEntity.typeSync(file.path) == FileSystemEntityType.file
          ? file.path
          : '';
    } on FormatException {
      return '';
    } on FileSystemException {
      return '';
    }
  }

  /// Local-day key in the `yyyy-MM-dd` shape the native widget compares
  /// against its own date to detect a stale snapshot.
  static String dayKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Percent change clamped to ±999, or [unknownDelta] when either side is
  /// zero and a percentage would be meaningless.
  static int deltaPercent({required int current, required int previous}) {
    if (previous <= 0 || current <= 0) return unknownDelta;
    final percent = ((current - previous) / previous * 100).round();
    return percent.clamp(-999, 999);
  }
}
