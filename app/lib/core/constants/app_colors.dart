import 'package:flutter/material.dart';

/// 앱 컬러 팔레트
class AppColors {
  AppColors._();

  // 브랜드 컬러 (LH 블루)
  static const Color primary = Color(0xFF0054A6);
  static const Color primaryLight = Color(0xFF4A90D9);
  static const Color primaryDark = Color(0xFF003A72);

  // 배경
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);

  // 텍스트
  static const Color textPrimary = Color(0xFF1A2030);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B8C4);

  // 상태 컬러
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // 공급 유형별 컬러
  static const Color typeHousing = Color(0xFF6366F1);   // 주택 - 보라
  static const Color typeLand = Color(0xFF10B981);      // 토지 - 초록
  static const Color typeRental = Color(0xFFF59E0B);    // 임대 - 주황
  static const Color typeStore = Color(0xFFEF4444);     // 상가 - 빨강

  // 마감임박 배지
  static const Color urgentBadge = Color(0xFFFF4757);
  static const Color newBadge = Color(0xFF2ED573);
}
