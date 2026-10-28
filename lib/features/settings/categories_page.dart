import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/database.dart';

/// مدیریت دسته‌ها: افزودن دسته‌ی جدید و تغییر نام یا آیکن.
/// پیشوند کد بعد از ساخت عوض نمی‌شود چون روی برچسب‌های QR چاپ شده است.
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _categories = appDb.watchCategories();

  Future<void> _edit({DeviceCategory? existing}) async {
    final name = TextEditingController(text: existing?.name);
    final prefix = TextEditingController(text: existing?.prefix);
    var icon = existing?.icon ?? 'other';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'دسته‌ی جدید' : 'ویرایش دسته'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'نام دسته'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: prefix,
                  enabled: existing == null,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'پیشوند کد (۲ تا ۳ حرف انگلیسی)',
                    hintText: 'مثلاً HD',
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final entry in categoryIcons.entries)
                      ChoiceChip(
                        label: Icon(entry.value, size: 20),
                        selected: icon == entry.key,
                        onSelected: (_) => setLocal(() => icon = entry.key),
                      ),
                  ],
                ),
              ],
            ),
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
    if (ok != true || !mounted) return;

    final n = name.text.trim();
    final p = prefix.text.trim().toUpperCase();
    if (n.isEmpty) {
      showSnack(context, 'نام دسته لازم است.');
      return;
    }
    try {
      if (existing == null) {
        if (!RegExp(r'^[A-Z]{2,3}$').hasMatch(p)) {
          showSnack(context, 'پیشوند باید ۲ یا ۳ حرف انگلیسی باشد.');
          return;
        }
        await appDb.addCategory(name: n, prefix: p, icon: icon);
      } else {
        await appDb.updateCategory(existing.id, name: n, icon: icon);
      }
    } catch (_) {
      if (mounted) showSnack(context, 'این پیشوند قبلاً استفاده شده است.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دسته‌بندی دستگاه‌ها')),
      body: StreamBuilder<List<DeviceCategory>>(
        stream: _categories,
        builder: (context, snap) {
          final items = snap.data ?? const <DeviceCategory>[];
          return ListView.separated(
            padding: context.rs.centered(
                const EdgeInsets.only(bottom: AppSpacing.fabClearance)),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, i) {
              final c = items[i];
              return ListTile(
                leading: CategoryAvatar(iconKey: c.icon),
                title: Text(c.name),
                subtitle: Text('پیشوند کد: ${c.prefix}'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _edit(existing: c),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'دسته‌ی جدید',
        onPressed: () => _edit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
