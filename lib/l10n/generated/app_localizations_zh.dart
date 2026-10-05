// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get connectionNotices => '网络连接提示';

  @override
  String get connectionNoticesDescription => '显示离线和恢复连接提示';

  @override
  String get activateFallback => '启用回退';

  @override
  String get active => '已启用';

  @override
  String get adjustSpacingBetweenButtons => '调整按钮之间的间距';

  @override
  String get adjustTheSizeOfTheBottom => '调整底部栏的大小';

  @override
  String get adjustTheSizeOfTheIcons => '调整图标的大小';

  @override
  String get advanceToARandomCategory => '随机切换到一个分类';

  @override
  String get advanceToTheNextCategoryAlphabetically => '按字母顺序切换至下一个分类';

  @override
  String get advanceToTheNextMostRecently => '切换至最近添加的下一个分类';

  @override
  String get air => '空气感';

  @override
  String get alacAudio => 'ALAC 音频';

  @override
  String alacBit(Object arg1) {
    return 'ALAC ${arg1}bit';
  }

  @override
  String get album => '专辑';

  @override
  String get albumArt => '专辑封面';

  @override
  String get albums => '专辑';

  @override
  String get allFormats => '所有格式';

  @override
  String get allPass => '全通';

  @override
  String get allSongs => '所有歌曲';

  @override
  String get alphabetical => '按字母顺序';

  @override
  String get androidBlockedWritingToThisFile =>
      'Android 禁止写入此文件。请在设置中移除并重新添加该文件夹以授予编辑权限，然后重试。';

  @override
  String get appTitle => 'Flick 音乐播放器';

  @override
  String get appearance => '外观';

  @override
  String get appearsInTheOverflowMenu => '显示在溢出菜单中';

  @override
  String get artist => '艺术家';

  @override
  String get artists => '艺术家';

  @override
  String get artworkCard => '封面卡片';

  @override
  String get asmrDreams => 'ASMR 之梦';

  @override
  String atKhzBit(Object arg1, Object arg2) {
    return ' ${arg1}kHz/${arg2}bit';
  }

  @override
  String get autoCollapse => '自动收起';

  @override
  String get autoReconnect => '自动重连';

  @override
  String get back => '返回';

  @override
  String get backOnline => '已恢复在线';

  @override
  String get band => '频段';

  @override
  String get bandPass => '带通';

  @override
  String bandsActive(Object activeCount, Object arg1) {
    return '已启用 $activeCount/$arg1 个频段';
  }

  @override
  String bandsAdjusted2(Object adjustedCount, Object arg1) {
    return '已调整 $adjustedCount/$arg1 个频段';
  }

  @override
  String get barHeight => '栏高度';

  @override
  String get bass => '低音';

  @override
  String bit(Object depth) {
    return '${depth}bit';
  }

  @override
  String get bitDepth2 => '位深';

  @override
  String get bitDepths => '位深';

  @override
  String get bitPerfectUsbDac => '位完美（USB DAC）';

  @override
  String bitPerfectUsbDacCouldNot2(Object arg1) {
    return '无法为 $arg1 启用位完美（USB DAC）。请检查 USB 诊断。';
  }

  @override
  String bitPerfectUsbDacEnabledFor(Object arg1) {
    return '已为 $arg1 启用位完美（USB DAC）。';
  }

  @override
  String get boldSaturatedColorsFromAlbumArt => '来自专辑封面的浓郁饱和色彩。';

  @override
  String get bottomBar => '底部栏';

  @override
  String build(Object kAppVersion, Object kAppBuild) {
    return '$kAppVersion（build $kAppBuild）';
  }

  @override
  String get buttonSpacing => '按钮间距';

  @override
  String get buttons => '按钮';

  @override
  String get calmFrequencies => '平静频率';

  @override
  String get capabilitiesNotAvailable => '功能不可用';

  @override
  String get cast => '投放';

  @override
  String castingTo(Object deviceName) {
    return '正在投放到 $deviceName';
  }

  @override
  String get categories => '分类';

  @override
  String get channels => '声道';

  @override
  String channels3(Object ch) {
    return '$ch 声道';
  }

  @override
  String get cityBeats => '城市节拍';

  @override
  String get cleanStraightLineWithPrecisionScrubbing => '简洁直线，支持精细拖动定位。';

  @override
  String get collapseAfter => '收起延时';

  @override
  String get completelyHiddenFromTheBottomBar => '已从底栏完全隐藏';

  @override
  String get connect => '连接';

  @override
  String get connected => '已连接';

  @override
  String get connecting => '连接中';

  @override
  String get connectionManagement => '连接管理';

  @override
  String conversionFailed(Object error) {
    return '转换失败：$error';
  }

  @override
  String convertedSuccessfully(Object fileName) {
    return '$fileName 转换成功';
  }

  @override
  String get convertingAudio => '正在转换音频…';

  @override
  String convertingToWav(Object fileName) {
    return '正在将 $fileName 转换为 WAV…';
  }

  @override
  String get cosmicOrchestra => '宇宙管弦乐团';

  @override
  String get countingFiles => '正在统计文件…';

  @override
  String get crystalCaverns => '水晶洞窟';

  @override
  String get cueSheetTracksCannotBeEdited => 'CUE 表曲目无法编辑。';

  @override
  String get customizeAudioDisplayNavigationAnd => '自定义音频、显示、导航与集成。';

  @override
  String get customizeBottomBar => '自定义底部栏';

  @override
  String get daily => '每日';

  @override
  String get dateAdded => '添加日期';

  @override
  String db15(Object arg1, Object arg2) {
    return '$arg1%  $arg2 dB';
  }

  @override
  String get deactivateFallback => '停用回退';

  @override
  String get deepEarth => '大地深处';

  @override
  String get deviceCapabilities => '设备能力';

  @override
  String get deviceConnected => '设备已连接';

  @override
  String get deviceDacVolume => '设备 DAC 音量';

  @override
  String get deviceDisconnected => '设备已断开';

  @override
  String get deviceType => '设备类型';

  @override
  String get directUsb => 'USB 直连';

  @override
  String get disabled => '已禁用';

  @override
  String get disconnect => '断开';

  @override
  String get displayTextLabelsBelowIcons => '在图标下方显示文字标签';

  @override
  String get dragBandsUpOrDown => '上下拖动频段';

  @override
  String get dragToChangeFrequencyGain => '拖动调整频率与增益';

  @override
  String get dragToMovePinchToWiden => '拖动移动 • 捏合加宽/收窄';

  @override
  String get dragVerticallyToChangeGain => '垂直拖动调整增益';

  @override
  String get duration => '时长';

  @override
  String get equalizer => '均衡器';

  @override
  String error(Object error) {
    return '错误：$error';
  }

  @override
  String error2(Object arg1) {
    return '错误：$arg1';
  }

  @override
  String get error3 => '错误';

  @override
  String errorLoadingCapabilities(Object error) {
    return '加载能力失败：$error';
  }

  @override
  String get etherealTones => '空灵音色';

  @override
  String get exclusiveUsbBitPerfectReEngaged => '已重新启用 USB 独占位完美。';

  @override
  String get exclusiveUsbDroppedToTheAndroid =>
      '独占 USB 已回退到 Android 混音器。位完美已暂停。';

  @override
  String get exclusiveUsbIsStillUnavailableCheck => 'USB 独占仍不可用。请检查 USB 诊断。';

  @override
  String get externalSongsCannotBeEdited => '外部歌曲无法编辑。';

  @override
  String get failedToActivateFallback => '启用回退失败';

  @override
  String get failedToDeactivateFallback => '停用回退失败';

  @override
  String failedToSaveMetadata(Object e) {
    return '保存元数据失败：$e';
  }

  @override
  String get failedToStartStreaming => '无法启动音频流';

  @override
  String get failedToStopStreaming => '无法停止音频流';

  @override
  String get faintHueShiftFromAlbumArt => '来自专辑封面的轻微色相偏移。';

  @override
  String get fallbackAudio => '备用音频';

  @override
  String get fallbackAudioActivated => '已启用回退音频';

  @override
  String get fallbackAudioDeactivated => '已停用回退音频';

  @override
  String get fallbackAudioWillBeUsedIf => '若 UAC2 设备失效，将使用备用音频';

  @override
  String get favoriteAll => '全部收藏';

  @override
  String get favorites => '收藏';

  @override
  String get flat => '平坦';

  @override
  String get flickplayer => 'FlickPlayer';

  @override
  String get folder => '文件夹';

  @override
  String folderOf2(Object current, Object total) {
    return '第 $current 个文件夹，共 $total 个';
  }

  @override
  String get folders => '文件夹';

  @override
  String get frequency => '频率';

  @override
  String from(Object sourceLabel) {
    return '来自 $sourceLabel';
  }

  @override
  String get fullBleedAlbumArtWithThe => '满幅专辑封面，呈现当前的电影质感。';

  @override
  String get fullPlayer => '完整播放器';

  @override
  String get gain => '增益';

  @override
  String get getStarted => '开始使用';

  @override
  String get graphic => '图示';

  @override
  String get hardwareVolumeIsDetectedButWrites =>
      '检测到硬件音量，但 USB 直连实时播放期间写入仍被阻止。';

  @override
  String get havingMoreThan4ButtonsMay => '超过 4 个按钮可能导致文字标签被压缩。建议减小下方的按钮间距。';

  @override
  String get hidden => '已隐藏';

  @override
  String get hideNavigationButtonsAfterBeingIdle => '空闲后隐藏导航按钮';

  @override
  String get highPass => '高通';

  @override
  String get highShelf => '高架';

  @override
  String hz6(Object arg1) {
    return '$arg1 Hz';
  }

  @override
  String get iconSize => '图标大小';

  @override
  String get idle => '空闲';

  @override
  String get immersive => '沉浸式';

  @override
  String get inactive => '未启用';

  @override
  String get interactiveEq => '交互式均衡器';

  @override
  String get justAudioExoplayer => 'just_audio / ExoPlayer';

  @override
  String khz(Object arg1) {
    return '${arg1}kHz';
  }

  @override
  String khzBit(Object arg1, Object arg2) {
    return '${arg1}kHz/${arg2}bit';
  }

  @override
  String khzBit2(Object arg1, Object arg2) {
    return '${arg1}kHz/${arg2}bit';
  }

  @override
  String get language => '语言';

  @override
  String get languageSectionDescription => '选择应用界面使用的语言。';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get lateNightSessions => '深夜场';

  @override
  String get letSTakeAQuickTour => '快速了解你的新音乐播放器。';

  @override
  String get line => '线条';

  @override
  String get list => '列表';

  @override
  String get loadingArtwork2 => '正在加载封面…';

  @override
  String get lossless => ' 无损';

  @override
  String get losslessQualityPreservedDuringConversion => '转换过程中保持无损音质';

  @override
  String get lowPass => '低通';

  @override
  String get lowShelf => '低架';

  @override
  String get lyrics => '歌词';

  @override
  String get menu => '菜单';

  @override
  String get metropolitan => '大都会';

  @override
  String get mid => '中音';

  @override
  String get miniPlayer => '迷你播放器';

  @override
  String get moderate => '适中';

  @override
  String get mono => '单声道';

  @override
  String get monthly => '每月';

  @override
  String get more => '更多';

  @override
  String get mute => '静音';

  @override
  String nDb(Object arg1, Object arg2) {
    return '$arg1%\n$arg2 dB';
  }

  @override
  String get natureAmbient => '自然氛围';

  @override
  String get navigationBar => '导航栏';

  @override
  String get neonNights => '霓虹之夜';

  @override
  String get network => '网络';

  @override
  String get next => '下一步';

  @override
  String get noUsbAudioDevicesFound => '未找到 USB 音频设备';

  @override
  String get none => '无';

  @override
  String get notAnAlacFile => '不是 ALAC 文件';

  @override
  String get notch => '陷波';

  @override
  String get noticeableTintingFromAlbumArt => '来自专辑封面的明显着色。';

  @override
  String get numberOnArt => '封面编号';

  @override
  String get oceanWaves => '海浪';

  @override
  String get off => '关闭';

  @override
  String get openManual => '打开手册';

  @override
  String get orbital => 'Orbital';

  @override
  String get output => '输出';

  @override
  String get parametric => '参数';

  @override
  String get peaking => '峰值';

  @override
  String get pinchApartNarrowerHigherQNpinch =>
      '双指分开 = 更窄（Q 值更高）\n双指合拢 = 更宽（Q 值更低）';

  @override
  String get play => '播放';

  @override
  String get playAFewTracksTodayTo => '今天播放几首曲目，即可生成你的每日回顾。';

  @override
  String get playCategoriesInRandomOrderTracks => '分类随机顺序播放，曲目按顺序播放';

  @override
  String get playInOrder => '按顺序播放';

  @override
  String get playlist2 => '播放列表';

  @override
  String get playlists => '播放列表';

  @override
  String get preloadingAudio3 => '正在预加载音频';

  @override
  String get presence => '临场感';

  @override
  String get preview => '预览';

  @override
  String get prewarming => '预热中';

  @override
  String get queue => '队列';

  @override
  String get random => '随机';

  @override
  String get rating => '评分';

  @override
  String get reconnectAttempts => '重连次数';

  @override
  String get reconnectNow => '立即重连';

  @override
  String get reconnectionFailed => '重连失败';

  @override
  String get reconnectionSuccessful => '重连成功';

  @override
  String get refreshDevices2 => '刷新设备';

  @override
  String get removeFromFavorites2 => '取消收藏';

  @override
  String get reorderFilterAndShuffleFromThis => '在此标题栏可重新排序、筛选和随机播放。';

  @override
  String get resonance => '谐振';

  @override
  String get restart => '重启';

  @override
  String get restartRequired => '需要重启';

  @override
  String get retroFuture => '复古未来';

  @override
  String get retry => '重试';

  @override
  String get root => '根目录';

  @override
  String get roundedAlbumArtCardWithA => '圆角专辑封面卡片，配模糊的专辑封面背景。';

  @override
  String get rustViaOboe => '通过 Oboe 使用 Rust';

  @override
  String get rustViaOboeHighRes => '通过 Oboe 使用 Rust（高解析）';

  @override
  String sAgo(Object arg1) {
    return '$arg1 秒前';
  }

  @override
  String get sampleRate2 => '采样率';

  @override
  String get sampleRates => '采样率';

  @override
  String get samples => '采样数';

  @override
  String get scanProgress => '扫描进度';

  @override
  String get search => '搜索';

  @override
  String get searchAcrossSongsArtistsAndAlbums => '即时搜索歌曲、艺术家和专辑。';

  @override
  String get secondsOfInactivityBeforeCollapsing => '无操作多少秒后收起';

  @override
  String get selectDevice => '选择设备';

  @override
  String get separateFromNavBar => '与导航栏分离';

  @override
  String get settings => '设置';

  @override
  String get shadowJazz => '暗影爵士';

  @override
  String get share => '分享';

  @override
  String get showAlbumArtwork => '显示专辑封面。';

  @override
  String get showLabels => '显示标签';

  @override
  String get showMore => '显示更多';

  @override
  String get showTheMiniPlayerAsIts => '将迷你播放器显示为按钮上方的独立栏';

  @override
  String get showTheNumberOverBlurredArt => '在模糊封面上显示编号。';

  @override
  String showTheTabInTheBottom(Object arg1) {
    return '在底部栏显示 $arg1 标签页';
  }

  @override
  String get showTheTrackNumber => '显示曲目编号。';

  @override
  String get showsWhatSPlayingTapTo => '显示当前播放内容，点按打开完整播放器。';

  @override
  String get shuffle => '随机播放';

  @override
  String get shuffleSongsAndJumpBetweenCategories => '随机播放歌曲并在分类间跳转';

  @override
  String get shuffleSongsInCurrentList => '随机播放当前列表中的歌曲';

  @override
  String get skip => '跳过';

  @override
  String get sleepTimer2 => '睡眠定时';

  @override
  String get slope => '斜率';

  @override
  String get someOnlineFeaturesMayNotWork => '  ·  部分在线功能可能无法使用';

  @override
  String get songGestures => '歌曲手势';

  @override
  String get songs14 => '歌曲';

  @override
  String get songsCategories => '歌曲与分类';

  @override
  String get songsTab => '歌曲标签页';

  @override
  String get sortFilter => '排序与筛选';

  @override
  String get spaceOdyssey => '太空漫游';

  @override
  String get starlightSerenade => '星光小夜曲';

  @override
  String get startStreaming => '开始串流';

  @override
  String get state => '状态';

  @override
  String get status => '状态';

  @override
  String get stereo => '立体声';

  @override
  String get stop => '停止';

  @override
  String get stopStreaming => '停止串流';

  @override
  String get stormChasers => '追风者';

  @override
  String get streamConfigurationNotAvailable => '音频流配置不可用';

  @override
  String get streaming => '传输中';

  @override
  String get sub => '超低音';

  @override
  String get subtle => '淡雅';

  @override
  String get swipeLeftRightToSkipTracks => '左右滑动切换曲目';

  @override
  String get swipeToShowOrHideThe => '滑动以显示或隐藏可视化';

  @override
  String get switchSongs => '切换歌曲';

  @override
  String get synthwaveCity => '合成波之城';

  @override
  String get tagsWereWrittenButCouldNot =>
      '标签已写入，但未能通过重新读取文件确认。音乐库重新扫描会校正任何差异。';

  @override
  String get tapIconsToSwitchTabsLong => '点按图标切换标签页，长按可自定义导航栏。';

  @override
  String get tapTheMiniPlayerForWaveform => '点按迷你播放器，打开波形进度条、均衡器、歌词和可视化效果。';

  @override
  String get tapToPlayLongPressFor => '点按播放，长按查看更多选项（播放队列、下一首播放、信息）。';

  @override
  String get thatSTheTour => '导览到此结束！';

  @override
  String get thisMonthSRecap => '本月回顾';

  @override
  String get thisSongHasNoFilePath => '这首歌曲没有文件路径，无法编辑。';

  @override
  String get thisWeekSRecap => '本周回顾';

  @override
  String get thisYearSRecap => '今年回顾';

  @override
  String get thunderRoad => '雷霆之路';

  @override
  String get todaySRecap => '今日回顾';

  @override
  String get trackNumber => '曲目编号';

  @override
  String get trueRandomMayRepeatBeforeList => '完全随机（列表结束前可能重复）';

  @override
  String get uac2NotAvailableOnThisPlatform => '此平台不支持 UAC2';

  @override
  String get unableToCheckForUpdatesRight => '暂时无法检查更新。';

  @override
  String get undo => '撤销';

  @override
  String get unknown => '未知';

  @override
  String get unknownAlbum => '未知专辑';

  @override
  String get unknownArtist => '未知艺术家';

  @override
  String get unknownTitle => '未知标题';

  @override
  String get unmute => '取消静音';

  @override
  String get urbanEchoes => '城市回声';

  @override
  String get usbAudioDevice => 'USB 音频设备';

  @override
  String get usbAudioError => 'USB 音频错误';

  @override
  String get usbRouteVolume => 'USB 路由音量';

  @override
  String get usbVolume => 'USB 音量';

  @override
  String get useTheDefaultMonochromeTheme => '使用默认的单色主题。';

  @override
  String get variousArtists2 => '多位艺术家';

  @override
  String get velvetNoir => '暗夜天鹅绒';

  @override
  String get verticalBarsThatAnimateAcrossThe => '在屏幕上动画移动的垂直柱条。';

  @override
  String get vibrant => '鲜艳';

  @override
  String get visualizer => '可视化';

  @override
  String get volume => '音量';

  @override
  String get volumeIsFixedWhileBitPerfect2 =>
      '位完美直通启用时音量固定：音频流原样送出，而这个 DAC 没有硬件音量控制。';

  @override
  String get wantEveryControlDocumentedOpenThe =>
      '想了解每个控件的说明？随时可从「设置 → 帮助与手册」打开应用内手册。';

  @override
  String get waveform => '波形';

  @override
  String get weekly => '每周';

  @override
  String get welcomeToFlick2 => '欢迎使用 Flick';

  @override
  String get whisperWorld => '耳语世界';

  @override
  String get whisperedSecrets => '低语的秘密';

  @override
  String get wildWeather => '狂野天气';

  @override
  String get yearly => '每年';

  @override
  String get youReOffline => '你已离线';

  @override
  String get youReOfflineSomeOnlineFeatures => '你处于离线状态。部分在线功能可能无法使用。';

  @override
  String get yourMonthlyRecapNeedsABit => '本月再多听一些，你的每月回顾才会生成。';

  @override
  String get yourNewAudioEngineIsReady => '新的音频引擎已就绪，重启 Flick 即可生效。';

  @override
  String get yourWeeklyRecapAppearsOnceYou => '本周开始收听，你的每周回顾就会出现。';

  @override
  String get yourWholeLibraryLivesHereTap => '你的整个音乐库都在这里，点按任意歌曲即可播放。';

  @override
  String get yourYearlyRecapFillsInAs => '随着你全年持续收听，你的年度回顾会逐渐充实。';
}
