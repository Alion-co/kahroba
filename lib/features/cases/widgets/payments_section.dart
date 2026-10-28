import 'package:flutter/material.dart';

import '../../../core/services/messages.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/section.dart';
import '../../../data/database.dart';
import '../../../core/utils/input_formatters.dart';

/// بخش پرداخت‌ها در صفحه‌ی پرونده: بیعانه، قسط‌ها، مانده و یادآوری بدهی.
class PaymentsSection extends StatefulWidget {
  const PaymentsSection({super.key, required this.row, required this.total});
  final CaseRow row;

  /// جمع کل هزینه (اجرت + قطعات)
  final int total;

  @override
  State<PaymentsSection> createState() => _PaymentsSectionState();
}

class _PaymentsSectionState extends State<PaymentsSection> {
  late final _payments = appDb.watchPayments(widget.row.repairCase.id);

  Future<void> _add(int due) async {
    final result = await showPaymentDialog(context, suggested: due > 0 ? due : 0);
    if (result == null) return;
    await appDb.addPayment(widget.row.repairCase.id, result.amount,
        note: result.note);
  }

  Future<void> _remind(int due) async {
    final settings = await appDb.getSettings();
    final ok = await CaseMessages.send(
        widget.row, CaseMessages.debt(widget.row, settings, due));
    if (!ok && mounted) showSnack(context, 'شماره‌ای برای مشتری ثبت نشده.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<Payment>>(
      stream: _payments,
      builder: (context, snap) {
        final list = snap.data ?? const <Payment>[];
        final paid = list.fold<int>(0, (s, p) => s + p.amount);
        final due = widget.total - paid;
        final delivered =
            widget.row.repairCase.status == CaseStatus.delivered;
        final dueColor = due > 0
            ? (delivered ? theme.colorScheme.error : theme.colorScheme.primary)
            : const Color(0xFF2E7D32);

        return SectionCard(
          title: 'پرداخت‌ها',
          icon: Icons.payments_outlined,
          trailing: IconButton(
            tooltip: 'ثبت پرداخت',
            icon: const Icon(Icons.add),
            onPressed: () => _add(due),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final p in list)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(formatToman(p.amount)),
                  subtitle: Text(
                    [formatDate(p.at), if (p.note.isNotEmpty) p.note].join(' • '),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showConfirmDialog(
                        context,
                        title: 'حذف پرداخت',
                        message: 'پرداخت ${formatToman(p.amount)} حذف شود؟',
                        confirmLabel: 'حذف',
                        destructive: true,
                      );
                      if (ok) await appDb.deletePayment(p.id);
                    },
                  ),
                ),
              if (list.isEmpty)
                Text(
                  'پرداختی ثبت نشده.',
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              const Divider(),
              InfoRow(label: 'پرداخت‌شده', value: formatToman(paid)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Text(due >= 0 ? 'مانده' : 'اضافه‌پرداخت',
                        style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      due == 0 ? 'تسویه ✓' : formatToman(due.abs()),
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: dueColor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ),
              ),
              if (due > 0 && delivered)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => _remind(due),
                    icon: const Icon(Icons.sms_outlined),
                    label: const Text('پیامک یادآوری بدهی'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

typedef PaymentInput = ({int amount, String note});

/// پنجره‌ی ثبت پرداخت
Future<PaymentInput?> showPaymentDialog(BuildContext context, {int suggested = 0}) {
  final amount = TextEditingController(
      text: suggested > 0 ? suggested.toString() : '');
  final note = TextEditingController();
  return showDialog<PaymentInput>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('ثبت پرداخت'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amount,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: InputKinds.moneyFormatters,
            decoration: const InputDecoration(labelText: 'مبلغ (تومان)'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: note,
            decoration: const InputDecoration(
              labelText: 'توضیح (اختیاری)',
              hintText: 'مثلاً کارت‌به‌کارت',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('انصراف'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: () {
            final v = parseIntLoose(amount.text) ?? 0;
            if (v <= 0) return;
            Navigator.of(ctx).pop((amount: v, note: note.text.trim()));
          },
          child: const Text('ثبت'),
        ),
      ],
    ),
  );
}
