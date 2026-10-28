import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../data/database.dart';
import '../../../core/utils/input_formatters.dart';

/// ویرایش مشخصات دستگاه. کد دستگاه و دسته قابل تغییر نیستند.
class DeviceEditPage extends StatefulWidget {
  const DeviceEditPage({super.key, required this.device});
  final Device device;

  @override
  State<DeviceEditPage> createState() => _DeviceEditPageState();
}

class _DeviceEditPageState extends State<DeviceEditPage> {
  late final _brand = TextEditingController(text: widget.device.brand);
  late final _model = TextEditingController(text: widget.device.model);
  late final _serial = TextEditingController(text: widget.device.serial);
  late final _year = TextEditingController(
      text: toFaDigits(widget.device.purchaseYear?.toString() ?? ''));
  late final _note = TextEditingController(text: widget.device.note);

  @override
  void dispose() {
    for (final c in [_brand, _model, _serial, _year, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await appDb.updateDevice(
        widget.device.id,
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        serial: toEnDigits(_serial.text.trim()),
        purchaseYear: parseIntLoose(_year.text),
        note: _note.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, 'ذخیره نشد: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppBar(title: Text('ویرایش ${widget.device.code}')),
      body: ResponsiveListView(
        readable: true,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _brand,
            decoration: const InputDecoration(labelText: 'برند'),
          ),
          gap,
          TextField(
            controller: _model,
            decoration: const InputDecoration(labelText: 'مدل'),
          ),
          gap,
          TextField(
            controller: _serial,
            decoration: const InputDecoration(labelText: 'شماره سریال'),
          ),
          gap,
          TextField(
            controller: _year,
            decoration: const InputDecoration(
              labelText: 'سال تقریبی خرید',
              hintText: 'مثلاً ۱۴۰۰',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: const [DigitsInputFormatter(maxDigits: 4)],
          ),
          gap,
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'یادداشت'),
            minLines: 1,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: _save, child: const Text('ذخیره')),
        ],
      ),
    );
  }
}
