import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/app_colors.dart';
import 'package:flick/core/theme/adaptive_color_provider.dart';
import 'package:flick/models/mini_player_config.dart';
import 'package:flick/providers/providers.dart';
import 'package:flick/providers/mini_player_config_provider.dart';
import 'package:flick/widgets/common/mini_player_bar.dart';
import 'package:flick/widgets/navigation/flick_nav_bar.dart';
import 'package:flick/features/settings/widgets/settings_widgets.dart';

class MiniPlayerCustomization extends ConsumerWidget {
  const MiniPlayerCustomization({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(miniPlayerConfigProvider);
    final prefs = ref.watch(appPreferencesProvider);
    final notifier = ref.read(miniPlayerConfigProvider.notifier);

    Widget slider(
      String title,
      String subtitle,
      double value,
      double min,
      double max,
      int divisions,
      String display,
      MiniPlayerConfig Function(MiniPlayerConfig, double) change,
    ) => SliderSetting(
      icon: LucideIcons.ruler,
      title: title,
      subtitle: subtitle,
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      displayValue: display,
      onChanged: (value) => notifier.update((config) => change(config, value)),
    );

    Widget toggle(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      MiniPlayerConfig Function(MiniPlayerConfig, bool) change,
    ) => ToggleSetting(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: (value) => notifier.update((config) => change(config, value)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader('Preview'),
        const MiniPlayerPreview(),
        const SizedBox(height: AppConstants.spacingLg),
        const SettingsSectionHeader('Mini Player Layout'),
        SettingsCard(
          children: [
            ToggleSetting(
              icon: LucideIcons.split,
              title: 'Separate from Nav Bar',
              subtitle: 'Show the mini player as its own bar above the buttons',
              value: prefs.separateMiniPlayerFromNavBar,
              onChanged: (value) => ref
                  .read(appPreferencesProvider.notifier)
                  .setSeparateMiniPlayerFromNavBar(value),
            ),
            const SettingsDivider(),
            if (prefs.separateMiniPlayerFromNavBar) ...[
              _Choices<MiniPlayerWidthMode>(
                title: 'Width',
                value: config.widthMode,
                options: const {
                  MiniPlayerWidthMode.matchNavigation: 'Match navigation',
                  MiniPlayerWidthMode.custom: 'Custom',
                },
                onChanged: (value) =>
                    notifier.update((c) => c.copyWith(widthMode: value)),
              ),
              if (config.widthMode == MiniPlayerWidthMode.custom)
                slider(
                  'Custom Width',
                  'Centered; widens to fit your controls',
                  config.widthFraction,
                  0.7,
                  1,
                  30,
                  '${(config.widthFraction * 100).round()}%',
                  (c, value) => c.copyWith(widthFraction: value),
                ),
              const SettingsDivider(),
              slider(
                'Gap Above Navigation',
                'Space between the two bars',
                config.navigationGap,
                0,
                24,
                24,
                '${config.navigationGap.round()} dp',
                (c, value) => c.copyWith(navigationGap: value),
              ),
              const SettingsDivider(),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Text(
                  'Separate the mini player to customize its width and gap. '
                  'Your custom values are saved while joined.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.adaptiveTextSecondary,
                  ),
                ),
              ),
              const SettingsDivider(),
            ],
            slider(
              'Mini Player Height',
              'Grows further if larger system text needs room',
              config.height,
              48,
              88,
              40,
              '${config.height.round()} dp',
              (c, value) => c.copyWith(height: value),
            ),
            const SettingsDivider(),
            slider(
              'Corner Radius',
              'From square corners to a rounded bar',
              config.cornerRadius,
              0,
              32,
              32,
              '${config.cornerRadius.round()} dp',
              (c, value) => c.copyWith(cornerRadius: value),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        const SettingsSectionHeader('Content & Controls'),
        SettingsCard(
          children: [
            toggle(
              'Album Artwork',
              'Shown when there is room beside the controls',
              LucideIcons.image,
              config.showArtwork,
              (c, value) => c.copyWith(showArtwork: value),
            ),
            const SettingsDivider(),
            toggle(
              'Artist',
              'Show the artist below the song title',
              LucideIcons.type,
              config.showArtist,
              (c, value) => c.copyWith(showArtist: value),
            ),
            const SettingsDivider(),
            toggle(
              'Progress',
              'Show a thin playback progress line',
              LucideIcons.timer,
              config.showProgress,
              (c, value) => c.copyWith(showProgress: value),
            ),
            const SettingsDivider(),
            toggle(
              'Previous Song',
              'Add a previous-track button',
              LucideIcons.skipBack,
              config.showPrevious,
              (c, value) => c.copyWith(showPrevious: value),
            ),
            const SettingsDivider(),
            toggle(
              'Next Song',
              'Add a next-track button',
              LucideIcons.skipForward,
              config.showNext,
              (c, value) => c.copyWith(showNext: value),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        const SettingsSectionHeader('Mini Player Appearance'),
        SettingsCard(
          children: [
            slider(
              'Background Opacity',
              'Adjust the mini player surface',
              config.backgroundOpacity,
              0,
              1,
              100,
              '${(config.backgroundOpacity * 100).round()}%',
              (c, value) => c.copyWith(backgroundOpacity: value),
            ),
            const SettingsDivider(),
            toggle(
              'Border',
              'Outline the mini player',
              LucideIcons.square,
              config.showBorder,
              (c, value) => c.copyWith(showBorder: value),
            ),
            const SettingsDivider(),
            _Choices<MiniPlayerShadow>(
              title: 'Shadow',
              value: config.shadow,
              options: const {
                MiniPlayerShadow.off: 'Off',
                MiniPlayerShadow.subtle: 'Subtle',
                MiniPlayerShadow.strong: 'Strong',
              },
              onChanged: (value) =>
                  notifier.update((c) => c.copyWith(shadow: value)),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        const SettingsSectionHeader('Text & Gestures'),
        SettingsCard(
          children: [
            slider(
              'Text Size',
              'Also respects your system text size',
              config.textScale,
              0.85,
              1.3,
              45,
              '${(config.textScale * 100).round()}%',
              (c, value) => c.copyWith(textScale: value),
            ),
            const SettingsDivider(),
            _Choices<MiniPlayerTitleMode>(
              title: 'Long Song Titles',
              value: config.titleMode,
              options: const {
                MiniPlayerTitleMode.truncate: 'Truncate',
                MiniPlayerTitleMode.scroll: 'Scroll',
              },
              subtitle: 'Scrolling pauses when reduced motion is enabled',
              onChanged: (value) =>
                  notifier.update((c) => c.copyWith(titleMode: value)),
            ),
            const SettingsDivider(),
            SelectionSetting(
              icon: LucideIcons.audioLines,
              title: 'Visualizer',
              subtitle: 'Swipe to show or hide the visualizer',
              selected: prefs.miniPlayerSwipeAction == 'visualizer',
              onTap: () => ref
                  .read(appPreferencesProvider.notifier)
                  .setMiniPlayerSwipeAction('visualizer'),
            ),
            const SettingsDivider(),
            SelectionSetting(
              icon: LucideIcons.skipForward,
              title: 'Switch Songs',
              subtitle: 'Swipe left/right to skip tracks',
              selected: prefs.miniPlayerSwipeAction == 'switchSongs',
              onTap: () => ref
                  .read(appPreferencesProvider.notifier)
                  .setMiniPlayerSwipeAction('switchSongs'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextButton.icon(
          icon: const Icon(LucideIcons.rotateCcw, size: 18),
          label: const Text('Reset Mini Player to Defaults'),
          onPressed: () async {
            await Future.wait([
              notifier.reset(),
              ref
                  .read(appPreferencesProvider.notifier)
                  .setSeparateMiniPlayerFromNavBar(false),
              ref
                  .read(appPreferencesProvider.notifier)
                  .setMiniPlayerSwipeAction('visualizer'),
            ]);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mini player defaults restored')),
              );
            }
          },
        ),
      ],
    );
  }
}

class MiniPlayerPreview extends ConsumerStatefulWidget {
  const MiniPlayerPreview({super.key});

  @override
  ConsumerState<MiniPlayerPreview> createState() => _MiniPlayerPreviewState();
}

class _MiniPlayerPreviewState extends ConsumerState<MiniPlayerPreview> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final nav = ref.watch(navBarConfigProvider);
    final mini = ref.watch(miniPlayerConfigProvider);
    final separated = ref.watch(
      appPreferencesProvider.select(
        (prefs) => prefs.separateMiniPlayerFromNavBar,
      ),
    );
    final song = ref.watch(currentSongProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Expanded'),
              selected: !_collapsed,
              onSelected: (_) => setState(() => _collapsed = false),
            ),
            ChoiceChip(
              label: const Text('Collapsed'),
              selected: _collapsed,
              onSelected: (_) => setState(() => _collapsed = true),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            removeLeft: true,
            removeRight: true,
            child: ExcludeSemantics(
              child: AbsorbPointer(
                child: HeroMode(
                  enabled: false,
                  child: FlickNavBar(
                    currentIndex: nav.orderedButtons.first.pageIndex,
                    config: nav,
                    onTap: (_) {},
                    collapsed: _collapsed,
                    showMiniPlayer: true,
                    separateMiniPlayer: separated,
                    miniPlayerWidget: MiniPlayerBar(
                      config: mini,
                      separated: separated,
                      collapsed: _collapsed,
                      songId: song?.id ?? 'preview',
                      title:
                          song?.title ?? 'A song with a long title to preview',
                      artist: song?.artist ?? 'Sample artist',
                      albumArt: song?.albumArt,
                      audioSourcePath: song?.filePath,
                      progress: 0.42,
                      enableHero: false,
                      onPlayPause: () {},
                      onPrevious: () {},
                      onNext: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          song == null
              ? 'Sample song · preview only'
              : 'Current song · preview only',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.adaptiveTextSecondary),
        ),
      ],
    );
  }
}

class _Choices<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const _Choices({
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppConstants.spacingLg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: context.adaptiveTextPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.adaptiveTextSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppConstants.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final option in options.entries)
              ChoiceChip(
                label: Text(option.value),
                selected: value == option.key,
                onSelected: (_) => onChanged(option.key),
              ),
          ],
        ),
      ],
    ),
  );
}
