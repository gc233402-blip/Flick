import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Connection notice visibility setting in Interface settings
  ///
  /// In en, this message translates to:
  /// **'Connection notices'**
  String get connectionNotices;

  /// Description of the connection notice visibility setting
  ///
  /// In en, this message translates to:
  /// **'Show offline and back-online notices'**
  String get connectionNoticesDescription;

  /// lib/widgets/uac2/uac2_fallback_manager.dart:179
  ///
  /// In en, this message translates to:
  /// **'Activate Fallback'**
  String get activateFallback;

  /// lib/features/player/widgets/bit_perfect_indicator.dart:670
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:275
  ///
  /// In en, this message translates to:
  /// **'Adjust spacing between buttons'**
  String get adjustSpacingBetweenButtons;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:259
  ///
  /// In en, this message translates to:
  /// **'Adjust the size of the bottom bar'**
  String get adjustTheSizeOfTheBottom;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:291
  ///
  /// In en, this message translates to:
  /// **'Adjust the size of the icons'**
  String get adjustTheSizeOfTheIcons;

  /// lib/models/advance_list_order.dart:15
  ///
  /// In en, this message translates to:
  /// **'Advance to a random category'**
  String get advanceToARandomCategory;

  /// lib/models/advance_list_order.dart:13
  ///
  /// In en, this message translates to:
  /// **'Advance to the next category alphabetically'**
  String get advanceToTheNextCategoryAlphabetically;

  /// lib/models/advance_list_order.dart:14
  ///
  /// In en, this message translates to:
  /// **'Advance to the next most recently added category'**
  String get advanceToTheNextMostRecently;

  /// lib/features/settings/screens/equalizer_screen.dart:1891
  ///
  /// In en, this message translates to:
  /// **'Air'**
  String get air;

  /// lib/widgets/alac_conversion_indicator.dart:128
  ///
  /// In en, this message translates to:
  /// **'ALAC Audio'**
  String get alacAudio;

  /// lib/widgets/alac_conversion_indicator.dart:79
  ///
  /// In en, this message translates to:
  /// **'ALAC {arg1}-bit'**
  String alacBit(Object arg1);

  /// lib/features/albums/widgets/identify_album_sheet.dart:263
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// lib/features/settings/screens/widget_settings_screen.dart:200
  ///
  /// In en, this message translates to:
  /// **'Album Art'**
  String get albumArt;

  /// lib/features/albums/screens/albums_screen.dart:252
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// lib/providers/songs_provider.dart:116
  ///
  /// In en, this message translates to:
  /// **'All Formats'**
  String get allFormats;

  /// lib/providers/equalizer_provider.dart:41
  ///
  /// In en, this message translates to:
  /// **'All Pass'**
  String get allPass;

  /// lib/models/playback_context.dart:15
  ///
  /// In en, this message translates to:
  /// **'All Songs'**
  String get allSongs;

  /// lib/models/advance_list_order.dart:7
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get alphabetical;

  /// lib/services/metadata_editor_service.dart:184
  ///
  /// In en, this message translates to:
  /// **'Android blocked writing to this file. Remove and re-add the folder in Settings to grant edit access, then try again.'**
  String get androidBlockedWritingToThisFile;

  /// Application name. Used by MaterialApp.onGenerateTitle and shown in the Android task switcher.
  ///
  /// In en, this message translates to:
  /// **'Flick Player'**
  String get appTitle;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:253
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:394
  ///
  /// In en, this message translates to:
  /// **'Appears in the overflow menu'**
  String get appearsInTheOverflowMenu;

  /// lib/features/albums/widgets/identify_album_sheet.dart:254
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// lib/features/artists/screens/artists_screen.dart:253
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// lib/features/player/widgets/player_layout_sheet.dart:203
  ///
  /// In en, this message translates to:
  /// **'Artwork Card'**
  String get artworkCard;

  /// lib/models/song.dart:367
  ///
  /// In en, this message translates to:
  /// **'ASMR Dreams'**
  String get asmrDreams;

  /// lib/widgets/uac2/uac2_connection_manager.dart:88
  ///
  /// In en, this message translates to:
  /// **' at {arg1}kHz/{arg2}bit'**
  String atKhzBit(Object arg1, Object arg2);

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:77
  ///
  /// In en, this message translates to:
  /// **'Auto Collapse'**
  String get autoCollapse;

  /// lib/widgets/uac2/uac2_connection_manager.dart:183
  ///
  /// In en, this message translates to:
  /// **'Auto-Reconnect'**
  String get autoReconnect;

  /// lib/features/onboarding/widgets/tutorial_overlay.dart:338
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// lib/widgets/common/offline_notice.dart:137
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get backOnline;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:211
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get band;

  /// lib/providers/equalizer_provider.dart:37
  ///
  /// In en, this message translates to:
  /// **'Band Pass'**
  String get bandPass;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:294
  ///
  /// In en, this message translates to:
  /// **'{activeCount}/{arg1} bands active'**
  String bandsActive(Object activeCount, Object arg1);

  /// lib/widgets/equalizer/interactive_eq_graph.dart:291
  ///
  /// In en, this message translates to:
  /// **'{adjustedCount}/{arg1} bands adjusted'**
  String bandsAdjusted2(Object adjustedCount, Object arg1);

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:258
  ///
  /// In en, this message translates to:
  /// **'Bar Height'**
  String get barHeight;

  /// lib/features/settings/screens/equalizer_screen.dart:1665
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get bass;

  /// lib/features/settings/screens/uac2_preferences_screen.dart:1361
  ///
  /// In en, this message translates to:
  /// **'{depth}bit'**
  String bit(Object depth);

  /// lib/features/settings/screens/uac2_preferences_screen.dart:1350
  ///
  /// In en, this message translates to:
  /// **'Bit Depth'**
  String get bitDepth2;

  /// lib/features/settings/screens/uac2_settings_screen.dart:569
  ///
  /// In en, this message translates to:
  /// **'Bit Depths'**
  String get bitDepths;

  /// lib/features/menu/screens/menu_screen.dart:512
  ///
  /// In en, this message translates to:
  /// **'Bit-perfect (USB DAC)'**
  String get bitPerfectUsbDac;

  /// lib/widgets/uac2/usb_bit_perfect_prompt.dart:274
  ///
  /// In en, this message translates to:
  /// **'Bit-perfect (USB DAC) could not be enabled for {arg1}. Check the USB diagnostics.'**
  String bitPerfectUsbDacCouldNot2(Object arg1);

  /// lib/widgets/uac2/usb_bit_perfect_prompt.dart:273
  ///
  /// In en, this message translates to:
  /// **'Bit-perfect (USB DAC) enabled for {arg1}.'**
  String bitPerfectUsbDacEnabledFor(Object arg1);

  /// lib/models/album_color_mode.dart:39
  ///
  /// In en, this message translates to:
  /// **'Bold, saturated colors from album art.'**
  String get boldSaturatedColorsFromAlbumArt;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:27
  ///
  /// In en, this message translates to:
  /// **'Bottom Bar'**
  String get bottomBar;

  /// lib/core/constants/app_constants.dart:6
  ///
  /// In en, this message translates to:
  /// **'{kAppVersion} (build {kAppBuild})'**
  String build(Object kAppVersion, Object kAppBuild);

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:274
  ///
  /// In en, this message translates to:
  /// **'Button Spacing'**
  String get buttonSpacing;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:110
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get buttons;

  /// lib/models/song.dart:313
  ///
  /// In en, this message translates to:
  /// **'Calm Frequencies'**
  String get calmFrequencies;

  /// lib/features/settings/screens/uac2_settings_screen.dart:529
  ///
  /// In en, this message translates to:
  /// **'Capabilities not available'**
  String get capabilitiesNotAvailable;

  /// lib/features/player/widgets/player_action_button_row.dart:843
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// Snack bar shown after starting a cast session.
  ///
  /// In en, this message translates to:
  /// **'Casting to {deviceName}'**
  String castingTo(Object deviceName);

  /// lib/models/shuffle_mode.dart:14
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// lib/features/player/widgets/bit_perfect_indicator.dart:620
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// lib/widgets/uac2/uac2_stream_config.dart:185
  ///
  /// In en, this message translates to:
  /// **'{ch} channels'**
  String channels3(Object ch);

  /// lib/models/song.dart:331
  ///
  /// In en, this message translates to:
  /// **'City Beats'**
  String get cityBeats;

  /// lib/models/progress_bar_style.dart:27
  ///
  /// In en, this message translates to:
  /// **'Clean straight line with precision scrubbing.'**
  String get cleanStraightLineWithPrecisionScrubbing;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:91
  ///
  /// In en, this message translates to:
  /// **'Collapse After'**
  String get collapseAfter;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:393
  ///
  /// In en, this message translates to:
  /// **'Completely hidden from the bottom bar'**
  String get completelyHiddenFromTheBottomBar;

  /// lib/features/settings/widgets/listenbrainz_settings_tile.dart:785
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// lib/features/settings/screens/bluetooth_settings_screen.dart:110
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// lib/features/settings/screens/uac2_settings_screen.dart:901
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// lib/widgets/uac2/uac2_connection_manager.dart:140
  ///
  /// In en, this message translates to:
  /// **'Connection Management'**
  String get connectionManagement;

  /// lib/widgets/alac_conversion_indicator.dart:249
  ///
  /// In en, this message translates to:
  /// **'Conversion failed: {error}'**
  String conversionFailed(Object error);

  /// lib/widgets/alac_conversion_indicator.dart:233
  ///
  /// In en, this message translates to:
  /// **'{fileName} converted successfully'**
  String convertedSuccessfully(Object fileName);

  /// lib/widgets/alac_conversion_indicator.dart:39
  ///
  /// In en, this message translates to:
  /// **'Converting audio...'**
  String get convertingAudio;

  /// lib/widgets/alac_conversion_indicator.dart:218
  ///
  /// In en, this message translates to:
  /// **'Converting {fileName} to WAV...'**
  String convertingToWav(Object fileName);

  /// lib/models/song.dart:322
  ///
  /// In en, this message translates to:
  /// **'Cosmic Orchestra'**
  String get cosmicOrchestra;

  /// lib/features/settings/screens/library_settings_screen.dart:985
  ///
  /// In en, this message translates to:
  /// **'Counting files…'**
  String get countingFiles;

  /// lib/models/song.dart:348
  ///
  /// In en, this message translates to:
  /// **'Crystal Caverns'**
  String get crystalCaverns;

  /// lib/services/metadata_editor_service.dart:67
  ///
  /// In en, this message translates to:
  /// **'CUE sheet tracks cannot be edited.'**
  String get cueSheetTracksCannotBeEdited;

  /// lib/providers/tutorial_provider.dart:44
  ///
  /// In en, this message translates to:
  /// **'Customize audio, display, navigation, and integrations.'**
  String get customizeAudioDisplayNavigationAnd;

  /// lib/widgets/navigation/flick_nav_bar.dart:463
  ///
  /// In en, this message translates to:
  /// **'Customize Bottom Bar'**
  String get customizeBottomBar;

  /// lib/data/repositories/recently_played_repository.dart:14
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// lib/features/folders/screens/folders_screen.dart:2596
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get dateAdded;

  /// lib/widgets/uac2/iso_volume_popup.dart:275
  ///
  /// In en, this message translates to:
  /// **'{arg1}%  {arg2} dB'**
  String db15(Object arg1, Object arg2);

  /// lib/widgets/uac2/uac2_fallback_manager.dart:178
  ///
  /// In en, this message translates to:
  /// **'Deactivate Fallback'**
  String get deactivateFallback;

  /// lib/models/song.dart:353
  ///
  /// In en, this message translates to:
  /// **'Deep Earth'**
  String get deepEarth;

  /// lib/widgets/uac2/uac2_device_capabilities.dart:38
  ///
  /// In en, this message translates to:
  /// **'Device Capabilities'**
  String get deviceCapabilities;

  /// lib/widgets/uac2/uac2_hotplug_monitor.dart:48
  ///
  /// In en, this message translates to:
  /// **'Device connected'**
  String get deviceConnected;

  /// lib/widgets/uac2/uac2_volume_control.dart:163
  ///
  /// In en, this message translates to:
  /// **'Device DAC Volume'**
  String get deviceDacVolume;

  /// lib/widgets/uac2/uac2_hotplug_monitor.dart:49
  ///
  /// In en, this message translates to:
  /// **'Device disconnected'**
  String get deviceDisconnected;

  /// lib/features/settings/screens/uac2_settings_screen.dart:553
  ///
  /// In en, this message translates to:
  /// **'Device Type'**
  String get deviceType;

  /// lib/widgets/uac2/uac2_player_status.dart:224
  ///
  /// In en, this message translates to:
  /// **'Direct USB'**
  String get directUsb;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:185
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// lib/features/settings/widgets/lastfm_settings_tile.dart:253
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:307
  ///
  /// In en, this message translates to:
  /// **'Display text labels below icons'**
  String get displayTextLabelsBelowIcons;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:129
  ///
  /// In en, this message translates to:
  /// **'Drag bands up or down'**
  String get dragBandsUpOrDown;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:161
  ///
  /// In en, this message translates to:
  /// **'Drag to change frequency & gain'**
  String get dragToChangeFrequencyGain;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:130
  ///
  /// In en, this message translates to:
  /// **'Drag to move • Pinch to widen/narrow'**
  String get dragToMovePinchToWiden;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:160
  ///
  /// In en, this message translates to:
  /// **'Drag vertically to change gain'**
  String get dragVerticallyToChangeGain;

  /// lib/features/settings/screens/audio_settings_screen.dart:330
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// lib/features/player/widgets/player_action_button_row.dart:756
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// lib/features/settings/screens/uac2_settings_screen.dart:226
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// lib/widgets/uac2/uac2_device_selector.dart:90
  ///
  /// In en, this message translates to:
  /// **'Error: {arg1}'**
  String error2(Object arg1);

  /// lib/features/settings/screens/uac2_settings_screen.dart:909
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error3;

  /// lib/widgets/uac2/uac2_device_capabilities.dart:89
  ///
  /// In en, this message translates to:
  /// **'Error loading capabilities: {error}'**
  String errorLoadingCapabilities(Object error);

  /// lib/models/song.dart:349
  ///
  /// In en, this message translates to:
  /// **'Ethereal Tones'**
  String get etherealTones;

  /// lib/widgets/uac2/usb_bit_perfect_prompt.dart:254
  ///
  /// In en, this message translates to:
  /// **'Exclusive USB bit-perfect re-engaged.'**
  String get exclusiveUsbBitPerfectReEngaged;

  /// lib/widgets/uac2/usb_bit_perfect_prompt.dart:291
  ///
  /// In en, this message translates to:
  /// **'Exclusive USB dropped to the Android mixer. Bit-perfect is paused.'**
  String get exclusiveUsbDroppedToTheAndroid;

  /// lib/widgets/uac2/usb_bit_perfect_prompt.dart:255
  ///
  /// In en, this message translates to:
  /// **'Exclusive USB is still unavailable. Check the USB diagnostics.'**
  String get exclusiveUsbIsStillUnavailableCheck;

  /// lib/services/metadata_editor_service.dart:73
  ///
  /// In en, this message translates to:
  /// **'External songs cannot be edited.'**
  String get externalSongsCannotBeEdited;

  /// lib/widgets/uac2/uac2_fallback_manager.dart:61
  ///
  /// In en, this message translates to:
  /// **'Failed to activate fallback'**
  String get failedToActivateFallback;

  /// lib/widgets/uac2/uac2_fallback_manager.dart:81
  ///
  /// In en, this message translates to:
  /// **'Failed to deactivate fallback'**
  String get failedToDeactivateFallback;

  /// lib/services/metadata_editor_service.dart:100
  ///
  /// In en, this message translates to:
  /// **'Failed to save metadata: {e}'**
  String failedToSaveMetadata(Object e);

  /// lib/widgets/uac2/uac2_stream_config.dart:270
  ///
  /// In en, this message translates to:
  /// **'Failed to start streaming'**
  String get failedToStartStreaming;

  /// lib/widgets/uac2/uac2_stream_config.dart:283
  ///
  /// In en, this message translates to:
  /// **'Failed to stop streaming'**
  String get failedToStopStreaming;

  /// lib/models/album_color_mode.dart:35
  ///
  /// In en, this message translates to:
  /// **'Faint hue shift from album art.'**
  String get faintHueShiftFromAlbumArt;

  /// lib/widgets/uac2/uac2_fallback_manager.dart:136
  ///
  /// In en, this message translates to:
  /// **'Fallback Audio'**
  String get fallbackAudio;

  /// lib/widgets/uac2/uac2_fallback_manager.dart:60
  ///
  /// In en, this message translates to:
  /// **'Fallback audio activated'**
  String get fallbackAudioActivated;

  /// lib/widgets/uac2/uac2_fallback_manager.dart:80
  ///
  /// In en, this message translates to:
  /// **'Fallback audio deactivated'**
  String get fallbackAudioDeactivated;

  /// lib/widgets/uac2/uac2_fallback_manager.dart:197
  ///
  /// In en, this message translates to:
  /// **'Fallback audio will be used if UAC2 device fails'**
  String get fallbackAudioWillBeUsedIf;

  /// lib/widgets/common/detail_header.dart:257
  ///
  /// In en, this message translates to:
  /// **'Favorite all'**
  String get favoriteAll;

  /// lib/features/favorites/screens/favorites_screen.dart:301
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// lib/services/eq_preset_service.dart:280
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flat;

  /// lib/features/settings/screens/app_info_settings_screen.dart:230
  ///
  /// In en, this message translates to:
  /// **'FlickPlayer'**
  String get flickplayer;

  /// lib/models/playback_context.dart:13
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// lib/widgets/common/floating_scan_progress.dart:403
  ///
  /// In en, this message translates to:
  /// **'Folder {current} of {total}'**
  String folderOf2(Object current, Object total);

  /// lib/features/folders/screens/folders_screen.dart:320
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// lib/features/settings/screens/equalizer_screen.dart:2611
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// lib/widgets/common/fetched_description.dart:41
  ///
  /// In en, this message translates to:
  /// **'From {sourceLabel}'**
  String from(Object sourceLabel);

  /// lib/models/player_screen_mode.dart:26
  ///
  /// In en, this message translates to:
  /// **'Full-bleed album art with the current cinematic look.'**
  String get fullBleedAlbumArtWithThe;

  /// lib/providers/tutorial_provider.dart:48
  ///
  /// In en, this message translates to:
  /// **'Full Player'**
  String get fullPlayer;

  /// lib/features/settings/screens/equalizer_screen.dart:2666
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get gain;

  /// lib/features/onboarding/screens/onboarding_screen.dart:269
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// lib/features/settings/screens/equalizer_screen.dart:4162
  ///
  /// In en, this message translates to:
  /// **'Graphic'**
  String get graphic;

  /// lib/widgets/uac2/uac2_volume_control.dart:246
  ///
  /// In en, this message translates to:
  /// **'Hardware volume is detected, but writes stay blocked while live direct USB playback is active.'**
  String get hardwareVolumeIsDetectedButWrites;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:241
  ///
  /// In en, this message translates to:
  /// **'Having more than 4 buttons may cause text labels to compress. Consider reducing the button spacing below.'**
  String get havingMoreThan4ButtonsMay;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:202
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:79
  ///
  /// In en, this message translates to:
  /// **'Hide navigation buttons after being idle'**
  String get hideNavigationButtonsAfterBeingIdle;

  /// lib/providers/equalizer_provider.dart:35
  ///
  /// In en, this message translates to:
  /// **'High Pass'**
  String get highPass;

  /// lib/providers/equalizer_provider.dart:31
  ///
  /// In en, this message translates to:
  /// **'High Shelf'**
  String get highShelf;

  /// lib/widgets/alac_conversion_indicator.dart:137
  ///
  /// In en, this message translates to:
  /// **'{arg1} Hz'**
  String hz6(Object arg1);

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:290
  ///
  /// In en, this message translates to:
  /// **'Icon Size'**
  String get iconSize;

  /// lib/features/settings/screens/uac2_settings_screen.dart:899
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// lib/features/player/widgets/player_layout_sheet.dart:278
  ///
  /// In en, this message translates to:
  /// **'Immersive'**
  String get immersive;

  /// lib/features/player/widgets/bit_perfect_indicator.dart:670
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:121
  ///
  /// In en, this message translates to:
  /// **'Interactive EQ'**
  String get interactiveEq;

  /// lib/features/settings/screens/uac2_preferences_screen.dart:758
  ///
  /// In en, this message translates to:
  /// **'just_audio / ExoPlayer'**
  String get justAudioExoplayer;

  /// lib/widgets/uac2/uac2_player_status.dart:186
  ///
  /// In en, this message translates to:
  /// **'{arg1}kHz'**
  String khz(Object arg1);

  /// lib/widgets/uac2/uac2_player_status.dart:77
  ///
  /// In en, this message translates to:
  /// **'{arg1}kHz/{arg2}bit'**
  String khzBit(Object arg1, Object arg2);

  /// lib/widgets/uac2/uac2_status_indicator.dart:51
  ///
  /// In en, this message translates to:
  /// **'{arg1}kHz/{arg2}bit'**
  String khzBit2(Object arg1, Object arg2);

  /// Settings entry label and the title of the language picker.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Helper text under the language setting.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used across the app.'**
  String get languageSectionDescription;

  /// Language option that follows the device locale.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// lib/models/song.dart:344
  ///
  /// In en, this message translates to:
  /// **'Late Night Sessions'**
  String get lateNightSessions;

  /// lib/providers/tutorial_provider.dart:8
  ///
  /// In en, this message translates to:
  /// **'Let\'s take a quick tour of your new music player.'**
  String get letSTakeAQuickTour;

  /// lib/models/progress_bar_style.dart:18
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get line;

  /// lib/models/song_view_mode.dart:19
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// lib/features/settings/screens/library_settings_screen.dart:961
  ///
  /// In en, this message translates to:
  /// **'Loading artwork…'**
  String get loadingArtwork2;

  /// lib/widgets/common/detail_header.dart:157
  ///
  /// In en, this message translates to:
  /// **' Lossless'**
  String get lossless;

  /// lib/widgets/alac_conversion_indicator.dart:158
  ///
  /// In en, this message translates to:
  /// **'Lossless quality preserved during conversion'**
  String get losslessQualityPreservedDuringConversion;

  /// lib/providers/equalizer_provider.dart:33
  ///
  /// In en, this message translates to:
  /// **'Low Pass'**
  String get lowPass;

  /// lib/providers/equalizer_provider.dart:29
  ///
  /// In en, this message translates to:
  /// **'Low Shelf'**
  String get lowShelf;

  /// lib/features/player/widgets/song_actions_sheet.dart:295
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// lib/models/nav_bar_config.dart:5
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// lib/models/song.dart:335
  ///
  /// In en, this message translates to:
  /// **'Metropolitan'**
  String get metropolitan;

  /// lib/features/settings/screens/equalizer_screen.dart:1680
  ///
  /// In en, this message translates to:
  /// **'Mid'**
  String get mid;

  /// lib/providers/tutorial_provider.dart:38
  ///
  /// In en, this message translates to:
  /// **'Mini Player'**
  String get miniPlayer;

  /// lib/models/album_color_mode.dart:24
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// lib/features/player/widgets/bit_perfect_indicator.dart:621
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get mono;

  /// lib/data/repositories/recently_played_repository.dart:16
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// lib/features/settings/screens/logs_screen.dart:322
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// lib/widgets/uac2/iso_volume_popup.dart:260
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// lib/widgets/uac2/iso_volume_popup.dart:292
  ///
  /// In en, this message translates to:
  /// **'{arg1}%\n{arg2} dB'**
  String nDb(Object arg1, Object arg2);

  /// lib/models/song.dart:317
  ///
  /// In en, this message translates to:
  /// **'Nature Ambient'**
  String get natureAmbient;

  /// lib/providers/tutorial_provider.dart:11
  ///
  /// In en, this message translates to:
  /// **'Navigation Bar'**
  String get navigationBar;

  /// lib/models/song.dart:357
  ///
  /// In en, this message translates to:
  /// **'Neon Nights'**
  String get neonNights;

  /// lib/models/playback_context.dart:16
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// lib/features/onboarding/screens/onboarding_screen.dart:269
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// lib/features/settings/screens/uac2_settings_screen.dart:289
  ///
  /// In en, this message translates to:
  /// **'No USB audio devices found'**
  String get noUsbAudioDevicesFound;

  /// lib/features/settings/screens/equalizer_screen.dart:3769
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// lib/widgets/alac_conversion_indicator.dart:112
  ///
  /// In en, this message translates to:
  /// **'Not an ALAC file'**
  String get notAnAlacFile;

  /// lib/providers/equalizer_provider.dart:39
  ///
  /// In en, this message translates to:
  /// **'Notch'**
  String get notch;

  /// lib/models/album_color_mode.dart:37
  ///
  /// In en, this message translates to:
  /// **'Noticeable tinting from album art.'**
  String get noticeableTintingFromAlbumArt;

  /// lib/models/song_tile_thumbnail_mode.dart:22
  ///
  /// In en, this message translates to:
  /// **'Number on Art'**
  String get numberOnArt;

  /// lib/models/song.dart:312
  ///
  /// In en, this message translates to:
  /// **'Ocean Waves'**
  String get oceanWaves;

  /// lib/features/settings/screens/audio_settings_screen.dart:189
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// lib/features/onboarding/widgets/tutorial_overlay.dart:345
  ///
  /// In en, this message translates to:
  /// **'Open Manual'**
  String get openManual;

  /// lib/models/song_view_mode.dart:17
  ///
  /// In en, this message translates to:
  /// **'Orbital'**
  String get orbital;

  /// lib/features/settings/screens/casting_settings_screen.dart:281
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// lib/features/settings/screens/equalizer_screen.dart:4169
  ///
  /// In en, this message translates to:
  /// **'Parametric'**
  String get parametric;

  /// lib/providers/equalizer_provider.dart:27
  ///
  /// In en, this message translates to:
  /// **'Peaking'**
  String get peaking;

  /// lib/widgets/equalizer/interactive_eq_graph.dart:158
  ///
  /// In en, this message translates to:
  /// **'Pinch apart = narrower (higher Q)\nPinch together = wider (lower Q)'**
  String get pinchApartNarrowerHigherQNpinch;

  /// lib/widgets/common/detail_header.dart:273
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// lib/data/repositories/recently_played_repository.dart:33
  ///
  /// In en, this message translates to:
  /// **'Play a few tracks today to build your daily recap.'**
  String get playAFewTracksTodayTo;

  /// lib/models/shuffle_mode.dart:22
  ///
  /// In en, this message translates to:
  /// **'Play categories in random order, tracks in sequence'**
  String get playCategoriesInRandomOrderTracks;

  /// lib/models/shuffle_mode.dart:19
  ///
  /// In en, this message translates to:
  /// **'Play in order'**
  String get playInOrder;

  /// lib/models/playback_context.dart:14
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist2;

  /// lib/features/menu/screens/menu_screen.dart:1446
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// lib/widgets/common/floating_scan_progress.dart:379
  ///
  /// In en, this message translates to:
  /// **'Preloading audio'**
  String get preloadingAudio3;

  /// lib/features/settings/screens/equalizer_screen.dart:1890
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get presence;

  /// lib/features/settings/screens/audio_settings_screen.dart:686
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// lib/features/settings/screens/uac2_settings_screen.dart:905
  ///
  /// In en, this message translates to:
  /// **'Prewarming'**
  String get prewarming;

  /// lib/features/menu/screens/menu_screen.dart:1081
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// lib/models/advance_list_order.dart:9
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// lib/features/manual/data/manual_data.dart:236
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// lib/widgets/uac2/uac2_connection_manager.dart:160
  ///
  /// In en, this message translates to:
  /// **'Reconnect Attempts'**
  String get reconnectAttempts;

  /// lib/widgets/uac2/uac2_connection_manager.dart:205
  ///
  /// In en, this message translates to:
  /// **'Reconnect Now'**
  String get reconnectNow;

  /// lib/widgets/uac2/uac2_connection_manager.dart:72
  ///
  /// In en, this message translates to:
  /// **'Reconnection failed'**
  String get reconnectionFailed;

  /// lib/widgets/uac2/uac2_connection_manager.dart:72
  ///
  /// In en, this message translates to:
  /// **'Reconnection successful'**
  String get reconnectionSuccessful;

  /// lib/widgets/uac2/uac2_device_selector.dart:179
  ///
  /// In en, this message translates to:
  /// **'Refresh devices'**
  String get refreshDevices2;

  /// lib/widgets/common/detail_header.dart:257
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites2;

  /// lib/providers/tutorial_provider.dart:28
  ///
  /// In en, this message translates to:
  /// **'Reorder, filter, and shuffle from this header.'**
  String get reorderFilterAndShuffleFromThis;

  /// lib/providers/equalizer_provider.dart:70
  ///
  /// In en, this message translates to:
  /// **'Resonance'**
  String get resonance;

  /// lib/widgets/common/engine_restart_notice.dart:88
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// lib/widgets/common/engine_restart_notice.dart:46
  ///
  /// In en, this message translates to:
  /// **'Restart required'**
  String get restartRequired;

  /// lib/models/song.dart:358
  ///
  /// In en, this message translates to:
  /// **'Retro Future'**
  String get retroFuture;

  /// lib/features/songs/screens/songs_screen.dart:1838
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// lib/services/sources/upnp_service.dart:239
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get root;

  /// lib/models/player_screen_mode.dart:28
  ///
  /// In en, this message translates to:
  /// **'Rounded album art card with a blurred album-art background.'**
  String get roundedAlbumArtCardWithA;

  /// lib/features/settings/screens/uac2_preferences_screen.dart:794
  ///
  /// In en, this message translates to:
  /// **'Rust via Oboe'**
  String get rustViaOboe;

  /// lib/models/audio_engine_type.dart:39
  ///
  /// In en, this message translates to:
  /// **'Rust via Oboe (high-res)'**
  String get rustViaOboeHighRes;

  /// lib/widgets/uac2/uac2_hotplug_monitor.dart:103
  ///
  /// In en, this message translates to:
  /// **'{arg1}s ago'**
  String sAgo(Object arg1);

  /// lib/features/settings/screens/uac2_preferences_screen.dart:1319
  ///
  /// In en, this message translates to:
  /// **'Sample Rate'**
  String get sampleRate2;

  /// lib/features/settings/screens/uac2_settings_screen.dart:560
  ///
  /// In en, this message translates to:
  /// **'Sample Rates'**
  String get sampleRates;

  /// lib/widgets/alac_conversion_indicator.dart:144
  ///
  /// In en, this message translates to:
  /// **'Samples'**
  String get samples;

  /// lib/widgets/common/floating_scan_progress.dart:489
  ///
  /// In en, this message translates to:
  /// **'Scan progress'**
  String get scanProgress;

  /// lib/providers/tutorial_provider.dart:21
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// lib/providers/tutorial_provider.dart:22
  ///
  /// In en, this message translates to:
  /// **'Search across songs, artists, and albums instantly.'**
  String get searchAcrossSongsArtistsAndAlbums;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:93
  ///
  /// In en, this message translates to:
  /// **'Seconds of inactivity before collapsing'**
  String get secondsOfInactivityBeforeCollapsing;

  /// lib/widgets/uac2/uac2_device_selector.dart:58
  ///
  /// In en, this message translates to:
  /// **'Select Device'**
  String get selectDevice;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:60
  ///
  /// In en, this message translates to:
  /// **'Separate from Nav Bar'**
  String get separateFromNavBar;

  /// lib/features/recap/screens/listening_recap_screen.dart:166
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// lib/models/song.dart:340
  ///
  /// In en, this message translates to:
  /// **'Shadow Jazz'**
  String get shadowJazz;

  /// lib/features/player/widgets/player_action_button_row.dart:676
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// lib/models/song_tile_thumbnail_mode.dart:29
  ///
  /// In en, this message translates to:
  /// **'Show album artwork.'**
  String get showAlbumArtwork;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:306
  ///
  /// In en, this message translates to:
  /// **'Show Labels'**
  String get showLabels;

  /// lib/features/songs/screens/songs_screen.dart:3180
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:61
  ///
  /// In en, this message translates to:
  /// **'Show the mini player as its own bar above the buttons'**
  String get showTheMiniPlayerAsIts;

  /// lib/models/song_tile_thumbnail_mode.dart:33
  ///
  /// In en, this message translates to:
  /// **'Show the number over blurred art.'**
  String get showTheNumberOverBlurredArt;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:165
  ///
  /// In en, this message translates to:
  /// **'Show the {arg1} tab in the bottom bar'**
  String showTheTabInTheBottom(Object arg1);

  /// lib/models/song_tile_thumbnail_mode.dart:31
  ///
  /// In en, this message translates to:
  /// **'Show the track number.'**
  String get showTheTrackNumber;

  /// lib/providers/tutorial_provider.dart:39
  ///
  /// In en, this message translates to:
  /// **'Shows what\'s playing. Tap to open the full player.'**
  String get showsWhatSPlayingTapTo;

  /// lib/widgets/common/detail_header.dart:267
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// lib/models/shuffle_mode.dart:21
  ///
  /// In en, this message translates to:
  /// **'Shuffle songs and jump between categories'**
  String get shuffleSongsAndJumpBetweenCategories;

  /// lib/models/shuffle_mode.dart:20
  ///
  /// In en, this message translates to:
  /// **'Shuffle songs in current list'**
  String get shuffleSongsInCurrentList;

  /// lib/features/onboarding/screens/onboarding_screen.dart:167
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// lib/features/player/widgets/sleep_timer_bottom_sheet.dart:55
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepTimer2;

  /// lib/providers/equalizer_provider.dart:64
  ///
  /// In en, this message translates to:
  /// **'Slope'**
  String get slope;

  /// lib/widgets/common/offline_notice.dart:185
  ///
  /// In en, this message translates to:
  /// **'  ·  Some online features may not work'**
  String get someOnlineFeaturesMayNotWork;

  /// lib/providers/tutorial_provider.dart:33
  ///
  /// In en, this message translates to:
  /// **'Song Gestures'**
  String get songGestures;

  /// lib/features/manual/data/manual_data.dart:29
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs14;

  /// lib/models/shuffle_mode.dart:13
  ///
  /// In en, this message translates to:
  /// **'Songs & Categories'**
  String get songsCategories;

  /// lib/providers/tutorial_provider.dart:16
  ///
  /// In en, this message translates to:
  /// **'Songs Tab'**
  String get songsTab;

  /// lib/providers/tutorial_provider.dart:27
  ///
  /// In en, this message translates to:
  /// **'Sort & Filter'**
  String get sortFilter;

  /// lib/models/song.dart:326
  ///
  /// In en, this message translates to:
  /// **'Space Odyssey'**
  String get spaceOdyssey;

  /// lib/models/song.dart:321
  ///
  /// In en, this message translates to:
  /// **'Starlight Serenade'**
  String get starlightSerenade;

  /// lib/widgets/uac2/uac2_stream_config.dart:207
  ///
  /// In en, this message translates to:
  /// **'Start Streaming'**
  String get startStreaming;

  /// lib/widgets/uac2/uac2_connection_manager.dart:152
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// lib/features/settings/screens/uac2_settings_screen.dart:87
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// lib/features/player/widgets/bit_perfect_indicator.dart:621
  ///
  /// In en, this message translates to:
  /// **'Stereo'**
  String get stereo;

  /// lib/features/settings/screens/library_settings_screen.dart:1399
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// lib/widgets/uac2/uac2_stream_config.dart:207
  ///
  /// In en, this message translates to:
  /// **'Stop Streaming'**
  String get stopStreaming;

  /// lib/models/song.dart:376
  ///
  /// In en, this message translates to:
  /// **'Storm Chasers'**
  String get stormChasers;

  /// lib/widgets/uac2/uac2_stream_config.dart:57
  ///
  /// In en, this message translates to:
  /// **'Stream configuration not available'**
  String get streamConfigurationNotAvailable;

  /// lib/features/settings/screens/uac2_settings_screen.dart:907
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get streaming;

  /// lib/features/settings/screens/equalizer_screen.dart:1887
  ///
  /// In en, this message translates to:
  /// **'Sub'**
  String get sub;

  /// lib/models/album_color_mode.dart:22
  ///
  /// In en, this message translates to:
  /// **'Subtle'**
  String get subtle;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:49
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right to skip tracks'**
  String get swipeLeftRightToSkipTracks;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:37
  ///
  /// In en, this message translates to:
  /// **'Swipe to show or hide the visualizer'**
  String get swipeToShowOrHideThe;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:48
  ///
  /// In en, this message translates to:
  /// **'Switch Songs'**
  String get switchSongs;

  /// lib/models/song.dart:308
  ///
  /// In en, this message translates to:
  /// **'Synthwave City'**
  String get synthwaveCity;

  /// lib/services/metadata_editor_service.dart:131
  ///
  /// In en, this message translates to:
  /// **'Tags were written but could not be confirmed by re-reading the file. A library rescan will reconcile any difference.'**
  String get tagsWereWrittenButCouldNot;

  /// lib/providers/tutorial_provider.dart:12
  ///
  /// In en, this message translates to:
  /// **'Tap icons to switch tabs. Long-press to customize the bar.'**
  String get tapIconsToSwitchTabsLong;

  /// lib/providers/tutorial_provider.dart:50
  ///
  /// In en, this message translates to:
  /// **'Tap the mini player for waveform seekbar, EQ, lyrics, and visualizer.'**
  String get tapTheMiniPlayerForWaveform;

  /// lib/providers/tutorial_provider.dart:34
  ///
  /// In en, this message translates to:
  /// **'Tap to play, long-press for options (queue, play next, info).'**
  String get tapToPlayLongPressFor;

  /// lib/providers/tutorial_provider.dart:53
  ///
  /// In en, this message translates to:
  /// **'That\'s the tour!'**
  String get thatSTheTour;

  /// lib/data/repositories/recently_played_repository.dart:25
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Recap'**
  String get thisMonthSRecap;

  /// lib/services/metadata_editor_service.dart:61
  ///
  /// In en, this message translates to:
  /// **'This song has no file path and cannot be edited.'**
  String get thisSongHasNoFilePath;

  /// lib/data/repositories/recently_played_repository.dart:24
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Recap'**
  String get thisWeekSRecap;

  /// lib/data/repositories/recently_played_repository.dart:26
  ///
  /// In en, this message translates to:
  /// **'This Year\'s Recap'**
  String get thisYearSRecap;

  /// lib/models/song.dart:375
  ///
  /// In en, this message translates to:
  /// **'Thunder Road'**
  String get thunderRoad;

  /// lib/data/repositories/recently_played_repository.dart:23
  ///
  /// In en, this message translates to:
  /// **'Today\'s Recap'**
  String get todaySRecap;

  /// lib/models/song_tile_thumbnail_mode.dart:20
  ///
  /// In en, this message translates to:
  /// **'Track Number'**
  String get trackNumber;

  /// lib/models/shuffle_mode.dart:23
  ///
  /// In en, this message translates to:
  /// **'True random (may repeat before list ends)'**
  String get trueRandomMayRepeatBeforeList;

  /// lib/widgets/uac2/uac2_device_selector.dart:20
  ///
  /// In en, this message translates to:
  /// **'UAC2 not available on this platform'**
  String get uac2NotAvailableOnThisPlatform;

  /// lib/providers/update_check_provider.dart:177
  ///
  /// In en, this message translates to:
  /// **'Unable to check for updates right now.'**
  String get unableToCheckForUpdatesRight;

  /// lib/features/favorites/screens/favorites_screen.dart:63
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// lib/features/albums/screens/album_detail_screen.dart:950
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// lib/data/repositories/recently_played_repository.dart:588
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get unknownAlbum;

  /// lib/data/repositories/recently_played_repository.dart:578
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// lib/services/playlist_service.dart:688
  ///
  /// In en, this message translates to:
  /// **'Unknown Title'**
  String get unknownTitle;

  /// lib/widgets/uac2/iso_volume_popup.dart:260
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// lib/models/song.dart:330
  ///
  /// In en, this message translates to:
  /// **'Urban Echoes'**
  String get urbanEchoes;

  /// lib/widgets/uac2/uac2_device_selector.dart:36
  ///
  /// In en, this message translates to:
  /// **'USB Audio Device'**
  String get usbAudioDevice;

  /// lib/widgets/uac2/uac2_error_notification.dart:55
  ///
  /// In en, this message translates to:
  /// **'USB Audio Error'**
  String get usbAudioError;

  /// lib/widgets/uac2/uac2_volume_control.dart:162
  ///
  /// In en, this message translates to:
  /// **'USB Route Volume'**
  String get usbRouteVolume;

  /// lib/features/player/widgets/player_action_button_row.dart:726
  ///
  /// In en, this message translates to:
  /// **'USB Volume'**
  String get usbVolume;

  /// lib/models/album_color_mode.dart:33
  ///
  /// In en, this message translates to:
  /// **'Use the default monochrome theme.'**
  String get useTheDefaultMonochromeTheme;

  /// lib/data/repositories/song_repository.dart:637
  ///
  /// In en, this message translates to:
  /// **'Various Artists'**
  String get variousArtists2;

  /// lib/models/song.dart:339
  ///
  /// In en, this message translates to:
  /// **'Velvet Noir'**
  String get velvetNoir;

  /// lib/models/progress_bar_style.dart:25
  ///
  /// In en, this message translates to:
  /// **'Vertical bars that animate across the screen.'**
  String get verticalBarsThatAnimateAcrossThe;

  /// lib/models/album_color_mode.dart:26
  ///
  /// In en, this message translates to:
  /// **'Vibrant'**
  String get vibrant;

  /// lib/features/settings/screens/bottom_bar_settings_screen.dart:36
  ///
  /// In en, this message translates to:
  /// **'Visualizer'**
  String get visualizer;

  /// No description provided for @visualizerColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get visualizerColors;

  /// No description provided for @visualizerAlbumColorsDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the album cover colors; monochrome when unavailable'**
  String get visualizerAlbumColorsDescription;

  /// No description provided for @visualizerRainbow.
  ///
  /// In en, this message translates to:
  /// **'Rainbow'**
  String get visualizerRainbow;

  /// No description provided for @visualizerRainbowDescription.
  ///
  /// In en, this message translates to:
  /// **'A spectrum of colors across the visualizer'**
  String get visualizerRainbowDescription;

  /// No description provided for @visualizerMonochrome.
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get visualizerMonochrome;

  /// No description provided for @visualizerMonochromeDescription.
  ///
  /// In en, this message translates to:
  /// **'White and gray, independent of the album cover'**
  String get visualizerMonochromeDescription;

  /// No description provided for @visualizerBlocks.
  ///
  /// In en, this message translates to:
  /// **'Fading Blocks'**
  String get visualizerBlocks;

  /// No description provided for @visualizerBlocksDescription.
  ///
  /// In en, this message translates to:
  /// **'Segmented bars with softly fading trails'**
  String get visualizerBlocksDescription;

  /// lib/features/player/widgets/bit_perfect_indicator.dart:646
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// lib/widgets/uac2/uac2_volume_control.dart:236
  ///
  /// In en, this message translates to:
  /// **'Volume is fixed while bit-perfect passthrough is active: the stream is sent untouched and this DAC has no hardware volume control.'**
  String get volumeIsFixedWhileBitPerfect2;

  /// lib/providers/tutorial_provider.dart:55
  ///
  /// In en, this message translates to:
  /// **'Want every control documented? Open the in-app Manual anytime from Settings → Help & Manual.'**
  String get wantEveryControlDocumentedOpenThe;

  /// lib/models/progress_bar_style.dart:16
  ///
  /// In en, this message translates to:
  /// **'Waveform'**
  String get waveform;

  /// lib/data/repositories/recently_played_repository.dart:15
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// lib/providers/tutorial_provider.dart:7
  ///
  /// In en, this message translates to:
  /// **'Welcome to Flick'**
  String get welcomeToFlick2;

  /// lib/models/song.dart:371
  ///
  /// In en, this message translates to:
  /// **'Whisper World'**
  String get whisperWorld;

  /// lib/models/song.dart:366
  ///
  /// In en, this message translates to:
  /// **'Whispered Secrets'**
  String get whisperedSecrets;

  /// lib/models/song.dart:380
  ///
  /// In en, this message translates to:
  /// **'Wild Weather'**
  String get wildWeather;

  /// lib/data/repositories/recently_played_repository.dart:17
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// lib/widgets/common/offline_notice.dart:180
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get youReOffline;

  /// lib/widgets/common/offline_notice.dart:136
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Some online features may not work.'**
  String get youReOfflineSomeOnlineFeatures;

  /// lib/data/repositories/recently_played_repository.dart:37
  ///
  /// In en, this message translates to:
  /// **'Your monthly recap needs a bit more listening time this month.'**
  String get yourMonthlyRecapNeedsABit;

  /// lib/widgets/common/engine_restart_notice.dart:54
  ///
  /// In en, this message translates to:
  /// **'Your new audio engine is ready. Restart Flick to apply it.'**
  String get yourNewAudioEngineIsReady;

  /// lib/data/repositories/recently_played_repository.dart:35
  ///
  /// In en, this message translates to:
  /// **'Your weekly recap appears once you start listening this week.'**
  String get yourWeeklyRecapAppearsOnceYou;

  /// lib/providers/tutorial_provider.dart:17
  ///
  /// In en, this message translates to:
  /// **'Your whole library lives here. Tap any song to play it.'**
  String get yourWholeLibraryLivesHereTap;

  /// lib/data/repositories/recently_played_repository.dart:39
  ///
  /// In en, this message translates to:
  /// **'Your yearly recap fills in as you keep listening throughout the year.'**
  String get yourYearlyRecapFillsInAs;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
