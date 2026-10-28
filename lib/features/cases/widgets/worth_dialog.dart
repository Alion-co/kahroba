import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/appointment_picker.dart';
import '../../../data/database.dart';
import '../../../core/utils/input_formatters.dart';

/// عمر تقریبی مفید هر دسته (سال). قاعده‌ی سرانگشتی است، نه عدد دقیق.
const _lifespan = <String, int>{
  'BK': 15, 'SM': 8, 'PK': 12, 'AG': 12, 'KA': 12, 'KG': 12,
  'LS': 10, 'ZS': 10, 'YK': 13, 'JB': 8, 'AT': 6, 'MW': 9,
  'TV': 8, 'AB': 8,
};

enum WorthVerdict { worth, borderline, replace }

/// قاعده‌ی سرانگشتی تعمیر یا تعویض:
/// - هزینه کمتر از ۳۰٪ قیمت نو ← ارزش دارد
/// - بیش از ۵۰٪ ← تعویض به‌صرفه‌تر است
/// - بین این دو، یا اگر دستگاه از ۷۰٪ عمرش گذشته ← مرزی
WorthVerdict worthVerdict({
  required int cost,
  required int newPrice,
  int? ageYears,
  int lifespan = 10,
}) {
  final ratio = newPrice <= 0 ? 0.0 : cost / newPrice;
  final old = ageYears != null && ageYears >= lifespan * 0.7;
  if (ratio > 0.5) return WorthVerdict.replace;
  if (ratio > 0.3 || old) {
    return (ratio > 0.3 && old) ? WorthVerdict.replace : WorthVerdict.borderline;
  }
  return WorthVerdict.worth;
}

/// پنجره‌ی «ارزش تعمیر دارد؟»
Future<void> showWorthDialog(BuildContext context, CaseRow row, int cost) {
  final device = row.device;
  final priceCtrl = TextEditingController(
      text: formatMoneyInput(device.newPrice));
  final ageCtrl = TextEditingController(
      text: device.purchaseYear == null
          ? ''
          : (currentJalaliYear() - device.purchaseYear!).clamp(0, 99).toString());
  final life = _lifespan[row.category.prefix] ?? 10;

  return showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        final price = parseIntLoose(priceCtrl.text) ?? 0;
        final age = parseIntLoose(ageCtrl.text);
        final verdict = price > 0
            ? worthVerdict(cost: cost, newPrice: price, ageYears: age, lifespan: life)
            : null;
        final theme = Theme.of(ctx);
        final (color, title, body) = switch (verdict) {
          WorthVerdict.worth => (
              const Color(0xFF2E7D32),
              'ارزش تعمیر دارد ✓',
              'هزینه‌ی تعمیر بخش کوچکی از قیمت دستگاه نو است.',
            ),
          WorthVerdict.borderline => (
              const Color(0xFFC77C02),
              'مرزی است',
              'تصمیم با مشتری؛ سن دستگاه و احتمال خرابی بعدی را هم در نظر بگیرید.',
            ),
          WorthVerdict.replace => (
              theme.colorScheme.error,
              'تعویض به‌صرفه‌تر است',
              'هزینه‌ی تعمیر به نسبت قیمت نو یا عمر دستگاه زیاد است.',
            ),
          null => (theme.colorScheme.outline, '', ''),
        };

        return AlertDialog(
          title: const Text('ارزش تعمیر دارد؟'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('هزینه‌ی تعمیر: ${formatToman(cost)}'),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: InputKinds.moneyFormatters,
                  decoration: const InputDecoration(
                    labelText: 'قیمت تقریبی دستگاه نو (تومان)',
                  ),
                  onChanged: (_) => setLocal(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [DigitsInputFormatter(maxDigits: 2)],
                  decoration: InputDecoration(
                    labelText: 'سن دستگاه (سال)',
                    helperText: 'عمر معمول این دسته: حدود ${toFaDigits(life)} سال',
                  ),
                  onChanged: (_) => setLocal(() {}),
                ),
                if (verdict != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      border: Border.all(color: color),
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: color)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(body),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'نسبت هزینه به قیمت نو: ${toFaDigits((cost * 100 / price).round())}٪',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'قاعده‌ی سرانگشتی: زیر ۳۰٪ قیمت نو ارزش تعمیر دارد، بالای ۵۰٪ معمولاً تعویض بهتر است.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
              onPressed: () async {
                final p = parseIntLoose(priceCtrl.text);
                if (p != null && p > 0) {
                  await appDb.setDeviceNewPrice(device.id, p);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('بستن'),
            ),
          ],
        );
      },
    ),
  );
}
