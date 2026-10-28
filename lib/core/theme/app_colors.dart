import 'package:flutter/material.dart';

/// همه‌ی رنگ‌های خام برنامه فقط اینجاست.
/// در صفحه‌ها و ویجت‌ها هیچ‌وقت Color(0x...) نمی‌نویسیم؛
/// از Theme.of(context) یا context.statusColors استفاده می‌کنیم.
abstract final class AppColors {
  /// رنگ اصلی برند؛ بقیه‌ی رنگ‌های تم از روی آن ساخته می‌شوند.
  static const Color seed = Color(0xFFF5A623);

  // رنگ وضعیت‌های پرونده
  static const Color statusReceived = Color(0xFF607D8B);
  static const Color statusDiagnosing = Color(0xFF8E24AA);
  static const Color statusAwaitingApproval = Color(0xFFC77C02);
  static const Color statusWaitingParts = Color(0xFFE65100);
  static const Color statusRepairing = Color(0xFF1E88E5);
  static const Color statusReady = Color(0xFF2E7D32);
  static const Color statusDelivered = Color(0xFF9E9E9E);
  static const Color statusUnrepairable = Color(0xFFC62828);
  static const Color statusWarrantyReturn = Color(0xFF6D4C41);
}
