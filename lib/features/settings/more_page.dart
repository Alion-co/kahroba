import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/developer_info.dart';
import '../../core/widgets/motion.dart';
import '../marketing/marketing_page.dart';
import '../reports/monthly_report_page.dart';
import 'about_page.dart';
import 'settings_page.dart';

/// تب «بیشتر»: فقط چهار ورودی. کارهای هرروزی در «دسترسی سریع» خانه‌اند،
/// قطعات معادل در بانک فنی، و دسته‌ها/همگام‌سازی/معرفی داخل تنظیمات.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  void _go(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.bar_chart_rounded,
        'گزارش‌ها',
        'درآمد ماه، تعداد تعمیرات و خرابی‌های پرتکرار',
        () => _go(context, const MonthlyReportPage()),
      ),
      (
        Icons.campaign_outlined,
        'بازاریابی',
        'کمپین فصلی و کارت ویزیت QR',
        () => _go(context, const MarketingPage()),
      ),
      (
        Icons.settings_outlined,
        'تنظیمات',
        'مغازه، پشتیبان، قفل، اعلان‌ها و همگام‌سازی',
        () => _go(context, const SettingsPage()),
      ),
      (
        Icons.info_outline,
        'درباره‌ی کهربا',
        'اصول، سازنده و مجوزها',
        () => AboutPage.open(context),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('بیشتر')),
      // امضای سازنده همیشه پایینِ صفحه، بالای نوار پایین
      body: Column(
        children: [
          Expanded(
            child: ResponsiveListView(
              padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 24),
              children: [
                for (var i = 0; i < items.length; i++)
                  FadeSlideIn(
                    index: i,
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                        leading: Icon(items[i].$1,
                            color: Theme.of(context).colorScheme.primary),
                        title: Text(items[i].$2),
                        subtitle: Text(items[i].$3),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: items[i].$4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: DeveloperCredit(),
          ),
        ],
      ),
    );
  }
}
