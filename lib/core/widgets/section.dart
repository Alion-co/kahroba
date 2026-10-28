import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// کارت یک بخش با عنوان و دکمه‌ی اختیاری کنار عنوان.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.icon,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                if (trailing != null) trailing! else const SizedBox(height: 40),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            child,
          ],
        ),
      ),
    );
  }
}

/// یک ردیف «عنوان: مقدار» قابل لمس.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.placeholder = '—',
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = value.trim().isEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: Text(
                empty ? placeholder : value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: empty ? theme.colorScheme.outline : null,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.edit_outlined,
                  size: 18, color: theme.colorScheme.outline),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
