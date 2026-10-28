import 'package:flutter/material.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/glass.dart';
import '../../core/theme/status_colors.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/motion.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';
import '../cases/pages/case_form_page.dart';
import '../pricelist/price_list_page.dart';
import '../settings/settings_page.dart';

/// یک قدم «شروع سریع»
class _Step {
  const _Step({
    required this.icon,
    required this.title,
    required this.hint,
    required this.done,
    required this.page,
  });
  final IconData icon;
  final String title;
  final String hint;
  final bool done;
  final Widget Function() page;
}

/// کارت «شروع سریع» خانه: چهار قدم با تیک خودکار.
///
/// تیک‌ها از خود داده‌ها خوانده می‌شوند (نه با لمس)، پس هر وقت کاری انجام
/// شود خودبه‌خود تیک می‌خورد. وقتی همه انجام شد یا کاربر کارت را بست
/// دیگر نمایش داده نمی‌شود.
class WelcomeCard extends StatefulWidget {
  const WelcomeCard({
    super.key,
    required this.settings,
    required this.hasCases,
    this.showClose = true,
  });

  final ShopSettings settings;
  final bool hasCases;
  final bool showClose;

  /// آیا کارت باید روی خانه بیاید؟ (بسته نشده و هنوز قدمی مانده)
  static bool shouldShow(ShopSettings s) =>
      s.get(SettingKeys.welcomeDismissed) != '1';

  @override
  State<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<WelcomeCard> {
  final _prices = appDb.watchPriceItems();

  List<_Step> _steps(bool hasPrices) {
    final s = widget.settings;
    final named = (s.raw[SettingKeys.shopName] ?? '').trim().isNotEmpty &&
        s.shopName != settingDefaults[SettingKeys.shopName];
    return [
      _Step(
        icon: Icons.storefront_outlined,
        title: 'نام مغازه',
        hint: 'روی رسید و پیامک‌ها می‌آید',
        done: named,
        page: () => const SettingsPage(),
      ),
      _Step(
        icon: Icons.call_outlined,
        title: 'شماره‌ی مغازه',
        hint: 'تا مشتری بتواند تماس بگیرد',
        done: s.shopPhone.trim().isNotEmpty,
        page: () => const SettingsPage(),
      ),
      _Step(
        icon: Icons.sell_outlined,
        title: 'نرخ‌نامه',
        hint: 'اجرت و قطعه‌های پرتکرار',
        done: hasPrices,
        page: () => const PriceListPage(),
      ),
      _Step(
        icon: Icons.add_box_outlined,
        title: 'اولین پرونده',
        hint: 'پذیرش اولین دستگاه',
        done: widget.hasCases,
        page: () => const CaseFormPage(),
      ),
    ];
  }

  Future<void> _dismiss() =>
      appDb.setSetting(SettingKeys.welcomeDismissed, '1');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PriceItem>>(
      stream: _prices,
      builder: (context, snap) {
        final steps = _steps((snap.data ?? const []).isNotEmpty);
        final doneCount = steps.where((s) => s.done).length;
        // همه انجام شد: کارت جمع می‌شود
        if (doneCount == steps.length && widget.hasCases) {
          return const SizedBox.shrink();
        }
        return _card(context, steps, doneCount);
      },
    );
  }

  Widget _card(BuildContext context, List<_Step> steps, int doneCount) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final progress = doneCount / steps.length;

    return Container(
      margin: context.rs.page(top: AppSpacing.sm, bottom: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.lg),
      decoration: BoxDecoration(
        color: dark
            ? (GlassPalette.of(context).isBlack
                ? const Color(0xFF0E0E10)
                : const Color(0xFF141B2B))
            : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GlassPalette.of(context).accent.withValues(alpha: dark ? 0.25 : 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch_outlined,
                  size: 20, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'شروع سریع',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${toFaDigits(doneCount)} از ${toFaDigits(steps.length)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.showClose)
                IconButton(
                  tooltip: 'بستن',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _dismiss,
                )
              else
                const SizedBox(width: AppSpacing.sm),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: AdaptiveWrap(
              minTileWidth: 150,
              minColumns: 2,
              maxColumns: 4,
              builder: (w) => [
                for (var i = 0; i < steps.length; i++)
                  SizedBox(
                    width: w,
                    child: FadeSlideIn(
                      index: i,
                      child: _StepTile(step: steps[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ok = context.statusColors.of(CaseStatus.ready);
    final accent = step.done ? ok : scheme.primary;

    return PressScale(
      scale: 0.95,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => step.page()),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 96,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: accent.withValues(alpha: step.done ? 0.10 : 0.08),
              border: Border.all(
                color: accent.withValues(alpha: step.done ? 0.45 : 0.30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon, size: 22, color: accent),
                    const Spacer(),
                    // تیک: دایره‌ی خالی ← تیک سبز
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: step.done
                          ? Icon(Icons.check_circle,
                              key: const ValueKey(true), size: 22, color: ok)
                          : Icon(Icons.radio_button_unchecked,
                              key: const ValueKey(false),
                              size: 22,
                              color: scheme.outline),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  step.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: step.done ? scheme.onSurfaceVariant : null,
                  ),
                ),
                Text(
                  step.done ? 'انجام شد' : step.hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: step.done ? ok : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
