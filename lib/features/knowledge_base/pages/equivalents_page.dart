import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/database.dart';

/// قطعات معادلی که تعمیرکار خودش تجربه کرده و ثبت می‌کند.
/// مثلاً «ترموستات سماور مدل X» ← «ترموستات KSD301 با دمای ...».
class EquivalentsPage extends StatefulWidget {
  const EquivalentsPage({super.key});

  @override
  State<EquivalentsPage> createState() => _EquivalentsPageState();
}

class _EquivalentsPageState extends State<EquivalentsPage> {
  final _items = appDb.watchEquivalents();
  String _query = '';

  Future<void> _add() async {
    final part = TextEditingController();
    final eq = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('قطعه‌ی معادل جدید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: part,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'قطعه‌ی اصلی'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: eq,
              decoration: const InputDecoration(labelText: 'معادل'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: note,
              decoration: const InputDecoration(
                labelText: 'توضیح (اختیاری)',
                hintText: 'مثلاً پایه‌ها را باید جابه‌جا کرد',
              ),
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
    );
    if (ok != true) return;
    if (part.text.trim().isEmpty || eq.text.trim().isEmpty) {
      if (mounted) showSnack(context, 'قطعه و معادل هر دو لازم‌اند.');
      return;
    }
    await appDb.addEquivalent(
        part.text.trim(), eq.text.trim(), note.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قطعات معادل')),
      body: StreamBuilder<List<PartEquivalent>>(
        stream: _items,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!;
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.swap_horiz,
              title: 'هنوز معادلی ثبت نکرده‌اید',
              message:
                  'هر بار قطعه‌ای را با قطعه‌ی دیگری جایگزین کردید و جواب داد، اینجا ثبتش کنید.',
              actionLabel: 'ثبت اولین معادل',
              onAction: _add,
            );
          }
          final items = all
              .where((e) => _query.isEmpty ||
                  normalizeForSearch('${e.partName} ${e.equivalent} ${e.note}')
                      .contains(_query))
              .toList();
          return Column(
            children: [
              Padding(
                padding: context.rs.readable(),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'جستجوی قطعه',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      setState(() => _query = normalizeForSearch(v)),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: context.rs.centered(
                      const EdgeInsets.only(bottom: AppSpacing.fabClearance)),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final e = items[i];
                    return ListTile(
                      title: Text(e.partName),
                      subtitle: Text(
                        '← ${e.equivalent}${e.note.isEmpty ? '' : '\n${e.note}'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'حذف',
                            message: 'این معادل پاک شود؟',
                            destructive: true,
                            confirmLabel: 'حذف',
                          );
                          if (ok) await appDb.deleteEquivalent(e.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'افزودن',
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }
}
