import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/motion.dart';
import '../pricelist/price_list_page.dart';
import '../reports/monthly_report_page.dart';
import '../schedule/calendar_page.dart';
import '../tools/calculators_page.dart';

/// ردیف «دسترسی سریع» خانه: چهار کار هرروزی، هر کدام با یک لمس.
class QuickAccessRow extends StatelessWidget {
  const QuickAccessRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.calendar_month_outlined, 'تقویم کارها', () => const CalendarPage()),
      (Icons.sell_outlined, 'نرخ‌نامه', () => const PriceListPage()),
      (Icons.calculate_outlined, 'ماشین‌حساب', () => const CalculatorsPage()),
      (Icons.bar_chart_rounded, 'گزارش ماه', () => const MonthlyReportPage()),
    ];
    return Padding(
      padding: context.rs.page(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickTile(
                icon: items[i].$1,
                label: items[i].$2,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => items[i].$3()),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return PressScale(
      scale: 0.94,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 66,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: scheme.primary),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
