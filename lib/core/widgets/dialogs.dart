import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/input_formatters.dart';
import '../utils/text_utils.dart';

/// پنجره‌ی ویرایش یک متن. اگر کاربر انصراف بدهد null برمی‌گرداند.
Future<String?> showTextEditDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String? hint,
  bool multiline = false,
  bool number = false,
  List<TextInputFormatter>? inputFormatters,
  TextDirection? textDirection,
  TextInputType? keyboardType,
}) {
  // کنترلر عمداً dispose نمی‌شود: انیمیشن بسته‌شدن پنجره هنوز از آن استفاده می‌کند.
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: keyboardType ??
            (number
                ? TextInputType.number
                : (multiline ? TextInputType.multiline : TextInputType.text)),
        inputFormatters: inputFormatters,
        textDirection: textDirection,
        textAlign: textDirection == null ? TextAlign.start : TextAlign.right,
        minLines: multiline ? 3 : 1,
        maxLines: multiline ? 6 : 1,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: multiline ? null : (v) => Navigator.of(ctx).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('انصراف'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: () => Navigator.of(ctx).pop(controller.text),
          child: const Text('ذخیره'),
        ),
      ],
    ),
  );
}

/// پنجره‌ی ویرایش عدد. فقط عدد می‌پذیرد (ارقام فارسی هم).
/// [money] یعنی مبلغ: با جداکننده‌ی سه‌رقمی نمایش داده می‌شود.
Future<int?> showNumberEditDialog(
  BuildContext context, {
  required String title,
  int initial = 0,
  String? hint,
  bool money = false,
}) async {
  final text = await showTextEditDialog(
    context,
    title: title,
    initial: money
        ? formatMoneyInput(initial)
        : (initial == 0 ? '' : toFaDigits(initial)),
    hint: hint,
    number: true,
    inputFormatters:
        money ? InputKinds.moneyFormatters : InputKinds.digitsFormatters,
  );
  if (text == null) return null;
  return parseIntLoose(text) ?? 0;
}

/// پنجره‌ی تأیید. true یعنی کاربر تأیید کرد.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'بله',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(88, 40),
              backgroundColor: destructive ? scheme.error : null,
              foregroundColor: destructive ? scheme.onError : null,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void showSnack(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
