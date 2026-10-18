import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:flick/features/settings/widgets/settings_widgets.dart';
import 'package:flick/l10n/l10n.dart';

/// Language choices keep their autonyms readable even in the draft pilot.
class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance,
      builder: (context, selectedLocale, _) {
        return SettingsCard(
          children: [
            SelectionSetting(
              icon: LucideIcons.smartphone,
              title: context.l10n.languageSystemDefault,
              subtitle: context.l10n.languageSectionDescription,
              selected: selectedLocale == null,
              onTap: () => LocaleController.instance.select(null),
            ),
            const SettingsDivider(),
            SelectionSetting(
              icon: LucideIcons.languages,
              title: '简体中文',
              subtitle: context.l10n.simplifiedChinese,
              selected: selectedLocale?.languageCode == 'zh',
              onTap: () =>
                  LocaleController.instance.select(const Locale('zh', 'CN')),
            ),
            const SettingsDivider(),
            SelectionSetting(
              icon: LucideIcons.globe,
              title: 'English',
              subtitle: context.l10n.english,
              selected: selectedLocale?.languageCode == 'en',
              onTap: () => LocaleController.instance.select(const Locale('en')),
            ),
            const SettingsDivider(),
            SelectionSetting(
              icon: LucideIcons.languages,
              title: 'Tagalog (Baybayin)',
              subtitle: context.l10n.baybayinPilotDescription,
              selected: selectedLocale == kBaybayinLocale,
              onTap: () => LocaleController.instance.select(kBaybayinLocale),
            ),
          ],
        );
      },
    );
  }
}
