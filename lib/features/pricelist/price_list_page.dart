import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../core/utils/input_formatters.dart';

/// نرخ‌نامه‌ی شخصی: کارها و قطعات پرتکرار با قیمت.
/// در صفحه‌ی پرونده با یک لمس اضافه می‌شوند.
class PriceListPage extends StatefulWidget {
  const PriceListPage({super.key});

  @override
  State<PriceListPage> createState() => _PriceListPageState();
}

class _PriceListPageState extends State<PriceListPage> {
  final _items = appDb.watchPriceItems();

  Future<void> _edit([PriceItem? item]) async {
    final name = TextEditingController(text: item?.name);
    final price = TextEditingController(text: formatMoneyInput(item?.price));
    var isPart = item?.isPart ?? false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(item == null ? 'مورد جدید' : 'ویرایش'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('اجرت')),
                  ButtonSegment(value: true, label: Text('قطعه')),
                ],
                selected: {isPart},
                onSelectionChanged: (v) => setLocal(() => isPart = v.first),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: name,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'نام',
                  hintText: isPart ? 'مثلاً ترموکوپل' : 'مثلاً سرویس بخاری',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                inputFormatters: InputKinds.moneyFormatters,
                decoration: const InputDecoration(labelText: 'قیمت (تومان)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('انصراف'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final n = name.text.trim();
    if (n.isEmpty) return;
    final p = parseIntLoose(price.text) ?? 0;
    if (item == null) {
      await appDb.addPriceItem(n, p, isPart);
    } else {
      await appDb.updatePriceItem(item.id, n, p, isPart);
    }
  }

  Future<void> _increase() async {
    final percent = await showNumberEditDialog(
      context,
      title: 'افزایش همه‌ی قیمت‌ها (درصد)',
      hint: 'مثلاً ۲۰',
    );
    if (percent == null || percent <= 0 || !mounted) return;
    final ok = await showConfirmDialog(
      context,
      title: 'افزایش قیمت‌ها',
      message:
          'همه‌ی قیمت‌ها ${toFaDigits(percent)}٪ افزایش پیدا کنند؟ (به نزدیک‌ترین هزار تومان گرد می‌شود)',
      confirmLabel: 'افزایش',
    );
    if (!ok) return;
    await appDb.increaseAllPrices(percent.toDouble());
    if (mounted) showSnack(context, 'قیمت‌ها به‌روز شد.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نرخ‌نامه'),
        actions: [
          IconButton(
            tooltip: 'افزایش همه‌ی قیمت‌ها',
            icon: const Icon(Icons.trending_up),
            onPressed: _increase,
          ),
        ],
      ),
      body: StreamBuilder<List<PriceItem>>(
        stream: _items,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.sell_outlined,
              title: 'نرخ‌نامه خالی است',
              message:
                  'کارها و قطعات پرتکرار را با قیمت ثبت کنید تا در پرونده با یک لمس اضافه شوند.',
              actionLabel: 'افزودن اولین قیمت',
              onAction: () => _edit(),
            );
          }
          return ListView.separated(
            padding: context.rs.centered(
                const EdgeInsets.only(bottom: AppSpacing.fabClearance)),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, i) {
              final it = items[i];
              return ListTile(
                leading: Icon(it.isPart
                    ? Icons.settings_input_component_outlined
                    : Icons.handyman_outlined),
                title: Text(it.name),
                subtitle: Text(it.isPart ? 'قطعه' : 'اجرت'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatToman(it.price)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await showConfirmDialog(
                          context,
                          title: 'حذف',
                          message: '«${it.name}» حذف شود؟',
                          confirmLabel: 'حذف',
                          destructive: true,
                        );
                        if (ok) await appDb.deletePriceItem(it.id);
                      },
                    ),
                  ],
                ),
                onTap: () => _edit(it),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'مورد جدید',
        onPressed: () => _edit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
