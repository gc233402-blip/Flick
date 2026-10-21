import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/app_theme.dart';
import 'package:flick/features/playlists/widgets/playlist_sort_bottom_sheet.dart';
import 'package:flick/features/songs/widgets/sort_filter_bottom_sheet.dart';
import 'package:flick/providers/songs_provider.dart';
import 'package:flick/widgets/common/detail_header.dart';
import 'package:flick/widgets/common/glass_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _systemInset = EdgeInsets.only(bottom: 34);

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: _systemInset),
        child: Scaffold(body: child),
      ),
    ),
  );
}

Container _surfaceContainer(WidgetTester tester) {
  final finder = find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.decoration == AppBottomSheetSurface.decoration,
  );
  expect(finder, findsOneWidget);
  return tester.widget<Container>(finder);
}

void main() {
  group('AppBottomSheetSurface', () {
    testWidgets(
      'paints to the bottom edge and keeps the system inset as content padding',
      (tester) async {
        await tester.pumpWidget(
          _host(const AppBottomSheetSurface(child: SizedBox(height: 100))),
        );

        final container = _surfaceContainer(tester);
        final padding = container.padding! as EdgeInsets;
        expect(padding.bottom, AppConstants.spacingLg + _systemInset.bottom);

        final surfaceRect = tester.getRect(find.byWidget(container));
        final screenRect = tester.getRect(find.byType(Scaffold));
        expect(surfaceRect.bottom, screenRect.bottom);
      },
    );

    testWidgets('respects a custom padding and still adds the system inset', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const AppBottomSheetSurface(
            padding: EdgeInsets.zero,
            child: SizedBox(height: 100),
          ),
        ),
      );

      final container = _surfaceContainer(tester);
      final padding = container.padding! as EdgeInsets;
      expect(padding, EdgeInsets.only(bottom: _systemInset.bottom));
    });
  });

  group('GlassBottomSheet', () {
    testWidgets('adds the system inset to its default bottom padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const GlassBottomSheet(content: SizedBox(height: 100))),
      );

      final container = _surfaceContainer(tester);
      final padding = container.padding! as EdgeInsets;
      expect(padding.bottom, AppConstants.spacingLg + _systemInset.bottom);
    });
  });

  group('DetailMoreSheet', () {
    testWidgets('matches Sort By typography, spacing, and row alignment', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PlaylistSortBottomSheet(
            currentSort: PlaylistSortOption.artist,
            onSortChanged: (_) {},
          ),
        ),
      );

      final sortTitle = tester.widget<Text>(find.text('SORT BY'));
      final sortLabel = tester.widget<Text>(find.text('Manual Order'));
      final sortIcon = tester.widget<Icon>(
        find.byIcon(LucideIcons.gripVertical),
      );
      final sortTitlePosition = tester.getTopLeft(find.text('SORT BY'));
      final sortIconRect = tester.getRect(
        find.byIcon(LucideIcons.gripVertical),
      );
      final sortLabelLeft = tester.getTopLeft(find.text('Manual Order')).dx;
      final sortRowSize = tester.getSize(find.byType(InkWell).first);
      final sortPadding = tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .padding;

      await tester.pumpWidget(
        _host(
          DetailMoreSheet(
            items: [
              DetailMoreSheetItem(
                icon: LucideIcons.imagePlus,
                label: 'Change cover',
                onTap: () {},
              ),
              DetailMoreSheetItem(
                icon: LucideIcons.imageOff,
                label: 'Remove cover',
                onTap: () {},
              ),
            ],
          ),
        ),
      );

      final title = tester.widget<Text>(find.text('MORE'));
      final label = tester.widget<Text>(find.text('Change cover'));
      expect(title.style, sortTitle.style);
      expect(label.style, sortLabel.style);
      expect(tester.getTopLeft(find.text('MORE')), sortTitlePosition);
      expect(tester.getRect(find.byIcon(LucideIcons.imagePlus)), sortIconRect);
      expect(tester.getSize(find.byType(InkWell).first), sortRowSize);
      expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .padding,
        sortPadding,
      );

      for (final iconData in [LucideIcons.imagePlus, LucideIcons.imageOff]) {
        final icon = tester.widget<Icon>(find.byIcon(iconData));
        expect(icon.size, sortIcon.size);
        expect(icon.color, sortIcon.color);
        expect(tester.getTopLeft(find.byIcon(iconData)).dx, sortIconRect.left);
      }
      for (final label in ['Change cover', 'Remove cover']) {
        expect(tester.getTopLeft(find.text(label)).dx, sortLabelLeft);
      }
    });

    testWidgets('scrolls long action lists within the sheet height limit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          DetailMoreSheet(
            items: List.generate(
              20,
              (index) => DetailMoreSheetItem(
                icon: LucideIcons.imagePlus,
                label: 'Action $index',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final surface = _surfaceContainer(tester);
      final screenHeight = tester.getSize(find.byType(Scaffold)).height;
      expect(tester.getSize(find.byWidget(surface)).height, screenHeight * 0.7);
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      expect(find.text('Action 19').hitTestable(), findsOneWidget);
    });

    testWidgets('dismisses before running the selected action once', (
      tester,
    ) async {
      var calls = 0;
      late BuildContext sheetContext;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => DetailMoreSheet.show(
                context,
                items: [
                  DetailMoreSheetItem(
                    icon: LucideIcons.imagePlus,
                    label: 'Change cover',
                    onTap: () {
                      calls++;
                      expect(ModalRoute.of(sheetContext)!.isCurrent, isFalse);
                    },
                  ),
                ],
              ),
              child: const Text('Open More'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open More'));
      await tester.pumpAndSettle();
      sheetContext = tester.element(find.byType(DetailMoreSheet));
      await tester.tap(find.text('Change cover'));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(find.byType(DetailMoreSheet), findsNothing);
    });
  });

  group('standalone sheets', () {
    testWidgets('use the shared bottom sheet material', (tester) async {
      await tester.pumpWidget(
        _host(
          SortFilterBottomSheet(
            currentSort: SongSortOption.title,
            currentFilter: SongFileTypeFilter.all,
            onSortChanged: (_) {},
            onFilterChanged: (_) {},
          ),
        ),
      );

      _surfaceContainer(tester);
    });
  });
}
