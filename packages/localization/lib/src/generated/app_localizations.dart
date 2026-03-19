import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// No description provided for @commonPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get commonPause;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get commonStreak;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get commonUpgrade;

  /// No description provided for @commonPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get commonPremium;

  /// No description provided for @commonReadyToBegin.
  ///
  /// In en, this message translates to:
  /// **'Ready to begin'**
  String get commonReadyToBegin;

  /// No description provided for @commonPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get commonPaused;

  /// No description provided for @commonRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get commonRecentActivity;

  /// No description provided for @commonActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get commonActiveDays;

  /// No description provided for @commonMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get commonMode;

  /// No description provided for @commonPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get commonPlan;

  /// No description provided for @commonSeePremium.
  ///
  /// In en, this message translates to:
  /// **'See premium'**
  String get commonSeePremium;

  /// No description provided for @shellOpenMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get shellOpenMenuTooltip;

  /// No description provided for @shellUtilityAppMenu.
  ///
  /// In en, this message translates to:
  /// **'Utility app menu'**
  String get shellUtilityAppMenu;

  /// No description provided for @shellAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get shellAboutApp;

  /// No description provided for @shellSettingsConfig.
  ///
  /// In en, this message translates to:
  /// **'Settings / Config'**
  String get shellSettingsConfig;

  /// No description provided for @shellSubscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plan'**
  String get shellSubscriptionPlan;

  /// No description provided for @shellPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get shellPrivacy;

  /// No description provided for @shellFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get shellFeedback;

  /// No description provided for @shellAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About {appTitle}'**
  String shellAboutTitle(String appTitle);

  /// No description provided for @shellAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A reusable placeholder surface for app information. Hook the real destination in when the page is ready.'**
  String get shellAboutDescription;

  /// No description provided for @shellSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get shellSettingsTitle;

  /// No description provided for @shellSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Settings lives in the shared shell now. Wire in the real configuration screen when it is implemented.'**
  String get shellSettingsDescription;

  /// No description provided for @shellSubscriptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Subscription management can be connected here without cluttering the main task screen.'**
  String get shellSubscriptionDescription;

  /// No description provided for @shellPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add the privacy destination here when the shared legal pages are ready.'**
  String get shellPrivacyDescription;

  /// No description provided for @shellFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Route feedback and support flows here without changing the main app flow.'**
  String get shellFeedbackDescription;

  /// No description provided for @pomodoroTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Flow'**
  String get pomodoroTitle;

  /// No description provided for @pomodoroCurrentCycle.
  ///
  /// In en, this message translates to:
  /// **'Current cycle'**
  String get pomodoroCurrentCycle;

  /// No description provided for @pomodoroModeFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get pomodoroModeFocus;

  /// No description provided for @pomodoroModeShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get pomodoroModeShortBreak;

  /// No description provided for @pomodoroModeLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get pomodoroModeLongBreak;

  /// No description provided for @pomodoroFocusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Focus in progress'**
  String get pomodoroFocusInProgress;

  /// No description provided for @pomodoroBreakInProgress.
  ///
  /// In en, this message translates to:
  /// **'Break in progress'**
  String get pomodoroBreakInProgress;

  /// No description provided for @pomodoroFocusFootnote.
  ///
  /// In en, this message translates to:
  /// **'Stay with a single task until the timer ends.'**
  String get pomodoroFocusFootnote;

  /// No description provided for @pomodoroShortBreakFootnote.
  ///
  /// In en, this message translates to:
  /// **'Take a quick reset, then come back with clarity.'**
  String get pomodoroShortBreakFootnote;

  /// No description provided for @pomodoroLongBreakFootnote.
  ///
  /// In en, this message translates to:
  /// **'Step away for a longer recharge before the next block.'**
  String get pomodoroLongBreakFootnote;

  /// No description provided for @pomodoroStartFocusSession.
  ///
  /// In en, this message translates to:
  /// **'Start focus session'**
  String get pomodoroStartFocusSession;

  /// No description provided for @pomodoroStartBreak.
  ///
  /// In en, this message translates to:
  /// **'Start break'**
  String get pomodoroStartBreak;

  /// No description provided for @pomodoroPauseFocus.
  ///
  /// In en, this message translates to:
  /// **'Pause focus'**
  String get pomodoroPauseFocus;

  /// No description provided for @pomodoroPauseBreak.
  ///
  /// In en, this message translates to:
  /// **'Pause break'**
  String get pomodoroPauseBreak;

  /// No description provided for @pomodoroResumeFocus.
  ///
  /// In en, this message translates to:
  /// **'Resume focus'**
  String get pomodoroResumeFocus;

  /// No description provided for @pomodoroResumeBreak.
  ///
  /// In en, this message translates to:
  /// **'Resume break'**
  String get pomodoroResumeBreak;

  /// No description provided for @pomodoroTodaySessionsValue.
  ///
  /// In en, this message translates to:
  /// **'{count}/{goal} sessions'**
  String pomodoroTodaySessionsValue(int count, int goal);

  /// No description provided for @pomodoroFocusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus time'**
  String get pomodoroFocusTime;

  /// No description provided for @pomodoroSevenDaySummary.
  ///
  /// In en, this message translates to:
  /// **'7-day summary: {sessions} sessions | {minutes} minutes deep work'**
  String pomodoroSevenDaySummary(int sessions, int minutes);

  /// No description provided for @pomodoroFreeSessionsLeft.
  ///
  /// In en, this message translates to:
  /// **'{remaining} free focus sessions left today.'**
  String pomodoroFreeSessionsLeft(int remaining);

  /// No description provided for @pomodoroFocusLength.
  ///
  /// In en, this message translates to:
  /// **'Focus length'**
  String get pomodoroFocusLength;

  /// No description provided for @pomodoroCustomFocusPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom focus lengths are Premium'**
  String get pomodoroCustomFocusPremiumTitle;

  /// No description provided for @pomodoroUnlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium'**
  String get pomodoroUnlockPremium;

  /// No description provided for @pomodoroResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get pomodoroResetAction;

  /// No description provided for @pomodoroSkipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get pomodoroSkipAction;

  /// No description provided for @pomodoroAdvancedInsights.
  ///
  /// In en, this message translates to:
  /// **'Advanced insights'**
  String get pomodoroAdvancedInsights;

  /// No description provided for @pomodoroAverageFocus.
  ///
  /// In en, this message translates to:
  /// **'Avg focus'**
  String get pomodoroAverageFocus;

  /// No description provided for @pomodoroFocusNote.
  ///
  /// In en, this message translates to:
  /// **'Focus note'**
  String get pomodoroFocusNote;

  /// No description provided for @pomodoroFocusNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'What matters right now?'**
  String get pomodoroFocusNoteLabel;

  /// No description provided for @pomodoroFocusNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write the one thing this session is for.'**
  String get pomodoroFocusNoteHint;

  /// No description provided for @pomodoroSessionNotesPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Session notes are part of Premium'**
  String get pomodoroSessionNotesPremiumTitle;

  /// No description provided for @pomodoroHistoryItem.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m focus | {month}/{day} at {time}'**
  String pomodoroHistoryItem(int minutes, int month, int day, String time);

  /// No description provided for @fastingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting Flow'**
  String get fastingTitle;

  /// No description provided for @fastingCurrentFast.
  ///
  /// In en, this message translates to:
  /// **'Current fast'**
  String get fastingCurrentFast;

  /// No description provided for @fastingFastInProgress.
  ///
  /// In en, this message translates to:
  /// **'Fast in progress'**
  String get fastingFastInProgress;

  /// No description provided for @fastingStartFast.
  ///
  /// In en, this message translates to:
  /// **'Start fast'**
  String get fastingStartFast;

  /// No description provided for @fastingPauseFast.
  ///
  /// In en, this message translates to:
  /// **'Pause fast'**
  String get fastingPauseFast;

  /// No description provided for @fastingResumeFast.
  ///
  /// In en, this message translates to:
  /// **'Resume fast'**
  String get fastingResumeFast;

  /// No description provided for @fastingTodayFastsValue.
  ///
  /// In en, this message translates to:
  /// **'{count}/1 fast'**
  String fastingTodayFastsValue(int count);

  /// No description provided for @fastingLastFast.
  ///
  /// In en, this message translates to:
  /// **'Last fast'**
  String get fastingLastFast;

  /// No description provided for @fastingSevenDaySummary.
  ///
  /// In en, this message translates to:
  /// **'7-day summary: {fasts} fasts | {hours} total fasting'**
  String fastingSevenDaySummary(int fasts, String hours);

  /// No description provided for @fastingResetFast.
  ///
  /// In en, this message translates to:
  /// **'Reset fast'**
  String get fastingResetFast;

  /// No description provided for @fastingPremiumHistoryUnlock.
  ///
  /// In en, this message translates to:
  /// **'Premium unlocks your full fasting history.'**
  String get fastingPremiumHistoryUnlock;

  /// No description provided for @fastingDeeperInsights.
  ///
  /// In en, this message translates to:
  /// **'Deeper insights'**
  String get fastingDeeperInsights;

  /// No description provided for @fastingLongestFast.
  ///
  /// In en, this message translates to:
  /// **'Longest fast'**
  String get fastingLongestFast;

  /// No description provided for @fastingPremiumPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium unlocks extended fasting plans'**
  String get fastingPremiumPlansTitle;

  /// No description provided for @fastingPlanSummary.
  ///
  /// In en, this message translates to:
  /// **'{plan} plan | Eating window {window} | {description}'**
  String fastingPlanSummary(String plan, String window, String description);

  /// No description provided for @fastingHistoryItem.
  ///
  /// In en, this message translates to:
  /// **'{hours} fast | {month}/{day} at {time}'**
  String fastingHistoryItem(String hours, int month, int day, String time);

  /// No description provided for @fastingPlanReset12Description.
  ///
  /// In en, this message translates to:
  /// **'A balanced reset for building consistency.'**
  String get fastingPlanReset12Description;

  /// No description provided for @fastingPlanLean16Description.
  ///
  /// In en, this message translates to:
  /// **'The classic daily fasting rhythm.'**
  String get fastingPlanLean16Description;

  /// No description provided for @fastingPlanPerformance18Description.
  ///
  /// In en, this message translates to:
  /// **'A longer fast with a compact fueling block.'**
  String get fastingPlanPerformance18Description;

  /// No description provided for @fastingPlanDeep20Description.
  ///
  /// In en, this message translates to:
  /// **'A deep fast for experienced routines.'**
  String get fastingPlanDeep20Description;

  /// No description provided for @fastingEatingWindow12.
  ///
  /// In en, this message translates to:
  /// **'12h eating window'**
  String get fastingEatingWindow12;

  /// No description provided for @fastingEatingWindow8.
  ///
  /// In en, this message translates to:
  /// **'8h eating window'**
  String get fastingEatingWindow8;

  /// No description provided for @fastingEatingWindow6.
  ///
  /// In en, this message translates to:
  /// **'6h eating window'**
  String get fastingEatingWindow6;

  /// No description provided for @fastingEatingWindow4.
  ///
  /// In en, this message translates to:
  /// **'4h eating window'**
  String get fastingEatingWindow4;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
