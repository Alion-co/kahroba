import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/utils/input_formatters.dart';

typedef PartInput = ({String name, int qty, int unitPrice});

/// پنجره‌ی افزودن قطعه به پرونده.
Future<PartInput?> showPartDialog(BuildContext context) {
  final name = TextEditingController();
  final qty = TextEditingController(text: '1');
  final price = TextEditingController();

  return showDialog<PartInput>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('افزودن قطعه'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'نام قطعه',
              hintText: 'مثلاً ترموکوپل',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: qty,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [DigitsInputFormatter(maxDigits: 3)],
                  decoration: const InputDecoration(labelText: 'تعداد'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  inputFormatters: InputKinds.moneyFormatters,
                  decoration: const InputDecoration(
                    labelText: 'قیمت واحد (تومان)',
                  ),
                ),
              ),
            ],
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
            final n = name.text.trim();
            if (n.isEmpty) return;
            Navigator.of(ctx).pop((
              name: n,
              qty: parseIntLoose(qty.text) ?? 1,
              unitPrice: parseIntLoose(price.text) ?? 0,
            ));
          },
          child: const Text('افزودن'),
        ),
      ],
    ),
  );
}
