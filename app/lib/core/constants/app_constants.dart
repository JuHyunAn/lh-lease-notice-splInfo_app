/// 앱 전역 상수 정의
class AppConstants {
  AppConstants._();

  // 앱 정보
  static const String appName = 'LH 청약정보';
  static const String appVersion = '1.0.0';

  // Supabase 테이블명
  static const String tableNoticeMap = 'mart_notice_map';
  static const String tableNoticeDetail = 'mart_notice_detail';

  // 페이지네이션
  static const int pageSize = 20;

  // 지도 기본 좌표 (서울 시청)
  static const double defaultLat = 37.5665;
  static const double defaultLng = 126.9780;
  static const int defaultZoom = 10;

  // 마감임박 기준 (일)
  static const int urgentDays = 7;
}
