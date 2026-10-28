import 'package:flutter/material.dart';

import '../../../core/theme/status_colors.dart';
import '../../../core/utils/format.dart';
import '../../../data/database.dart';

/// یک مرحله‌ی نوار پیشرفت پرونده.
class CaseStep {
  const CaseStep(this.label, this.icon, this.status);
  final String label;
  final IconData icon;

  /// وضعیتی که با لمس این مرحله ثبت می‌شود
  final CaseStatus status;
}

/// پنج مرحله‌ی اصلی کار: پذیرش ← عیب‌یابی ← تعمیر ← آماده ← تحویل
const caseSteps = [
  CaseStep('پذیرش', Icons.move_to_inbox_outlined, CaseStatus.received),
  CaseStep('عیب‌یابی', Icons.search, CaseStatus.diagnosing),
  CaseStep('تعمیر', Icons.build_outlined, CaseStatus.repairing),
  CaseStep('آماده', Icons.check_circle_outline, CaseStatus.ready),
  CaseStep('تحویل', Icons.done_all, CaseStatus.delivered),
];

/// هر وضعیت در کدام مرحله است.
/// «منتظر تأیید قیمت» جزو عیب‌یابی، «منتظر قطعه» جزو تعمیر،
/// «برگشتی گارانتی» دوباره عیب‌یابی و «مرجوعی» پایان کار حساب می‌شود.
int stepOf(CaseStatus s) => switch (s) {
      CaseStatus.received => 0,
      CaseStatus.diagnosing ||
      CaseStatus.awaitingApproval ||
      CaseStatus.warrantyReturn =>
        1,
      CaseStatus.waitingParts || CaseStatus.repairing => 2,
      CaseStatus.ready => 3,
      CaseStatus.delivered || CaseStatus.unrepairable => 4,
    };

/// نوار مراحل بالای صفحه‌ی پرونده.
///
/// مرحله‌های گذشته تیک می‌خورند و تاریخشان زیرشان می‌آید، مرحله‌ی فعلی
/// به رنگ وضعیت می‌درخشد. لمس یک مرحله وضعیت را به آن مرحله می‌برد؛
/// لمس مرحله‌ی فعلی فهرست کامل وضعیت‌ها را باز می‌کند.
class CaseProgressBar extends StatelessWidget {
  const CaseProgressBar({
    super.key,
    required this.status,
    required this.receivedAt,
    this.events = const [],
    this.onStepTap,
  });

  final CaseStatus status;
  final DateTime receivedAt;
  final List<StatusEvent> events;
  final void Function(int step)? onStepTap;

  /// آخرین زمانی که پرونده وارد هر مرحله شد
  Map<int, DateTime> _dates() {
    final out = <int, DateTime>{0: receivedAt};
    for (final e in events) {
      final k = stepOf(e.status);
      if (k == 0) continue;
      final prev = out[k];
      if (prev == null || e.at.isAfter(prev)) out[k] = e.at;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = stepOf(status);
    final rejected = status == CaseStatus.unrepairable;
    final activeColor =
        rejected ? scheme.error : context.statusColors.of(status);
    final doneColor = scheme.primary;
    final idle = scheme.outlineVariant;
    final dates = _dates();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dur = Duration(milliseconds: reduce ? 0 : 320);

    // زیرنویس مرحله‌ی فعلی وقتی وضعیت دقیق با نام مرحله فرق دارد
    final sub = switch (status) {
      CaseStatus.awaitingApproval => 'منتظر تأیید',
      CaseStatus.waitingParts => 'منتظر قطعه',
      CaseStatus.warrantyReturn => 'برگشتی گارانتی',
      _ => null,
    };

    Widget line(bool on) => Expanded(
          child: AnimatedContainer(
            duration: dur,
            height: 3,
            decoration: BoxDecoration(
              color: on ? doneColor : idle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );

    Widget step(int i) {
      final s = caseSteps[i];
      final done = i < current;
      final active = i == current;
      final isLast = i == caseSteps.length - 1;
      final label = (isLast && rejected) ? 'مرجوعی' : s.label;
      final icon = (isLast && rejected)
          ? Icons.block
          : (done ? Icons.check_rounded : s.icon);
      final color = active ? activeColor : (done ? doneColor : idle);
      final size = active ? 38.0 : 30.0;
      final date = (done || active) ? dates[i] : null;

      return Expanded(
        child: Semantics(
          button: onStepTap != null,
          selected: active,
          label: 'مرحله‌ی $label',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onStepTap == null ? null : () => onStepTap!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        // نیمه‌ی رو به مرحله‌ی قبل
                        i == 0
                            ? const Spacer()
                            : line(i <= current),
                        AnimatedContainer(
                          duration: dur,
                          curve: Curves.easeOutBack,
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? doneColor
                                : color.withValues(alpha: active ? 0.18 : 0.0),
                            border: Border.all(
                              color: color,
                              width: active ? 2.2 : 1.6,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: activeColor.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            icon,
                            size: active ? 20 : 16,
                            color: done ? scheme.onPrimary : color,
                          ),
                        ),
                        // نیمه‌ی رو به مرحله‌ی بعد
                        isLast ? const Spacer() : line(i < current),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? activeColor
                          : (done ? scheme.onSurface : scheme.onSurfaceVariant),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                    child: Text(
                      active && sub != null
                          ? sub
                          : (date == null ? '' : formatDayMonth(date)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: active && sub != null
                            ? activeColor
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (var i = 0; i < caseSteps.length; i++) step(i)],
    );
  }
}
