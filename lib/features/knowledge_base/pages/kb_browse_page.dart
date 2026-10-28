import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/defaults.dart';
import '../kb_repository.dart';
import 'kb_entry_page.dart';

/// کلید آیکن برای پیشوند دسته (مثل LS ← washer)
String kbIconKey(String prefix) {
  for (final (_, p, icon) in defaultCategories) {
    if (p == prefix) return icon;
  }
  return 'other';
}

/// صفحه را باز می‌کند و اگر در حالت انتخاب، موردی انتخاب شد، آن را به صفحه‌ی
/// قبلی برمی‌گرداند.
Future<void> pushKb(BuildContext context, Widget page, bool pickMode) async {
  final picked = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => page),
  );
  if (picked != null && pickMode && context.mounted) {
    Navigator.of(context).pop(picked);
  }
}

/// مرحله‌ی دوم: دستگاه‌های یک برند (لباسشویی، کولر گازی و...).
/// اگر [brand] null باشد، یعنی عیب‌یابی عمومی بر اساس علامت.
class KbDevicesPage extends StatelessWidget {
  const KbDevicesPage({
    super.key,
    required this.brand,
    required this.entries,
    this.pickMode = false,
  });

  final KbBrand? brand;
  final List<KbEntry> entries;
  final bool pickMode;

  @override
  Widget build(BuildContext context) {
    final b = brand;
    final devices = KbRepository.devicesOf(entries, b?.id ?? '').entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(b == null ? 'عیب‌یابی بر اساس علامت' : b.fa),
      ),
      body: devices.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'هنوز موردی نیست',
              message:
                  'برای ${b?.fa ?? 'این بخش'} هنوز موردی ثبت نشده.\nبانک فنی در حال تکمیل است.',
            )
          : ResponsiveListView(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.xl,
              ),
              children: [
                if (b != null && b.en.isNotEmpty)
                  Padding(
                    padding: context.rs.page(bottom: AppSpacing.sm),
                    child: Text(
                      '${b.en} — نوع دستگاه را انتخاب کنید',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                for (final d in devices)
                  Card(
                    child: ListTile(
                      leading: CategoryAvatar(iconKey: kbIconKey(d.key)),
                      title: Text(KbEntry.deviceName(d.key)),
                      subtitle: Text('${toFaDigits(d.value)} مورد'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => pushKb(
                        context,
                        KbEntriesPage(
                          brand: b,
                          device: d.key,
                          entries: entries,
                          pickMode: pickMode,
                        ),
                        pickMode,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// مرحله‌ی سوم: کدها یا علائم یک دستگاه از یک برند.
class KbEntriesPage extends StatelessWidget {
  const KbEntriesPage({
    super.key,
    required this.brand,
    required this.device,
    required this.entries,
    this.pickMode = false,
  });

  final KbBrand? brand;
  final String device;
  final List<KbEntry> entries;
  final bool pickMode;

  @override
  Widget build(BuildContext context) {
    final brandId = brand?.id ?? '';
    final items = entries
        .where((e) => e.brandId == brandId && e.device == device)
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    final title = [KbEntry.deviceName(device), if (brand != null) brand!.fa]
        .join(' ');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: context.rs.centered(const EdgeInsets.only(bottom: AppSpacing.xl)),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, i) => KbEntryTile(
          entry: items[i],
          showBrand: false,
          onTap: (e) =>
              pushKb(context, KbEntryPage(entry: e, pickMode: pickMode), pickMode),
        ),
      ),
    );
  }
}

/// یک ردیف از فهرست موارد بانک فنی
class KbEntryTile extends StatelessWidget {
  const KbEntryTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.showBrand = true,
  });

  final KbEntry entry;
  final ValueChanged<KbEntry> onTap;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCode = entry.type == KbType.code;
    final subtitle = [
      if (showBrand || !isCode) KbEntry.deviceName(entry.device),
      if (showBrand && entry.brand.isNotEmpty) entry.brand,
      if (isCode && entry.aliases.isNotEmpty) 'مشابه: ${entry.aliasText}',
    ].join(' • ');

    return ListTile(
      leading: isCode
          ? Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                entry.code,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.troubleshoot, color: scheme.primary),
            ),
      title: Text(entry.title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: () => onTap(entry),
    );
  }
}
