import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../theme/app_spacing.dart';
import '../utils/format.dart';
import '../utils/text_utils.dart';

/// تقویم شمسی ماهانه به‌صورت برگه‌ی پایین صفحه.
/// روز انتخاب‌شده (DateTime میلادی، فقط تاریخ) یا null برمی‌گرداند.
/// روزهای قبل از [firstDate] قابل انتخاب نیستند.
Future<DateTime?> showJalaliDatePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  String title = 'انتخاب تاریخ',
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: JalaliCalendar(
          title: title,
          initial: initial,
          firstDate: firstDate,
          onPick: (d) => Navigator.of(ctx).pop(d),
        ),
      ),
    ),
  );
}

class JalaliCalendar extends StatefulWidget {
  const JalaliCalendar({
    super.key,
    required this.onPick,
    this.initial,
    this.firstDate,
    this.title = 'انتخاب تاریخ',
  });

  final ValueChanged<DateTime> onPick;
  final DateTime? initial;
  final DateTime? firstDate;
  final String title;

  @override
  State<JalaliCalendar> createState() => _JalaliCalendarState();
}

class _JalaliCalendarState extends State<JalaliCalendar> {
  static const _weekHeads = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  late final Jalali _today = Jalali.now();
  late final Jalali? _selected =
      widget.initial == null ? null : Jalali.fromDateTime(widget.initial!);
  late int _year = (_selected ?? _today).year;
  late int _month = (_selected ?? _today).month;

  void _shift(int delta) {
    setState(() {
      var m = _month + delta;
      var y = _year;
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

  bool _disabled(Jalali d) {
    final first = widget.firstDate;
    if (first == null) return false;
    return DateUtils.dateOnly(d.toDateTime())
        .isBefore(DateUtils.dateOnly(first));
  }

  bool _same(Jalali? a, Jalali b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final first = Jalali(_year, _month, 1);
    final length = first.monthLength;
    // در shamsi_date روز هفته از شنبه (۱) شروع می‌شود
    final lead = first.weekDay - 1;
    final cells = lead + length;
    final rows = (cells / 7).ceil();

    Widget quick(String label, Jalali d) => ActionChip(
          label: Text(label),
          onPressed: _disabled(d) ? null : () => widget.onPick(d.toDateTime()),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            quick('امروز', _today),
            quick('فردا', _today.addDays(1)),
            quick('پس‌فردا', _today.addDays(2)),
            quick('هفته‌ی بعد', _today.addDays(7)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // سرصفحه‌ی ماه: در راست‌به‌چپ «ماه قبل» سمت راست است
        Row(
          children: [
            IconButton(
              tooltip: 'ماه قبل',
              onPressed: () => _shift(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${jalaliMonthNames[_month - 1]} ${toFaDigits(_year)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'ماه بعد',
              onPressed: () => _shift(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    _weekHeads[i],
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
                Expanded(child: _cell(r * 7 + c - lead + 1, length, c == 6)),
            ],
          ),
      ],
    );
  }

  Widget _cell(int day, int length, bool friday) {
    if (day < 1 || day > length) return const SizedBox(height: 44);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final d = Jalali(_year, _month, day);
    final isToday = _same(_today, d);
    final isSelected = _same(_selected, d);
    final disabled = _disabled(d);
    final color = disabled
        ? scheme.onSurface.withValues(alpha: 0.3)
        : isSelected
            ? scheme.onPrimary
            : friday
                ? scheme.error
                : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: disabled ? null : () => widget.onPick(d.toDateTime()),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? scheme.primary : null,
            border: isToday && !isSelected
                ? Border.all(color: scheme.primary, width: 1.5)
                : null,
          ),
          child: Text(
            toFaDigits(day),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight:
                  isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
