import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/section.dart';
import '../../data/database.dart';

/// گزارش یک ماه شمسی: درآمد، تعداد کارها، دسته‌ها، خرابی‌ها و قطعات پرمصرف.
/// درآمد بر اساس پرونده‌هایی حساب می‌شود که در همان ماه تحویل داده شده‌اند.
class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  late int _year;
  late int _month;
  late Future<(List<CaseRow>, List<CasePart>)> _data;

  @override
  void initState() {
    super.initState();
    final now = Jalali.now();
    _year = now.year;
    _month = now.month;
    _data = _load();
  }

  Future<(List<CaseRow>, List<CasePart>)> _load() async =>
      (await appDb.getCases(), await appDb.getAllParts());

  void _shift(int delta) {
    var m = _month + delta;
    var y = _year;
    if (m < 1) {
      m = 12;
      y--;
    } else if (m > 12) {
      m = 1;
      y++;
    }
    setState(() {
      _year = y;
      _month = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش ماهانه')),
      body: FutureBuilder<(List<CaseRow>, List<CasePart>)>(
        future: _data,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (cases, parts) = snap.data!;
          return _body(context, cases, parts);
        },
      ),
    );
  }

  Widget _body(BuildContext context, List<CaseRow> cases, List<CasePart> parts) {
    final theme = Theme.of(context);
    final (start, end) = jalaliMonthRange(_year, _month);
    bool inMonth(DateTime? d) =>
        d != null && !d.isBefore(start) && d.isBefore(end);

    final received = cases.where((r) => inMonth(r.repairCase.receivedAt)).toList();
    final delivered =
        cases.where((r) => inMonth(r.repairCase.deliveredAt)).toList();
    final deliveredIds = {for (final r in delivered) r.repairCase.id};

    final partsOfDelivered =
        parts.where((p) => deliveredIds.contains(p.caseId)).toList();
    final labor = delivered.fold<int>(0, (s, r) => s + r.repairCase.labor);
    final partsIncome =
        partsOfDelivered.fold<int>(0, (s, p) => s + p.qty * p.unitPrice);

    Map<String, int> countBy(Iterable<String> keys) {
      final m = <String, int>{};
      for (final k in keys) {
        if (k.trim().isEmpty) continue;
        m[k.trim()] = (m[k.trim()] ?? 0) + 1;
      }
      return m;
    }

    final byCategory = countBy(received.map((r) => r.category.name));
    final faults = countBy(delivered.map((r) => r.repairCase.actualFault));
    final partCounts = <String, int>{};
    for (final p in partsOfDelivered) {
      partCounts[p.name] = (partCounts[p.name] ?? 0) + p.qty;
    }

    Widget ranked(Map<String, int> m, String empty) {
      if (m.isEmpty) {
        return Text(empty, style: TextStyle(color: theme.colorScheme.outline));
      }
      final sorted = m.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return Column(
        children: [
          for (final e in sorted.take(8))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(e.key)),
                  Text(toFaDigits(e.value)),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
            ),
        ],
      );
    }

    return ResponsiveListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'ماه قبل',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shift(-1),
              ),
              Text(
                '${jalaliMonthNames[_month - 1]} ${toFaDigits(_year)}',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                tooltip: 'ماه بعد',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shift(1),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'درآمد (پرونده‌های تحویل‌شده)',
          icon: Icons.payments_outlined,
          child: Column(
            children: [
              InfoRow(label: 'اجرت', value: formatToman(labor)),
              InfoRow(label: 'فروش قطعات', value: formatToman(partsIncome)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Text('جمع', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      formatToman(labor + partsIncome),
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'تعداد کارها',
          icon: Icons.folder_outlined,
          child: Column(
            children: [
              InfoRow(label: 'پذیرش‌شده', value: toFaDigits(received.length)),
              InfoRow(label: 'تحویل‌شده', value: toFaDigits(delivered.length)),
            ],
          ),
        ),
        SectionCard(
          title: 'پذیرش به تفکیک دستگاه',
          icon: Icons.devices_other,
          child: ranked(byCategory, 'در این ماه پذیرشی نبوده.'),
        ),
        SectionCard(
          title: 'خرابی‌های پرتکرار',
          icon: Icons.troubleshoot,
          child: ranked(faults, 'برای پرونده‌های این ماه «عیب واقعی» ثبت نشده.'),
        ),
        SectionCard(
          title: 'قطعات مصرفی (برای خرید انبار)',
          icon: Icons.inventory_2_outlined,
          child: ranked(partCounts, 'قطعه‌ای ثبت نشده.'),
        ),
      ],
    );
  }
}
