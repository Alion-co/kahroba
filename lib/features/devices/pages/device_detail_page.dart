import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/services/photo_store.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/photo_view_page.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/stored_image.dart';
import '../../../data/database.dart';
import '../../cases/pages/case_form_page.dart';
import '../../cases/widgets/case_tile.dart';
import '../../customers/pages/customer_detail_page.dart';
import 'device_edit_page.dart';

/// متنی که داخل QR دستگاه قرار می‌گیرد. اسکنر برنامه (بسته‌ی بعدی) همین را می‌خواند.
String deviceQrData(String code) => 'KAHROBA:$code';

/// شناسنامه‌ی دستگاه: مشخصات، برچسب QR و سابقه‌ی تعمیرات.
class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({super.key, required this.deviceId});
  final int deviceId;

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  late final _device = appDb.watchDevice(widget.deviceId);
  late final _cases = appDb.watchCasesOfDevice(widget.deviceId);
  Stream<Customer?>? _customer;

  Future<void> _takeNameplate(DeviceInfo info) async {
    try {
      final path = await PhotoStore.capture();
      if (path == null) return;
      final old = info.device.nameplatePhoto;
      await appDb.setNameplatePhoto(info.device.id, path);
      if (old != null) await PhotoStore.delete(old);
    } catch (e) {
      if (mounted) showSnack(context, 'عکس گرفته نشد: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DeviceInfo?>(
      stream: _device,
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) {
          return Scaffold(
            appBar: AppBar(),
            body: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : EmptyState(
                    icon: Icons.search_off,
                    title: 'دستگاه پیدا نشد',
                    message: 'شاید پاک شده باشد.',
                    actionLabel: 'برگشت',
                    actionIcon: Icons.arrow_back,
                    onAction: () => Navigator.of(context).maybePop(),
                  ),
          );
        }
        _customer ??= appDb.watchCustomer(info.device.customerId);
        return StreamBuilder<Customer?>(
          stream: _customer,
          builder: (context, snap) => _build(context, info, snap.data),
        );
      },
    );
  }

  Widget _build(BuildContext context, DeviceInfo info, Customer? customer) {
    final d = info.device;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(d.code),
        actions: [
          IconButton(
            tooltip: 'ویرایش مشخصات',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DeviceEditPage(device: d),
            )),
          ),
        ],
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.fabClearance,
        ),
        children: [
          // ───── برچسب QR
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      CategoryAvatar(iconKey: info.category.icon),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(info.title,
                            style: theme.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                    child: QrImageView(
                      data: deviceQrData(d.code),
                      version: QrVersions.auto,
                      size: 170,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    d.code,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(letterSpacing: 2),
                  ),
                  Text(
                    'از این صفحه عکس بگیرید یا چاپ کنید و روی دستگاه بچسبانید.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ───── مالک
          if (customer != null)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(customer.name),
                subtitle: Text(toFaDigits(customer.phone)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CustomerDetailPage(customerId: customer.id),
                )),
              ),
            ),

          // ───── مشخصات
          SectionCard(
            title: 'مشخصات',
            icon: Icons.info_outline,
            child: Column(
              children: [
                InfoRow(label: 'برند', value: d.brand),
                InfoRow(label: 'مدل', value: d.model),
                InfoRow(label: 'شماره سریال', value: d.serial),
                InfoRow(
                  label: 'سال خرید',
                  value: d.purchaseYear == null ? '' : toFaDigits(d.purchaseYear!),
                ),
                InfoRow(label: 'یادداشت', value: d.note),
              ],
            ),
          ),

          // ───── پلاک مشخصات
          SectionCard(
            title: 'عکس پلاک مشخصات',
            icon: Icons.photo_camera_outlined,
            trailing: IconButton(
              tooltip: d.nameplatePhoto == null ? 'گرفتن عکس' : 'عکس دوباره',
              icon: const Icon(Icons.add_a_photo_outlined),
              onPressed: () => _takeNameplate(info),
            ),
            child: d.nameplatePhoto == null
                ? Text(
                    'یک بار از پلاک مشخصات عکس بگیرید؛ برای همیشه می‌ماند.',
                    style: TextStyle(color: theme.colorScheme.outline),
                  )
                : GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PhotoViewPage(
                        path: d.nameplatePhoto!,
                        title: 'پلاک مشخصات',
                      ),
                    )),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      child: storedImage(
                        d.nameplatePhoto!,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
          ),

          // ───── سابقه‌ی تعمیرات
          StreamBuilder<List<CaseRow>>(
            stream: _cases,
            builder: (context, snap) {
              final cases = snap.data ?? const <CaseRow>[];
              return SectionCard(
                title: 'سابقه‌ی تعمیرات (${toFaDigits(cases.length)})',
                icon: Icons.history,
                child: cases.isEmpty
                    ? Text('تعمیری ثبت نشده.',
                        style: TextStyle(color: theme.colorScheme.outline))
                    : Column(
                        children: [for (final r in cases) CaseTile(item: r, inset: true)],
                      ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: customer == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CaseFormPage(customer: customer, device: info),
              )),
              icon: const Icon(Icons.add),
              label: const Text('تعمیر جدید'),
            ),
    );
  }
}
