import 'package:flutter/material.dart';

import '../../data/enums.dart';
import 'app_colors.dart';

/// رنگ هر وضعیت پرونده، به‌صورت افزونه‌ی تم.
/// [standard] برای تم روشن، [bright] برای تم تیره (روشن‌تر تا روی زمینه‌ی
/// تیره خوانا بماند).
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Map<CaseStatus, Color> colors;
  const StatusColors(this.colors);

  static const StatusColors standard = StatusColors({
    CaseStatus.received: AppColors.statusReceived,
    CaseStatus.diagnosing: AppColors.statusDiagnosing,
    CaseStatus.awaitingApproval: AppColors.statusAwaitingApproval,
    CaseStatus.waitingParts: AppColors.statusWaitingParts,
    CaseStatus.repairing: AppColors.statusRepairing,
    CaseStatus.ready: AppColors.statusReady,
    CaseStatus.delivered: AppColors.statusDelivered,
    CaseStatus.unrepairable: AppColors.statusUnrepairable,
    CaseStatus.warrantyReturn: AppColors.statusWarrantyReturn,
  });

  static const StatusColors bright = StatusColors({
    CaseStatus.received: Color(0xFF9FB3C8),
    CaseStatus.diagnosing: Color(0xFFC792EA),
    CaseStatus.awaitingApproval: Color(0xFFFFC857),
    CaseStatus.waitingParts: Color(0xFFFF9A4D),
    CaseStatus.repairing: Color(0xFF6CC4FF),
    CaseStatus.ready: Color(0xFF5EE29A),
    CaseStatus.delivered: Color(0xFF8B95A5),
    CaseStatus.unrepairable: Color(0xFFFF6B6B),
    CaseStatus.warrantyReturn: Color(0xFFD4A373),
  });

  Color of(CaseStatus status) => colors[status] ?? AppColors.statusReceived;

  @override
  StatusColors copyWith({Map<CaseStatus, Color>? colors}) =>
      StatusColors(colors ?? this.colors);

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) =>
      other is StatusColors ? (t < 0.5 ? this : other) : this;
}

extension StatusColorsContext on BuildContext {
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>()!;
}
