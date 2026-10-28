import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../data/database.dart';
import '../../../core/utils/input_formatters.dart';

/// افزودن یا ویرایش مشتری. اگر [customer] داده شود، حالت ویرایش است.
class CustomerEditPage extends StatefulWidget {
  const CustomerEditPage({super.key, this.customer});
  final Customer? customer;

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  late final _name = TextEditingController(text: widget.customer?.name);
  late final _phone =
      TextEditingController(text: formatPhoneInput(widget.customer?.phone));
  late final _phone2 =
      TextEditingController(text: formatPhoneInput(widget.customer?.phone2));
  late final _address = TextEditingController(text: widget.customer?.address);
  late final _note = TextEditingController(text: widget.customer?.note);
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _phone2, _address, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showSnack(context, 'نام مشتری لازم است.');
      return;
    }
    setState(() => _saving = true);
    try {
      // جلوگیری از ثبت دوباره‌ی یک شماره برای دو مشتری
      final phone = normalizePhone(_phone.text);
      if (phone.isNotEmpty) {
        final other = await appDb.findCustomerByPhone(phone);
        if (other != null && other.id != widget.customer?.id) {
          if (mounted) {
            showSnack(context, 'این شماره قبلاً برای «${other.name}» ثبت شده.');
          }
          return;
        }
      }

      final existing = widget.customer;
      if (existing == null) {
        await appDb.insertCustomer(
          name: name,
          phone: _phone.text,
          phone2: _phone2.text,
          address: _address.text.trim(),
          note: _note.text.trim(),
        );
      } else {
        await appDb.updateCustomer(
          existing.id,
          name: name,
          phone: _phone.text,
          phone2: _phone2.text,
          address: _address.text.trim(),
          note: _note.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, 'ذخیره نشد: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'مشتری جدید' : 'ویرایش مشتری'),
      ),
      body: ResponsiveListView(
        readable: true,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'نام'),
            textInputAction: TextInputAction.next,
          ),
          gap,
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'شماره تماس'),
            keyboardType: TextInputType.phone,
            inputFormatters: InputKinds.phoneFormatters,
            textDirection: InputKinds.phoneDirection,
            textAlign: TextAlign.right,
            textInputAction: TextInputAction.next,
          ),
          gap,
          TextField(
            controller: _phone2,
            decoration: const InputDecoration(labelText: 'شماره دوم (اختیاری)'),
            keyboardType: TextInputType.phone,
            inputFormatters: InputKinds.phoneFormatters,
            textDirection: InputKinds.phoneDirection,
            textAlign: TextAlign.right,
            textInputAction: TextInputAction.next,
          ),
          gap,
          TextField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'آدرس'),
            minLines: 1,
            maxLines: 3,
          ),
          gap,
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'یادداشت',
              hintText: 'مثلاً زنگ طبقه دوم خراب است',
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }
}
