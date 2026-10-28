import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/motion.dart';
import '../campaign/campaign_page.dart';
import '../reports/story_page.dart';
import '../share/business_card_page.dart';

/// بازاریابی: هر چیزی که مشتری تازه یا مشتری قدیمی را برمی‌گرداند.
class MarketingPage extends StatelessWidget {
  const MarketingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.campaign_outlined,
        'کمپین فصلی',
        'پیامک یادآوری سرویس پیش از زمستان و تابستان به مشتری‌های قبلی',
        () => const CampaignPage(),
      ),
      (
        Icons.qr_code_2,
        'کارت ویزیت QR',
        'کارت تصویری مغازه برای فرستادن در پیام‌رسان',
        () => const BusinessCardPage(),
      ),
      (
        Icons.auto_awesome,
        'کارنامه‌ی استوری',
        'تصویر کارهای ماه برای استوری و تبلیغ',
        () => const StoryPage(),
      ),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('بازاریابی')),
      body: ResponsiveListView(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 24),
        children: [
          for (var i = 0; i < items.length; i++)
            FadeSlideIn(
              index: i,
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  leading: Icon(items[i].$1, color: scheme.primary, size: 28),
                  title: Text(items[i].$2),
                  subtitle: Text(items[i].$3),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => items[i].$4()),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
