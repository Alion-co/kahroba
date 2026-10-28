import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'motion.dart';

/// حالت خالی: آیکن داخل هاله‌ی کهربایی، عنوان، توضیح و دکمه‌ی اقدام.
///
/// همه‌ی پارامترها جز [message] اختیاری‌اند تا جاهای قدیمی بدون تغییر کار کنند.
/// [compact] برای وقتی است که حالت خالی داخل یک فهرست یا کارت می‌نشیند
/// (آیکن کوچک‌تر و فاصله‌ی کمتر).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
  });

  final String message;
  final String? title;
  final IconData icon;

  /// دکمه‌ی اصلی (فقط وقتی [onAction] هم داده شود نمایش داده می‌شود)
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// دکمه‌ی متنی دوم، مثلاً «پاک کردن جستجو»
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final circle = compact ? 64.0 : 96.0;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // هاله‌ی نرم پشت آیکن
        Container(
          width: circle,
          height: circle,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                scheme.primary.withValues(alpha: dark ? 0.26 : 0.20),
                scheme.primary.withValues(alpha: dark ? 0.06 : 0.04),
              ],
            ),
            border: Border.all(
              color: scheme.primary.withValues(alpha: dark ? 0.35 : 0.28),
            ),
          ),
          child: Icon(
            icon,
            size: compact ? 30 : 44,
            color: scheme.primary,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        if (title != null) ...[
          Text(
            title!,
            textAlign: TextAlign.center,
            style: (compact
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.titleMedium)
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(
          message,
          textAlign: TextAlign.center,
          style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
              ?.copyWith(color: scheme.onSurfaceVariant, height: 1.7),
        ),
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(140, 40)),
            onPressed: onAction,
            icon: Icon(actionIcon ?? Icons.add, size: 18),
            label: Text(actionLabel!),
          ),
        ],
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: AppSpacing.xs),
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
        ],
      ],
    );

    final body = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: compact ? AppSpacing.md : AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: FadeSlideIn(offset: 12, child: content),
      ),
    );

    // داخل فهرست (ارتفاع نامحدود) فقط وسط‌چین؛ در صفحه‌ی کامل، قابل پیمایش
    // تا با باز شدن صفحه‌کلید یا گوشی کوچک بیرون نزند.
    return LayoutBuilder(
      builder: (context, box) {
        if (!box.hasBoundedHeight) return Center(child: body);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Center(child: body),
          ),
        );
      },
    );
  }
}
