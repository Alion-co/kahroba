import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/database.dart';
import 'customer_detail_page.dart';
import 'customer_edit_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key, this.title, this.embedded = false});

  /// عنوان نوار بالا؛ در بخش «پرونده‌ها و مشتری‌ها» سوییچ دو بخش است
  final Widget? title;

  /// داخل بخش ادغامی: دکمه‌ی شناور ندارد (دکمه‌ی + وسط نوار مال پرونده است)
  /// و «مشتری جدید» به نوار بالا می‌رود.
  final bool embedded;

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _customers = appDb.watchCustomers();
  final _money = appDb.watchMoney();
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _newCustomer() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CustomerEditPage()),
      );

  bool _matches(Customer c) {
    if (_query.isEmpty) return true;
    return normalizeForSearch('${c.name} ${c.phone} ${c.phone2} ${c.address}')
        .contains(_query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title ?? const Text('مشتری‌ها'),
        actions: [
          if (widget.embedded)
            IconButton(
              tooltip: 'مشتری جدید',
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: _newCustomer,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: context.rs.centered(EdgeInsets.fromLTRB(
                context.rs.gutter, 0, context.rs.gutter, AppSpacing.sm)),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'جستجو: نام، شماره، آدرس',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = normalizeForSearch(v)),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Customer>>(
        stream: _customers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'هنوز مشتری‌ای ندارید',
              message:
                  'با ثبت اولین پرونده، مشتری خودکار ساخته می‌شود.\nیا همین حالا مشتری را جدا اضافه کنید.',
              actionLabel: 'افزودن مشتری',
              actionIcon: Icons.person_add_alt_1,
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerEditPage()),
              ),
            );
          }
          final items = all.where(_matches).toList();
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.person_search_outlined,
              title: 'مشتری‌ای پیدا نشد',
              message: 'نام یا شماره را دوباره بررسی کنید.',
              actionLabel: 'پاک کردن جستجو',
              actionIcon: Icons.close,
              onAction: () => setState(() {
                _search.clear();
                _query = '';
              }),
            );
          }
          return StreamBuilder<Map<int, CaseMoney>>(
           stream: _money,
           builder: (context, moneySnap) {
            final debt = <int, int>{};
            for (final m in (moneySnap.data ?? const {}).values) {
              if (m.isDebt) debt[m.customerId] = (debt[m.customerId] ?? 0) + m.due;
            }
            return ListView.separated(
            padding: context.rs.centered(
                const EdgeInsets.only(bottom: AppSpacing.fabClearance)),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, i) {
              final c = items[i];
              final due = debt[c.id] ?? 0;
              return ListTile(
                trailing: due <= 0
                    ? null
                    : Text(
                        formatToman(due),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                leading: CircleAvatar(
                  child: Text(c.name.isEmpty ? '?' : c.name.characters.first),
                ),
                title: Text(c.name),
                subtitle: Text(
                  [
                    if (c.phone.isNotEmpty) toFaDigits(c.phone),
                    if (c.address.isNotEmpty) c.address,
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CustomerDetailPage(customerId: c.id),
                )),
              );
            },
          );
           },
          );
        },
      ),
      floatingActionButton: widget.embedded
          ? null
          : FloatingActionButton(
              heroTag: 'customers-fab',
              tooltip: 'مشتری جدید',
              onPressed: _newCustomer,
              child: const Icon(Icons.person_add_alt_1),
            ),
    );
  }
}
