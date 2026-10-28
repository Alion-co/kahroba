import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/appointment_picker.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../cases/pages/case_form_page.dart';
import '../cases/widgets/case_tile.dart';
import 'today_page.dart';

/// تقویم کارها: ماه شمسی با علامت روی روزهایی که قرار کار در محل دارند،
/// و فهرست کارهای روز انتخاب‌شده. «کارهای در محل» امروز هم همین‌جاست:
/// کارهای باز با دکمه‌ی مسیریابی و تماس، و در «امروز» کارهای بدون زمان هم.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _cases = appDb.watchCases();
  final Jalali _today = Jalali.now();
  late Jalali _selected = _today;
  late int _year = _today.year;
  late int _month = _today.month;

  static const _weekHeads = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  void _shift(int delta) {
    setState(() {
      var m = _month + delta, y = _year;
      if (m < 1) {
        m = 12;
        y--;
      } else if (m > 12) {
        m = 1;
        y++;
      }
      _month = m;
      _year = y;
    });
  }

  void _goToday() => setState(() {
        _selected = _today;
        _year = _today.year;
        _month = _today.month;
      });

  /// کلید روز برای گروه‌بندی: ۱۴۰۵۰۸۰۳
  static int _key(Jalali j) => j.year * 10000 + j.month * 100 + j.day;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقویم کارها'),
        actions: [
          TextButton(onPressed: _goToday, child: const Text('امروز')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CaseFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('کار جدید'),
      ),
      body: StreamBuilder<List<CaseRow>>(
        stream: _cases,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // همه‌ی قرارها (باز و بسته) گروه‌بندی‌شده بر اساس روز شمسی
          final byDay = <int, List<CaseRow>>{};
          for (final r in snap.data!) {
            final a = r.repairCase.appointmentAt;
            if (a == null) continue;
            byDay.putIfAbsent(_key(Jalali.fromDateTime(a)), () => []).add(r);
          }
          for (final l in byDay.values) {
            l.sort((a, b) =>
                a.repairCase.appointmentAt!.compareTo(b.repairCase.appointmentAt!));
          }
          final isToday = _key(_selected) == _key(_today);
          final jobs = [
            ...?byDay[_key(_selected)],
            // کارهای در محلِ باز که هنوز زمان ندارند، زیر «امروز»
            if (isToday)
              ...snap.data!.where((r) =>
                  r.repairCase.jobType == JobType.onSite &&
                  r.repairCase.status.isOpen &&
                  r.repairCase.appointmentAt == null),
          ];

          final calendar = _MonthView(
            year: _year,
            month: _month,
            today: _today,
            selected: _selected,
            weekHeads: _weekHeads,
            countFor: (j) => byDay[_key(j)]?.length ?? 0,
            openFor: (j) =>
                byDay[_key(j)]?.any((r) => r.repairCase.status.isOpen) ?? false,
            onPrev: () => _shift(-1),
            onNext: () => _shift(1),
            onPick: (j) => setState(() => _selected = j),
          );

          final list = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: rs.page(top: AppSpacing.lg, bottom: AppSpacing.sm),
                child: Text(
                  '${_dayTitle(_selected)} • ${toFaDigits(jobs.length)} کار',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (jobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    compact: true,
                    icon: Icons.event_busy_outlined,
                    message: 'برای این روز قراری ثبت نشده.',
                  ),
                )
              else
                for (final r in jobs)
                  r.repairCase.jobType == JobType.onSite &&
                          r.repairCase.status.isOpen
                      ? JobCard(row: r)
                      : CaseTile(item: r),
            ],
          );

          // صفحه‌ی پهن: تقویم و فهرست کنار هم
          if (rs.isExpanded) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: rs.page(top: AppSpacing.md, bottom: 40),
                    children: [calendar],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [list],
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: rs.centered(const EdgeInsets.only(bottom: 96)),
            children: [
              Padding(
                padding: rs.page(top: AppSpacing.md),
                child: calendar,
              ),
              list,
            ],
          );
        },
      ),
    );
  }

  String _dayTitle(Jalali j) {
    final d = j.toDateTime();
    if (_key(j) == _key(_today)) return 'امروز';
    if (_key(j) == _key(_today.addDays(1))) return 'فردا';
    return '${weekDayName(d)} ${formatDayMonth(d)}';
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.year,
    required this.month,
    required this.today,
    required this.selected,
    required this.weekHeads,
    required this.countFor,
    required this.openFor,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final int year;
  final int month;
  final Jalali today;
  final Jalali selected;
  final List<String> weekHeads;
  final int Function(Jalali) countFor;
  final bool Function(Jalali) openFor;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<Jalali> onPick;

  bool _same(Jalali a, Jalali b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final first = Jalali(year, month, 1);
    final length = first.monthLength;
    final lead = first.weekDay - 1; // شنبه = ۱
    final rows = ((lead + length) / 7).ceil();

    Widget cell(int day, bool friday) {
      if (day < 1 || day > length) return const SizedBox(height: 52);
      final d = Jalali(year, month, day);
      final isToday = _same(d, today);
      final isSel = _same(d, selected);
      final count = countFor(d);
      final open = openFor(d);
      return Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onPick(d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            decoration: BoxDecoration(
              color: isSel ? scheme.primary : null,
              borderRadius: BorderRadius.circular(14),
              border: isToday && !isSel
                  ? Border.all(color: scheme.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  toFaDigits(day),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isToday || isSel ? FontWeight.w700 : FontWeight.w400,
                    color: isSel
                        ? scheme.onPrimary
                        : friday
                            ? scheme.error
                            : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                // نقطه‌ها: هر قرار یک نقطه (حداکثر ۳)؛ کهربایی یعنی کار باز
                SizedBox(
                  height: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < count.clamp(0, 3); i++)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSel
                                ? scheme.onPrimary
                                : open
                                    ? scheme.primary
                                    : scheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'ماه قبل',
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '${jalaliMonthNames[month - 1]} ${toFaDigits(year)}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'ماه بعد',
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekHeads[i],
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: i == 6 ? scheme.error : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            for (var r = 0; r < rows; r++)
              Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(child: cell(r * 7 + c - lead + 1, c == 6)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
