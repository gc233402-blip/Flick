// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flick 音乐播放器';

  @override
  String get language => '语言';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get languageSectionDescription => '选择应用界面使用的语言。';

  @override
  String castingTo(Object deviceName) {
    return '正在投放到 $deviceName';
  }
}
