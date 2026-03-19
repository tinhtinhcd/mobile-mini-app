// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonStart => 'Start';

  @override
  String get commonPause => 'Pause';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonStreak => 'Streak';

  @override
  String get commonToday => 'Today';

  @override
  String get commonUpgrade => 'Upgrade';

  @override
  String get commonPremium => 'Premium';

  @override
  String get commonReadyToBegin => 'Ready to begin';

  @override
  String get commonPaused => 'Paused';

  @override
  String get commonRecentActivity => 'Recent activity';

  @override
  String get commonActiveDays => 'Active days';

  @override
  String get commonMode => 'Mode';

  @override
  String get commonPlan => 'Plan';

  @override
  String get commonMomentum => 'Momentum';

  @override
  String get commonDailyGoal => 'Daily goal';

  @override
  String get commonWeeklyRhythm => 'Weekly rhythm';

  @override
  String get commonSeePremium => 'See premium';

  @override
  String get shellOpenMenuTooltip => 'Open menu';

  @override
  String get shellUtilityAppMenu => 'Utility app menu';

  @override
  String get shellAboutApp => 'About App';

  @override
  String get shellSettingsConfig => 'Settings / Config';

  @override
  String get shellSubscriptionPlan => 'Subscription Plan';

  @override
  String get shellPrivacy => 'Privacy';

  @override
  String get shellFeedback => 'Feedback';

  @override
  String shellAboutTitle(String appTitle) {
    return 'About $appTitle';
  }

  @override
  String get shellAboutDescription =>
      'A reusable placeholder surface for app information. Hook the real destination in when the page is ready.';

  @override
  String get shellSettingsTitle => 'Settings';

  @override
  String get shellSettingsDescription =>
      'Settings lives in the shared shell now. Wire in the real configuration screen when it is implemented.';

  @override
  String get shellSubscriptionDescription =>
      'Subscription management can be connected here without cluttering the main task screen.';

  @override
  String get shellPrivacyDescription =>
      'Add the privacy destination here when the shared legal pages are ready.';

  @override
  String get shellFeedbackDescription =>
      'Route feedback and support flows here without changing the main app flow.';

  @override
  String get pomodoroTitle => 'Focus Flow';

  @override
  String get pomodoroCurrentCycle => 'Current cycle';

  @override
  String get pomodoroModeFocus => 'Focus';

  @override
  String get pomodoroModeShortBreak => 'Short break';

  @override
  String get pomodoroModeLongBreak => 'Long break';

  @override
  String get pomodoroFocusInProgress => 'Focus in progress';

  @override
  String get pomodoroBreakInProgress => 'Break in progress';

  @override
  String get pomodoroFocusFootnote =>
      'Stay with a single task until the timer ends.';

  @override
  String get pomodoroShortBreakFootnote =>
      'Take a quick reset, then come back with clarity.';

  @override
  String get pomodoroLongBreakFootnote =>
      'Step away for a longer recharge before the next block.';

  @override
  String get pomodoroStartFocusSession => 'Start focus session';

  @override
  String get pomodoroStartBreak => 'Start break';

  @override
  String get pomodoroPauseFocus => 'Pause focus';

  @override
  String get pomodoroPauseBreak => 'Pause break';

  @override
  String get pomodoroResumeFocus => 'Resume focus';

  @override
  String get pomodoroResumeBreak => 'Resume break';

  @override
  String pomodoroTodaySessionsValue(int count, int goal) {
    return '$count/$goal sessions';
  }

  @override
  String get pomodoroFocusTime => 'Focus time';

  @override
  String pomodoroSevenDaySummary(int sessions, int minutes) {
    return '7-day summary: $sessions sessions | $minutes minutes deep work';
  }

  @override
  String pomodoroFreeSessionsLeft(int remaining) {
    return '$remaining free focus sessions left today.';
  }

  @override
  String get pomodoroFocusLength => 'Focus length';

  @override
  String get pomodoroCustomFocusPremiumTitle =>
      'Custom focus lengths are Premium';

  @override
  String get pomodoroUnlockPremium => 'Unlock premium';

  @override
  String get pomodoroResetAction => 'Reset';

  @override
  String get pomodoroSkipAction => 'Skip';

  @override
  String get pomodoroAdvancedInsights => 'Advanced insights';

  @override
  String pomodoroAdvancedInsightsSummary(int todayMinutes, int weeklyMinutes) {
    return 'Today: $todayMinutes minutes focused | This week: $weeklyMinutes minutes banked';
  }

  @override
  String get pomodoroAverageFocus => 'Avg focus';

  @override
  String get pomodoroCustomModesTitle => 'Custom modes';

  @override
  String get pomodoroPremiumTeaserTitle =>
      'Premium adds advanced stats and custom modes';

  @override
  String get pomodoroPremiumTeaserSubtitle =>
      'See deeper consistency signals, unlock longer presets, and keep notes attached to each focus block.';

  @override
  String get pomodoroFocusNote => 'Focus note';

  @override
  String get pomodoroFocusNoteLabel => 'What matters right now?';

  @override
  String get pomodoroFocusNoteHint =>
      'Write the one thing this session is for.';

  @override
  String get pomodoroSessionNotesPremiumTitle =>
      'Session notes are part of Premium';

  @override
  String pomodoroHistoryItem(int minutes, int month, int day, String time) {
    return '${minutes}m focus | $month/$day at $time';
  }

  @override
  String get fastingTitle => 'Fasting Flow';

  @override
  String get fastingCurrentFast => 'Current fast';

  @override
  String get fastingFastInProgress => 'Fast in progress';

  @override
  String get fastingStartFast => 'Start fast';

  @override
  String get fastingPauseFast => 'Pause fast';

  @override
  String get fastingResumeFast => 'Resume fast';

  @override
  String fastingTodayFastsValue(int count, int goal) {
    return '$count/$goal fasts';
  }

  @override
  String get fastingLastFast => 'Last fast';

  @override
  String fastingSevenDaySummary(int fasts, String hours) {
    return '7-day summary: $fasts fasts | $hours total fasting';
  }

  @override
  String get fastingResetFast => 'Reset fast';

  @override
  String get fastingPremiumHistoryUnlock =>
      'Premium unlocks your full fasting history.';

  @override
  String get fastingDeeperInsights => 'Deeper insights';

  @override
  String get fastingLongestFast => 'Longest fast';

  @override
  String get fastingAdvancedPlansTitle => 'Advanced plans';

  @override
  String fastingWeeklyConsistencySummary(int activeDays, String hours) {
    return '$activeDays/7 active days | $hours total fasting this week';
  }

  @override
  String get fastingPremiumTeaserTitle =>
      'Premium adds extended plans and deeper insights';

  @override
  String get fastingPremiumTeaserSubtitle =>
      'Unlock 18:6 and 20:4 plans, plus stronger weekly insight into your fasting consistency.';

  @override
  String get fastingPremiumPlansTitle =>
      'Premium unlocks extended fasting plans';

  @override
  String fastingPlanSummary(String plan, String window, String description) {
    return '$plan plan | Eating window $window | $description';
  }

  @override
  String fastingHistoryItem(String hours, int month, int day, String time) {
    return '$hours fast | $month/$day at $time';
  }

  @override
  String get fastingPlanReset12Description =>
      'A balanced reset for building consistency.';

  @override
  String get fastingPlanLean16Description =>
      'The classic daily fasting rhythm.';

  @override
  String get fastingPlanPerformance18Description =>
      'A longer fast with a compact fueling block.';

  @override
  String get fastingPlanDeep20Description =>
      'A deep fast for experienced routines.';

  @override
  String get fastingEatingWindow12 => '12h eating window';

  @override
  String get fastingEatingWindow8 => '8h eating window';

  @override
  String get fastingEatingWindow6 => '6h eating window';

  @override
  String get fastingEatingWindow4 => '4h eating window';
}
