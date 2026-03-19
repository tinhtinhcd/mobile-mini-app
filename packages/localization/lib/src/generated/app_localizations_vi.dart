// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get commonStart => 'Bắt đầu';

  @override
  String get commonPause => 'Tạm dừng';

  @override
  String get commonReset => 'Đặt lại';

  @override
  String get commonStreak => 'Chuỗi ngày';

  @override
  String get commonToday => 'Hôm nay';

  @override
  String get commonUpgrade => 'Nâng cấp';

  @override
  String get commonPremium => 'Premium';

  @override
  String get commonReadyToBegin => 'Sẵn sàng bắt đầu';

  @override
  String get commonPaused => 'Đã tạm dừng';

  @override
  String get commonRecentActivity => 'Hoạt động gần đây';

  @override
  String get commonActiveDays => 'Ngày hoạt động';

  @override
  String get commonMode => 'Chế độ';

  @override
  String get commonPlan => 'Lộ trình';

  @override
  String get commonSeePremium => 'Xem Premium';

  @override
  String get shellOpenMenuTooltip => 'Mở menu';

  @override
  String get shellUtilityAppMenu => 'Menu tiện ích';

  @override
  String get shellAboutApp => 'Giới thiệu ứng dụng';

  @override
  String get shellSettingsConfig => 'Cài đặt / Tùy chỉnh';

  @override
  String get shellSubscriptionPlan => 'Gói đăng ký';

  @override
  String get shellPrivacy => 'Quyền riêng tư';

  @override
  String get shellFeedback => 'Phản hồi';

  @override
  String shellAboutTitle(String appTitle) {
    return 'Giới thiệu $appTitle';
  }

  @override
  String get shellAboutDescription =>
      'Đây là bề mặt giữ chỗ dùng lại cho thông tin ứng dụng. Kết nối trang thật khi nó sẵn sàng.';

  @override
  String get shellSettingsTitle => 'Cài đặt';

  @override
  String get shellSettingsDescription =>
      'Cài đặt hiện nằm trong shared shell. Hãy nối màn hình cấu hình thật khi triển khai xong.';

  @override
  String get shellSubscriptionDescription =>
      'Quản lý gói đăng ký có thể được nối vào đây mà không làm rối màn hình chính.';

  @override
  String get shellPrivacyDescription =>
      'Thêm điểm đến quyền riêng tư ở đây khi các trang pháp lý dùng chung sẵn sàng.';

  @override
  String get shellFeedbackDescription =>
      'Điều hướng phản hồi và hỗ trợ vào đây mà không thay đổi luồng ứng dụng chính.';

  @override
  String get pomodoroTitle => 'Focus Flow';

  @override
  String get pomodoroCurrentCycle => 'Chu kỳ hiện tại';

  @override
  String get pomodoroModeFocus => 'Tập trung';

  @override
  String get pomodoroModeShortBreak => 'Nghỉ ngắn';

  @override
  String get pomodoroModeLongBreak => 'Nghỉ dài';

  @override
  String get pomodoroFocusInProgress => 'Đang tập trung';

  @override
  String get pomodoroBreakInProgress => 'Đang nghỉ';

  @override
  String get pomodoroFocusFootnote =>
      'Bám vào một việc duy nhất cho tới khi hết giờ.';

  @override
  String get pomodoroShortBreakFootnote =>
      'Nghỉ nhanh để reset rồi quay lại rõ ràng hơn.';

  @override
  String get pomodoroLongBreakFootnote =>
      'Rời màn hình lâu hơn một chút trước phiên tiếp theo.';

  @override
  String get pomodoroStartFocusSession => 'Bắt đầu phiên tập trung';

  @override
  String get pomodoroStartBreak => 'Bắt đầu nghỉ';

  @override
  String get pomodoroPauseFocus => 'Tạm dừng tập trung';

  @override
  String get pomodoroPauseBreak => 'Tạm dừng nghỉ';

  @override
  String get pomodoroResumeFocus => 'Tiếp tục tập trung';

  @override
  String get pomodoroResumeBreak => 'Tiếp tục nghỉ';

  @override
  String pomodoroTodaySessionsValue(int count, int goal) {
    return '$count/$goal phiên';
  }

  @override
  String get pomodoroFocusTime => 'Thời gian tập trung';

  @override
  String pomodoroSevenDaySummary(int sessions, int minutes) {
    return 'Tóm tắt 7 ngày: $sessions phiên | $minutes phút làm việc sâu';
  }

  @override
  String pomodoroFreeSessionsLeft(int remaining) {
    return 'Bạn còn $remaining phiên tập trung miễn phí hôm nay.';
  }

  @override
  String get pomodoroFocusLength => 'Độ dài phiên tập trung';

  @override
  String get pomodoroCustomFocusPremiumTitle =>
      'Độ dài tập trung tùy chỉnh là Premium';

  @override
  String get pomodoroUnlockPremium => 'Mở khóa Premium';

  @override
  String get pomodoroResetAction => 'Đặt lại';

  @override
  String get pomodoroSkipAction => 'Bỏ qua';

  @override
  String get pomodoroAdvancedInsights => 'Phân tích nâng cao';

  @override
  String get pomodoroAverageFocus => 'TB tập trung';

  @override
  String get pomodoroFocusNote => 'Ghi chú tập trung';

  @override
  String get pomodoroFocusNoteLabel => 'Điều gì quan trọng ngay bây giờ?';

  @override
  String get pomodoroFocusNoteHint =>
      'Viết ra một việc duy nhất cho phiên này.';

  @override
  String get pomodoroSessionNotesPremiumTitle =>
      'Ghi chú phiên là tính năng Premium';

  @override
  String pomodoroHistoryItem(int minutes, int month, int day, String time) {
    return '${minutes}p tập trung | $month/$day lúc $time';
  }

  @override
  String get fastingTitle => 'Fasting Flow';

  @override
  String get fastingCurrentFast => 'Phiên nhịn hiện tại';

  @override
  String get fastingFastInProgress => 'Đang nhịn';

  @override
  String get fastingStartFast => 'Bắt đầu nhịn';

  @override
  String get fastingPauseFast => 'Tạm dừng nhịn';

  @override
  String get fastingResumeFast => 'Tiếp tục nhịn';

  @override
  String fastingTodayFastsValue(int count) {
    return '$count/1 phiên';
  }

  @override
  String get fastingLastFast => 'Lần nhịn gần nhất';

  @override
  String fastingSevenDaySummary(int fasts, String hours) {
    return 'Tóm tắt 7 ngày: $fasts phiên | $hours tổng thời gian nhịn';
  }

  @override
  String get fastingResetFast => 'Đặt lại phiên nhịn';

  @override
  String get fastingPremiumHistoryUnlock =>
      'Premium mở khóa toàn bộ lịch sử nhịn của bạn.';

  @override
  String get fastingDeeperInsights => 'Phân tích sâu hơn';

  @override
  String get fastingLongestFast => 'Phiên dài nhất';

  @override
  String get fastingPremiumPlansTitle =>
      'Premium mở khóa các lộ trình nhịn mở rộng';

  @override
  String fastingPlanSummary(String plan, String window, String description) {
    return 'Lộ trình $plan | Cửa sổ ăn $window | $description';
  }

  @override
  String fastingHistoryItem(String hours, int month, int day, String time) {
    return '$hours nhịn | $month/$day lúc $time';
  }

  @override
  String get fastingPlanReset12Description =>
      'Khởi động cân bằng để xây dựng sự ổn định.';

  @override
  String get fastingPlanLean16Description => 'Nhịp nhịn hàng ngày cổ điển.';

  @override
  String get fastingPlanPerformance18Description =>
      'Phiên nhịn dài hơn với khoảng ăn ngắn gọn.';

  @override
  String get fastingPlanDeep20Description =>
      'Phiên nhịn sâu cho thói quen đã quen nhịp.';

  @override
  String get fastingEatingWindow12 => 'cửa sổ ăn 12h';

  @override
  String get fastingEatingWindow8 => 'cửa sổ ăn 8h';

  @override
  String get fastingEatingWindow6 => 'cửa sổ ăn 6h';

  @override
  String get fastingEatingWindow4 => 'cửa sổ ăn 4h';
}
