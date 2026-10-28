import 'package:flutter/material.dart';

import '../../../core/utils/format.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/database.dart';
import '../../pricelist/price_list_page.dart';

/// برگه‌ی انتخاب از نرخ‌نامه. قطعه به فهرست قطعات پرونده اضافه می‌شود و
/// اجرت به اجرت پرونده افزوده می‌شود.
Future<void> showPricePickerSheet(BuildContext context, int caseId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.6,
        child: StreamBuilder<List<PriceItem>>(
          stream: appDb.watchPriceItems(),
          builder: (ctx, snap) {
            final items = snap.data ?? const <PriceItem>[];
            return Column(
              children: [
                ListTile(
                  title: const Text('افزودن از نرخ‌نامه'),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const PriceListPage()));
                    },
                    child: const Text('ویرایش نرخ‌نامه'),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState(
                          message:
                              'نرخ‌نامه خالی است.\nکارها و قطعات پرتکرار را با قیمتشان یک بار ثبت کنید.',
                        )
                      : ListView(
                          children: [
                            for (final it in items)
                              ListTile(
                                leading: Icon(it.isPart
                                    ? Icons.settings_input_component_outlined
                                    : Icons.handyman_outlined),
                                title: Text(it.name),
                                subtitle: Text(it.isPart ? 'قطعه' : 'اجرت'),
                                trailing: Text(formatToman(it.price)),
                                onTap: () async {
                                  if (it.isPart) {
                                    await appDb.addPart(
                                        caseId, it.name, 1, it.price);
                                  } else {
                                    await appDb.addLabor(caseId, it.price);
                                  }
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                },
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
