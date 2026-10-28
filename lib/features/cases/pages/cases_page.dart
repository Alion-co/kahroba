import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/database.dart';
import '../widgets/case_tile.dart';
import 'case_form_page.dart';

/// فیلتر بالای فهرست پرونده‌ها
sealed class _Filter {
  const _Filter();
}

class _Open extends _Filter {
  const _Open();
}

class _All extends _Filter {
  const _All();
}

class _ByStatus extends _Filter {
  const _ByStatus(this.status);
  final CaseStatus status;
}

/// صفحه‌ی فهرست پرونده‌ها با جستجو و فیلتر وضعیت.
/// اگر [initialStatus] داده شود (مثلاً از داشبورد)، با همان فیلتر باز می‌شود.
class CasesPage extends StatefulWidget {
  const CasesPage({super.key, this.initialStatus, this.title});
  final CaseStatus? initialStatus;

  /// عنوان نوار بالا؛ در بخش «پرونده‌ها و مشتری‌ها» سوییچ دو بخش است
  final Widget? title;

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  late _Filter _filter = widget.initialStatus == null
      ? const _Open()
      : _ByStatus(widget.initialStatus!);
  final _search = TextEditingController();
  String _query = '';
  // استریم یک بار ساخته می‌شود تا با هر تایپ دوباره از پایگاه داده خوانده نشود.
  final _cases = appDb.watchCases();

  // ورود پله‌ای کارت‌ها فقط کمی بعد از باز شدن صفحه یا عوض شدن فیلتر
  DateTime _animUntil = DateTime.now().add(const Duration(milliseconds: 900));
  int _filterVersion = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(CaseRow r) {
    final s = r.repairCase.status;
    final statusOk = switch (_filter) {
      _Open() => s.isOpen,
      _All() => true,
      _ByStatus(:final status) => s == status,
    };
    if (!statusOk) return false;
    if (_query.isEmpty) return true;
    return r.searchText.contains(_query);
  }

  void _setFilter(_Filter f) => setState(() {
        _filter = f;
        _filterVersion++;
        _animUntil = DateTime.now().add(const Duration(milliseconds: 900));
      });

  Widget _chip(String label, _Filter f, bool selected) => Padding(
        padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => _setFilter(f),
        ),
      );

  /// برگه‌ی همه‌ی وضعیت‌ها (به‌جای ردیف بلند دکمه‌ها)
  Future<void> _pickStatus() async {
    final current = switch (_filter) {
      _ByStatus(:final status) => status,
      _ => null,
    };
    final picked = await showModalBottomSheet<CaseStatus>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text('فیلتر بر اساس وضعیت',
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
              for (final s in CaseStatus.values)
                ListTile(
                  leading: Icon(Icons.circle,
                      size: 14, color: ctx.statusColors.of(s)),
                  title: Text(s.label),
                  trailing: s == current ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(ctx).pop(s),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) _setFilter(_ByStatus(picked));
  }

  @override
  Widget build(BuildContext context) {
    final f = _filter;
    return Scaffold(
      appBar: AppBar(
        title: widget.title ?? const Text('پرونده‌ها'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: context.rs.centered(context.rs.page()),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'جستجو: کد، نام، شماره، دستگاه',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: (v) =>
                      setState(() => _query = normalizeForSearch(v)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // سه فیلتر اصلی + دکمه‌ی همه‌ی وضعیت‌ها
              Padding(
                padding: context.rs.centered(context.rs.page()),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _chip('در جریان', const _Open(), f is _Open),
                            _chip(
                              'آماده',
                              const _ByStatus(CaseStatus.ready),
                              f is _ByStatus && f.status == CaseStatus.ready,
                            ),
                            _chip('همه', const _All(), f is _All),
                            // وضعیت انتخاب‌شده از برگه (غیر از «آماده»)
                            if (f is _ByStatus && f.status != CaseStatus.ready)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    end: AppSpacing.sm),
                                child: InputChip(
                                  label: Text(f.status.label),
                                  selected: true,
                                  onPressed: _pickStatus,
                                  onDeleted: () => _setFilter(const _Open()),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'همه‌ی وضعیت‌ها',
                        onPressed: _pickStatus,
                        icon: Icon(
                          Icons.tune,
                          color: f is _ByStatus && f.status != CaseStatus.ready
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<CaseRow>>(
        stream: _cases,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'فهرست باز نشد',
              message: 'خطا: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.folder_open_outlined,
              title: 'هنوز پرونده‌ای ثبت نشده',
              message:
                  'هر دستگاهی که به مغازه می‌آید یک پرونده‌ی کددار می‌گیرد.\nاولین دستگاه را همین حالا پذیرش کنید.',
              actionLabel: 'پذیرش اولین دستگاه',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaseFormPage()),
              ),
            );
          }
          final items = all.where(_matches).toList();
          if (items.isEmpty) {
            final searching = _query.isNotEmpty;
            return EmptyState(
              icon: searching ? Icons.search_off : Icons.filter_alt_off_outlined,
              title: searching
                  ? 'چیزی پیدا نشد'
                  : 'پرونده‌ای در این وضعیت نیست',
              message: searching
                  ? 'کد، نام، شماره یا دستگاه را دوباره بررسی کنید.'
                  : 'فیلتر دیگری انتخاب کنید یا همه‌ی پرونده‌ها را ببینید.',
              actionLabel: searching ? 'پاک کردن جستجو' : 'نمایش همه',
              actionIcon: searching ? Icons.close : Icons.list_alt,
              onAction: () => setState(() {
                if (searching) {
                  _search.clear();
                  _query = '';
                } else {
                  _filter = const _All();
                  _filterVersion++;
                }
              }),
            );
          }
          final animate = DateTime.now().isBefore(_animUntil);
          final rs = context.rs;
          // صفحه‌ی پهن: کارت‌ها در چند ستون
          final cols = rs.columns(minTileWidth: 380, max: 3);
          if (cols > 1) {
            return GridView.builder(
              key: ValueKey(_filterVersion),
              padding: rs.page(top: AppSpacing.sm, bottom: AppSpacing.fabClearance),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: rs.gap,
                mainAxisExtent: 116,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => CaseTile(
                item: items[i],
                inset: true,
                enterIndex: animate && i < 12 ? i : null,
              ),
            );
          }
          return ListView.builder(
            key: ValueKey(_filterVersion),
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              bottom: AppSpacing.fabClearance,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => CaseTile(
              item: items[i],
              enterIndex: animate && i < 8 ? i : null,
            ),
          );
        },
      ),

    );
  }
}
