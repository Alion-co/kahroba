import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/services/rate_prompt.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/developer_info.dart';
import '../../core/widgets/motion.dart';

/// نسخه‌ی برنامه (همراه با pubspec.yaml عوض شود)
const appVersion = '1.0.0';

/// «درباره‌ی کهربا»: مینیمال و یک‌صفحه‌ای، بدون پیمایش.
/// لوگو و نام وسط، سازنده با سه دکمه‌ی تماس، و امضا ته صفحه.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const AboutPage()));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeSlideIn(
          child: Image.asset('assets/brand/logo_dark.png', height: 96),
        ),
        const SizedBox(height: AppSpacing.md),
        FadeSlideIn(
          index: 1,
          child: Text(
            'کهربا',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        FadeSlideIn(
          index: 2,
          child: Text(
            'دفتر دیجیتال تعمیرکاران',
            style: theme.textTheme.bodyLarge?.copyWith(color: muted),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FadeSlideIn(
          index: 2,
          child: Text(
            'نسخه‌ی $appVersion · رایگان و متن‌باز · کاملاً آفلاین',
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
        ),
      ],
    );

    // ───── سازنده: نشان شیر، نام «Alion»، و سه دکمه‌ی تماس با برچسب
    final maker = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeSlideIn(index: 3, child: const _LionBadge(size: 56)),
        const SizedBox(height: AppSpacing.sm),
        FadeSlideIn(
          index: 3,
          child: Text(
            'Alion',
            style: theme.textTheme.titleSmall?.copyWith(
              letterSpacing: 4,
              color: theme.brightness == Brightness.dark
                  ? DeveloperInfo.gold
                  : const Color(0xFF8C6A3A),
            ),
          ),
        ),
        Text(
          'سازنده‌ی این برنامه',
          style: theme.textTheme.labelSmall?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.md),
        FadeSlideIn(
          index: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ContactButton(
                icon: Icons.call_outlined,
                label: 'تماس',
                onTap: () => DeveloperInfo.open(DeveloperInfo.phoneUri),
              ),
              const SizedBox(width: 20),
              _ContactButton(
                icon: Icons.camera_alt_outlined,
                label: 'اینستاگرام',
                onTap: () => DeveloperInfo.open(DeveloperInfo.instagramUri),
              ),
              const SizedBox(width: 20),
              _ContactButton(
                icon: Icons.email_outlined,
                label: 'ایمیل',
                onTap: () => DeveloperInfo.open(DeveloperInfo.emailUri),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('درباره‌ی کهربا')),
      body: SafeArea(
        top: false,
        // یک صفحه: کهربا بالا، سازنده پایین، امضا ته صفحه.
        // روی گوشی خیلی کوچک قابل پیمایش می‌شود.
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    content,
                    if (!kIsWeb) ...[
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton.icon(
                        onPressed: RatePrompt.openMyket,
                        icon: const Icon(Icons.star_outline_rounded, size: 18),
                        label: const Text('امتیاز به کهربا در مایکت'),
                      ),
                    ],
                    // سازنده کمی بالاتر از وسط فضای خالی پایین
                    const Spacer(flex: 3),
                    const SizedBox(height: AppSpacing.xl),
                    maker,
                    const Spacer(flex: 2),
                    const SizedBox(height: AppSpacing.lg),
                    const DeveloperCredit(),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// نشان شیر روی دایره‌ی زغالی با حاشیه‌ی طلایی
class _LionBadge extends StatelessWidget {
  const _LionBadge({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF15161A),
        border: Border.all(color: DeveloperInfo.gold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: DeveloperInfo.gold.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Image.asset(DeveloperInfo.lionAsset, fit: BoxFit.contain),
    );
  }
}

/// دکمه‌ی گرد کوچک تماس با برچسب زیرش
class _ContactButton extends StatelessWidget {
  const _ContactButton({
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
    return PressScale(
      scale: 0.92,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DeveloperInfo.gold.withValues(alpha: 0.6),
                  ),
                ),
                child: Icon(icon, size: 20, color: DeveloperInfo.gold),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
