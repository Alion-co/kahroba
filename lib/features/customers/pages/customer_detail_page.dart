import 'package:flutter/material.dart';

import '../../../core/services/launcher.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section.dart';
import '../../../data/database.dart';
import '../../cases/pages/case_form_page.dart';
import '../../cases/widgets/case_tile.dart';
import '../../devices/pages/device_detail_page.dart';
import 'customer_edit_page.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key, required this.customerId});
  final int customerId;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late final _customer = appDb.watchCustomer(widget.customerId);
  late final _devices = appDb.watchDevicesOfCustomer(widget.customerId);
  late final _cases = appDb.watchCasesOfCustomer(widget.customerId);
  final _money = appDb.watchMoney();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Customer?>(
      stream: _customer,
      builder: (context, snapshot) {
        final c = snapshot.data;
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : EmptyState(
                    icon: Icons.person_off_outlined,
                    title: 'مشتری پیدا نشد',
                    message: 'شاید پاک شده باشد.',
                    actionLabel: 'برگشت',
                    actionIcon: Icons.arrow_back,
                    onAction: () => Navigator.of(context).maybePop(),
                  ),
          );
        }
        return _build(context, c);
      },
    );
  }

  Widget _phoneTile(String phone) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.call_outlined),
        title: Text(toFaDigits(phone), textDirection: TextDirection.ltr,
            textAlign: TextAlign.right),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'تماس',
              icon: const Icon(Icons.call),
              onPressed: () => Launcher.call(phone),
            ),
            IconButton(
              tooltip: 'پیامک',
              icon: const Icon(Icons.sms_outlined),
              onPressed: () => Launcher.sms(phone, ''),
            ),
          ],
        ),
      );

  Widget _build(BuildContext context, Customer c) {
    final theme = Theme.of(context);
    final hasLocation = c.latitude != null && c.longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        actions: [
          IconButton(
            tooltip: 'ویرایش',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CustomerEditPage(customer: c),
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
          SectionCard(
            title: 'اطلاعات تماس',
            icon: Icons.person_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (c.phone.isNotEmpty) _phoneTile(c.phone),
                if (c.phone2.isNotEmpty) _phoneTile(c.phone2),
                if (c.phone.isEmpty && c.phone2.isEmpty)
                  Text('شماره‌ای ثبت نشده.',
                      style: TextStyle(color: theme.colorScheme.outline)),
                if (c.address.isNotEmpty || hasLocation)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(c.address.isEmpty ? 'موقعیت ثبت‌شده' : c.address),
                    trailing: IconButton(
                      tooltip: 'باز کردن در نقشه',
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () => Launcher.map(
                        lat: c.latitude,
                        lng: c.longitude,
                        address: c.address,
                      ),
                    ),
                  ),
                if (c.note.isNotEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sticky_note_2_outlined),
                    title: Text(c.note),
                  ),
              ],
            ),
          ),
          // ───── حساب مشتری
          StreamBuilder<Map<int, CaseMoney>>(
            stream: _money,
            builder: (context, snap) {
              final mine = (snap.data ?? const {})
                  .values
                  .where((m) => m.customerId == c.id)
                  .toList();
              final debt =
                  mine.where((m) => m.isDebt).fold<int>(0, (s, m) => s + m.due);
              final paid = mine.fold<int>(0, (s, m) => s + m.paid);
              if (mine.isEmpty) return const SizedBox.shrink();
              return SectionCard(
                title: 'حساب',
                icon: Icons.account_balance_wallet_outlined,
                child: Column(
                  children: [
                    InfoRow(label: 'جمع پرداختی', value: formatToman(paid)),
                    InfoRow(
                      label: 'بدهی',
                      value: debt > 0 ? formatToman(debt) : 'ندارد ✓',
                    ),
                  ],
                ),
              );
            },
          ),
          StreamBuilder<List<DeviceInfo>>(
            stream: _devices,
            builder: (context, snap) {
              final devices = snap.data ?? const <DeviceInfo>[];
              return SectionCard(
                title: 'دستگاه‌ها',
                icon: Icons.devices_other,
                child: devices.isEmpty
                    ? Text('دستگاهی ثبت نشده.',
                        style: TextStyle(color: theme.colorScheme.outline))
                    : Column(
                        children: [
                          for (final d in devices)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CategoryAvatar(iconKey: d.category.icon),
                              title: Text(d.title),
                              subtitle: Text(d.device.code),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    DeviceDetailPage(deviceId: d.device.id),
                              )),
                            ),
                        ],
                      ),
              );
            },
          ),
          StreamBuilder<List<CaseRow>>(
            stream: _cases,
            builder: (context, snap) {
              final cases = snap.data ?? const <CaseRow>[];
              return SectionCard(
                title: 'پرونده‌ها (${toFaDigits(cases.length)})',
                icon: Icons.folder_outlined,
                child: cases.isEmpty
                    ? Text('پرونده‌ای ثبت نشده.',
                        style: TextStyle(color: theme.colorScheme.outline))
                    : Column(
                        children: [for (final r in cases) CaseTile(item: r, inset: true)],
                      ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CaseFormPage(customer: c),
        )),
        icon: const Icon(Icons.add),
        label: const Text('پرونده جدید'),
      ),
    );
  }
}
