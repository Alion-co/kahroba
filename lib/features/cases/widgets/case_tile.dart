import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/services/launcher.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/motion.dart';
import '../../../data/database.dart';
import '../pages/case_detail_page.dart';
import 'status_chip.dart';

/// کارت یک پرونده در فهرست‌ها: آیکن دستگاه به رنگ وضعیت، مشتری و دستگاه،
/// کد و تاریخ، برچسب وضعیت و دکمه‌ی تماس.
class CaseTile extends StatelessWidget {
  final CaseRow item;

  /// در کارت‌های تودرتو (مثل صفحه‌ی مشتری) حاشیه‌ی بیرونی حذف می‌شود.
  final bool inset;

  /// اگر داده شود، کارت با ورود پله‌ای ظاهر می‌شود
  final int? enterIndex;
  const CaseTile({
    super.key,
    required this.item,
    this.inset = false,
    this.enterIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = item.repairCase;
    final color = context.statusColors.of(c.status);
    final phone = item.customer.phone.isNotEmpty
        ? item.customer.phone
        : item.customer.phone2;

    final content = InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: c.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CategoryAvatar(iconKey: item.category.icon, radius: 26, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.customer.name} • ${item.deviceTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    toFaDigits(c.code),
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    formatDate(c.receivedAt),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (phone.isNotEmpty)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Launcher.call(phone),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withValues(alpha: 0.5)),
                      ),
                      child: Icon(Icons.call, size: 16, color: color),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                StatusChip(status: c.status, dense: true),
              ],
            ),
          ],
        ),
      ),
    );

    final card = PressScale(
      child: Card(
        margin: inset
            ? const EdgeInsets.symmetric(vertical: AppSpacing.xs)
            : EdgeInsets.symmetric(
                horizontal: context.rs.gutter, vertical: AppSpacing.xs + 2),
        child: content,
      ),
    );
    final i = enterIndex;
    return i == null ? card : FadeSlideIn(index: i, child: card);
  }
}
