import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ═══════════════════════════════════════════════════════════════════
// اطلاعات سازنده — ALION
//
// این فایل مستقل است: برای برنامه‌های دیگر فقط همین فایل را کپی کنید.
// (وابستگی‌ها: بسته‌ی url_launcher و فایل assets/brand/alion_lion.png)
//
// استفاده:
//   DeveloperCredit()                      ← خط کوچک «Designed by Alion»
//   DeveloperInfoPage.open(context)        ← صفحه‌ی کامل درباره‌ی سازنده
//   DeveloperBadge() و DeveloperContacts()  ← برای گذاشتن در صفحه‌ی «درباره»ی برنامه
//   DeveloperInfo.legalese                 ← متن کوتاه برای showAboutDialog
// ═══════════════════════════════════════════════════════════════════

abstract final class DeveloperInfo {
  static const name = 'ALION';
  static const phone = '09142745663';
  static const instagram = 'alion.inc';
  static const email = 'alion.inc.org@gmail.com';

  /// نشان شیر ALION (برای برنامه‌های دیگر این فایل را هم کپی کنید)
  static const lionAsset = 'assets/brand/alion_lion.png';

  /// طلایی برند ALION
  static const gold = Color(0xFFC9A46A);

  /// متن امضای سازنده
  static const credit = 'Designed by Alion';

  static Uri get phoneUri => Uri(scheme: 'tel', path: phone);
  static Uri get instagramUri => Uri.parse('https://instagram.com/$instagram');
  static Uri get emailUri => Uri(scheme: 'mailto', path: email);

  /// متن کوتاه برای پنجره‌ی «درباره»
  static const legalese =
      'اینستاگرام: @$instagram\nایمیل: $email';

  /// شماره با ارقام فارسی و فاصله: ۰۹۱۴ ۲۷۴ ۵۶۶۳
  static String get phoneDisplay {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    final d = phone.split('').map((c) => fa[int.parse(c)]).join();
    return d.length == 11
        ? '${d.substring(0, 4)} ${d.substring(4, 7)} ${d.substring(7)}'
        : d;
  }

  static Future<void> open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // اگر برنامه‌ای برای باز کردن نبود، کاری نمی‌کنیم
    }
  }
}

/// خط کوچک «Designed by Alion» برای پایین صفحه‌ها؛ لمسش صفحه‌ی سازنده را باز می‌کند.
class DeveloperCredit extends StatelessWidget {
  const DeveloperCredit({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: TextButton(
        onPressed: () => DeveloperInfoPage.open(context),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurfaceVariant,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(DeveloperInfo.lionAsset, width: 18, height: 18),
            const SizedBox(width: 6),
            Text(
              DeveloperInfo.credit,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// صفحه‌ی «درباره‌ی سازنده»
class DeveloperInfoPage extends StatelessWidget {
  const DeveloperInfoPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const DeveloperInfoPage()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره‌ی سازنده')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: const [
              DeveloperBadge(),
              SizedBox(height: 28),
              DeveloperContacts(),
            ],
          ),
        ),
      ),
    );
  }
}

/// نشان سازنده: دایره‌ی «A»، نام و توضیح کوتاه
class DeveloperBadge extends StatelessWidget {
  const DeveloperBadge({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        // نشان شیر ALION روی دایره‌ی زغالی با حاشیه‌ی طلایی
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF15161A),
            border: Border.all(color: DeveloperInfo.gold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: DeveloperInfo.gold.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(DeveloperInfo.lionAsset, fit: BoxFit.contain),
        ),
        const SizedBox(height: 12),
        Text(
          DeveloperInfo.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
            letterSpacing: 8,
            color: theme.brightness == Brightness.dark
                ? DeveloperInfo.gold
                : const Color(0xFF8C6A3A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'سازنده‌ی این برنامه',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// دکمه‌های تماس با سازنده: تلفن، اینستاگرام، ایمیل
class DeveloperContacts extends StatelessWidget {
  const DeveloperContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContactTile(
          icon: Icons.call_outlined,
          label: 'تماس',
          value: DeveloperInfo.phoneDisplay,
          onTap: () => DeveloperInfo.open(DeveloperInfo.phoneUri),
        ),
        _ContactTile(
          icon: Icons.camera_alt_outlined,
          label: 'اینستاگرام',
          value: '@${DeveloperInfo.instagram}',
          onTap: () => DeveloperInfo.open(DeveloperInfo.instagramUri),
        ),
        _ContactTile(
          icon: Icons.email_outlined,
          label: 'ایمیل',
          value: DeveloperInfo.email,
          onTap: () => DeveloperInfo.open(DeveloperInfo.emailUri),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: scheme.primary.withValues(alpha: 0.14),
          child: Icon(icon, color: scheme.primary),
        ),
        title: Text(label),
        subtitle: Text(
          value,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
