import 'package:flick/services/widget_replay_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WidgetReplaySnapshot.dayKey', () {
    test('zero-pads month and day', () {
      expect(WidgetReplaySnapshot.dayKey(DateTime(2026, 1, 5)), '2026-01-05');
      expect(WidgetReplaySnapshot.dayKey(DateTime(2026, 10, 14)), '2026-10-14');
    });

    test('ignores the time of day', () {
      expect(
        WidgetReplaySnapshot.dayKey(DateTime(2026, 10, 14, 23, 59, 59)),
        WidgetReplaySnapshot.dayKey(DateTime(2026, 10, 14)),
      );
    });
  });

  group('WidgetReplaySnapshot.deltaPercent', () {
    test('reports growth and decline against yesterday', () {
      expect(
        WidgetReplaySnapshot.deltaPercent(current: 120, previous: 100),
        20,
      );
      expect(WidgetReplaySnapshot.deltaPercent(current: 95, previous: 100), -5);
      expect(WidgetReplaySnapshot.deltaPercent(current: 100, previous: 100), 0);
    });

    test('rounds to the nearest whole percent', () {
      expect(
        WidgetReplaySnapshot.deltaPercent(current: 101, previous: 300),
        -66,
      );
      expect(WidgetReplaySnapshot.deltaPercent(current: 2, previous: 3), -33);
      expect(WidgetReplaySnapshot.deltaPercent(current: 4, previous: 3), 33);
    });

    test('is unknown when either day has no data', () {
      expect(
        WidgetReplaySnapshot.deltaPercent(current: 10, previous: 0),
        WidgetReplaySnapshot.unknownDelta,
      );
      expect(
        WidgetReplaySnapshot.deltaPercent(current: 0, previous: 10),
        WidgetReplaySnapshot.unknownDelta,
      );
      expect(
        WidgetReplaySnapshot.deltaPercent(current: 0, previous: 0),
        WidgetReplaySnapshot.unknownDelta,
      );
    });

    test('clamps extreme growth', () {
      expect(
        WidgetReplaySnapshot.deltaPercent(current: 1000000, previous: 1),
        999,
      );
    });
  });
}
