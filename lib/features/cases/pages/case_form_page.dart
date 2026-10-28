import 'package:flutter/material.dart';

import '../../../core/services/messages.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/services/photo_store.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/glass.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/appointment_picker.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/stored_image.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../data/database.dart';
import 'case_detail_page.dart';
import '../../../core/utils/input_formatters.dart';

/// ثبت سریع پرونده (هدف: زیر ۳۰ ثانیه).
/// شماره را بزنید؛ اگر مشتری قبلاً آمده باشد، اسم و دستگاه‌هایش خودکار می‌آید.
class CaseFormPage extends StatefulWidget {
  const CaseFormPage({super.key, this.customer, this.device});

  /// برای «پرونده‌ی جدید برای این مشتری»
  final Customer? customer;

  /// برای «پرونده‌ی جدید برای این دستگاه»
  final DeviceInfo? device;

  @override
  State<CaseFormPage> createState() => _CaseFormPageState();
}

class _CaseFormPageState extends State<CaseFormPage> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _problem = TextEditingController();

  List<DeviceCategory> _categories = [];
  Customer? _customer;
  List<DeviceInfo> _devices = [];

  /// دستگاه قبلی انتخاب‌شده؛ null یعنی «دستگاه جدید»
  int? _deviceId;
  int? _categoryId;
  JobType _jobType = JobType.shop;
  String? _photoPath;
  bool _saving = false;
  bool _saved = false;

  final _deposit = TextEditingController();
  DateTime? _appointment;

  /// اگر دستگاه انتخاب‌شده هنوز در گارانتی تعمیر قبلی است
  RepairCase? _warrantyCase;
  bool _asWarranty = true;

  /// دستگاه قبلی را انتخاب می‌کند و گارانتی تعمیر قبلی‌اش را بررسی می‌کند.
  Future<void> _selectDevice(int? id) async {
    setState(() {
      _deviceId = id;
      _warrantyCase = null;
    });
    if (id == null) return;
    final w = await appDb.activeWarrantyCase(id);
    if (mounted && _deviceId == id) {
      setState(() {
        _warrantyCase = w;
        _asWarranty = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    appDb.getCategories().then((c) {
      if (mounted) setState(() => _categories = c);
    });
    final customer = widget.customer;
    if (customer != null) {
      _phone.text = formatPhoneInput(customer.phone);
      _name.text = customer.name;
      _useCustomer(customer, selectDeviceId: widget.device?.device.id);
    }
  }

  @override
  void dispose() {
    // اگر عکس گرفته شد ولی پرونده ثبت نشد، فایلش را پاک می‌کنیم.
    if (!_saved && _photoPath != null) PhotoStore.delete(_photoPath!);
    _phone.dispose();
    _name.dispose();
    _brand.dispose();
    _problem.dispose();
    _deposit.dispose();
    super.dispose();
  }

  Future<void> _useCustomer(Customer c, {int? selectDeviceId}) async {
    final devices = await appDb.getDevicesOfCustomer(c.id);
    if (!mounted) return;
    setState(() {
      _customer = c;
      _devices = devices;
    });
    await _selectDevice(selectDeviceId);
  }

  Future<void> _onPhoneChanged(String value) async {
    final p = normalizePhone(value);
    if (p.length < 8) {
      if (_customer != null && widget.customer == null) {
        setState(() {
          _customer = null;
          _devices = [];
          _deviceId = null;
        });
      }
      return;
    }
    final found = await appDb.findCustomerByPhone(p);
    if (!mounted) return;
    if (found != null && found.id != _customer?.id) {
      _name.text = found.name;
      await _useCustomer(found);
    } else if (found == null && _customer != null) {
      setState(() {
        _customer = null;
        _devices = [];
        _deviceId = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final path = await PhotoStore.capture();
      if (path == null || !mounted) return;
      if (_photoPath != null) await PhotoStore.delete(_photoPath!);
      setState(() => _photoPath = path);
    } catch (e) {
      if (mounted) showSnack(context, 'عکس گرفته نشد: $e');
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty && _customer == null) {
      showSnack(context, 'نام مشتری را وارد کنید.');
      return;
    }
    if (_deviceId == null && _categoryId == null) {
      showSnack(context, 'نوع دستگاه را انتخاب کنید.');
      return;
    }

    setState(() => _saving = true);
    try {
      final result = await appDb.createCase(
        customerId: _customer?.id,
        customerName: name.isEmpty ? _customer!.name : name,
        phone: _phone.text,
        deviceId: _deviceId,
        categoryId: _categoryId,
        brand: _brand.text.trim(),
        jobType: _jobType,
        problem: _problem.text.trim(),
        status: (_warrantyCase != null && _asWarranty)
            ? CaseStatus.warrantyReturn
            : CaseStatus.received,
        deposit: parseIntLoose(_deposit.text) ?? 0,
        appointmentAt: _jobType == JobType.onSite ? _appointment : null,
        photoPath: _photoPath,
      );
      _saved = true;
      if (!mounted) return;
      await _afterSave(result.id, result.code);
    } catch (e) {
      if (mounted) showSnack(context, 'ثبت نشد: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _afterSave(int caseId, String code) async {
    final hasPhone = normalizePhone(_phone.text).isNotEmpty ||
        (_customer?.phone.isNotEmpty ?? false);
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, size: 40),
        title: Text('پرونده ${toFaDigits(code)} ثبت شد'),
        content: const Text('رسید پذیرش را برای مشتری پیامک کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('open'),
            child: const Text('مشاهده پرونده'),
          ),
          if (hasPhone)
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
              onPressed: () => Navigator.of(ctx).pop('sms'),
              icon: const Icon(Icons.sms_outlined),
              label: const Text('پیامک رسید'),
            ),
        ],
      ),
    );
    if (!mounted) return;

    if (choice == 'sms') {
      final row = await appDb.watchCase(caseId).first;
      final settings = await appDb.getSettings();
      if (row != null) {
        await CaseMessages.send(row, CaseMessages.receipt(row, settings));
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: caseId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.md);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('پرونده جدید')),
      body: ResponsiveListView(
        readable: true,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: 'شماره تماس',
              prefixIcon: Icon(Icons.call),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: InputKinds.phoneFormatters,
            textDirection: InputKinds.phoneDirection,
            textAlign: TextAlign.right,
            autofocus: widget.customer == null,
            onChanged: _onPhoneChanged,
          ),
          gap,
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: 'نام مشتری',
              prefixIcon: const Icon(Icons.person_outline),
              helperText: _customer == null ? null : 'مشتری قبلی — شناخته شد ✓',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ───── دستگاه
          Text('دستگاه', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (_devices.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final d in _devices)
                  ChoiceChip(
                    avatar: Icon(categoryIcon(d.category.icon), size: 18),
                    label: Text('${d.title}  ${d.device.code}'),
                    selected: _deviceId == d.device.id,
                    onSelected: (_) => _selectDevice(d.device.id),
                  ),
                ChoiceChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('دستگاه جدید'),
                  selected: _deviceId == null,
                  onSelected: (_) => _selectDevice(null),
                ),
              ],
            ),
            gap,
          ],
          if (_deviceId == null) ...[
            // کاشی‌های دسته (مطابق طرح)
            // گوشی ۴ ستون؛ صفحه‌ی پهن‌تر بیشتر
            AdaptiveWrap(
              minTileWidth: 72,
              minColumns: 4,
              maxColumns: 7,
              builder: (w) => [
                for (final c in _categories)
                  _CategoryTile(
                    width: w,
                    iconKey: c.icon,
                    label: c.name,
                    selected: _categoryId == c.id,
                    onTap: () => setState(() => _categoryId = c.id),
                  ),
              ],
            ),
            gap,
            TextField(
              controller: _brand,
              decoration: const InputDecoration(
                labelText: 'برند (اختیاری)',
                hintText: 'مثلاً بوتان، پارس‌خزر',
              ),
              textInputAction: TextInputAction.next,
            ),
            gap,
          ],

          if (_deviceId != null && _warrantyCase != null) ...[
            Card(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Text('این دستگاه هنوز در گارانتی است',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'تعمیر قبلی: ${toFaDigits(_warrantyCase!.code)} — تحویل ${formatDate(_warrantyCase!.deliveredAt!)}'
                      '${_warrantyCase!.actualFault.isEmpty ? '' : '\nعیب قبلی: ${_warrantyCase!.actualFault}'}',
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('ثبت به‌عنوان «برگشتی در گارانتی»'),
                      value: _asWarranty,
                      onChanged: (v) => setState(() => _asWarranty = v),
                    ),
                  ],
                ),
              ),
            ),
            gap,
          ],

          // ───── کار
          SegmentedButton<JobType>(
            segments: [
              for (final t in JobType.values)
                ButtonSegment(value: t, label: Text(t.label)),
            ],
            selected: {_jobType},
            onSelectionChanged: (s) => setState(() => _jobType = s.first),
          ),
          if (_jobType == JobType.onSite) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () async {
                final at =
                    await pickAppointment(context, initial: _appointment);
                if (at != null) setState(() => _appointment = at);
              },
              icon: const Icon(Icons.event),
              label: Text(_appointment == null
                  ? 'زمان قرار (اختیاری)'
                  : 'قرار: ${formatAppointment(_appointment!)}'),
            ),
          ],
          gap,
          TextField(
            controller: _problem,
            decoration: const InputDecoration(
              labelText: 'ایراد از زبان مشتری (اختیاری)',
              hintText: 'مثلاً روشن می‌شود ولی خاموش می‌کند',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          gap,
          TextField(
            controller: _deposit,
            keyboardType: TextInputType.number,
            inputFormatters: InputKinds.moneyFormatters,
            decoration: const InputDecoration(
              labelText: 'بیعانه (اختیاری، تومان)',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          gap,

          // ───── عکس
          if (_photoPath == null)
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('عکس از دستگاه'),
            )
          else
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  child: storedImage(
                    _photoPath!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                TextButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('عکس دوباره'),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('ثبت پرونده'),
          ),
        ],
      ),
    );
  }
}

/// کاشی انتخاب دسته در فرم پرونده‌ی جدید
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.width,
    required this.iconKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String iconKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = GlassPalette.of(context).accent;
    return SizedBox(
      width: width,
      child: Material(
        color: selected
            ? amber.withValues(alpha: 0.18)
            : theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? amber : theme.dividerTheme.color ?? Colors.transparent,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              children: [
                CategoryAvatar(iconKey: iconKey, radius: 18),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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
