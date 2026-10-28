import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/section.dart';

/// ماشین‌حساب‌های روزانه‌ی تعمیرکار — همه آفلاین.
class CalculatorsPage extends StatelessWidget {
  const CalculatorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ماشین‌حساب‌ها')),
      body: ResponsiveListView(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 40),
        children: const [
          _ElementCalc(),
          _OhmCalc(),
          _ResistorColors(),
          _CableTable(),
        ],
      ),
    );
  }
}

String _fmt(double v, [int digits = 1]) {
  if (v.isNaN || v.isInfinite) return '—';
  final s = v.toStringAsFixed(digits);
  return toFaDigits(s.endsWith('.0') ? s.substring(0, s.length - 2) : s);
}

Widget _numField(TextEditingController c, String label, VoidCallback onChanged) =>
    Expanded(
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (_) => onChanged(),
      ),
    );

double? _parse(TextEditingController c) =>
    double.tryParse(toEnDigits(c.text.trim()).replaceAll('٫', '.').replaceAll('/', '.'));

// ───────────── مقاومت المنت

class _ElementCalc extends StatefulWidget {
  const _ElementCalc();
  @override
  State<_ElementCalc> createState() => _ElementCalcState();
}

class _ElementCalcState extends State<_ElementCalc> {
  final _w = TextEditingController(text: '2000');
  final _v = TextEditingController(text: '220');

  @override
  Widget build(BuildContext context) {
    final p = _parse(_w);
    final v = _parse(_v);
    final r = (p != null && v != null && p > 0) ? v * v / p : double.nan;
    final i = (p != null && v != null && v > 0) ? p / v : double.nan;
    return SectionCard(
      title: 'مقاومت سالم المنت',
      icon: Icons.whatshot_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _numField(_w, 'توان (وات)', () => setState(() {})),
            const SizedBox(width: AppSpacing.sm),
            _numField(_v, 'ولتاژ (ولت)', () => setState(() {})),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text('مقاومت مورد انتظار: ${_fmt(r)} اهم',
              style: Theme.of(context).textTheme.titleMedium),
          Text('جریان مصرفی: ${_fmt(i)} آمپر'),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'R = V² ÷ P — مقاومت سرد المنت معمولاً کمی کمتر از این عدد است. مدار باز یعنی سوخته.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ───────────── قانون اهم

class _OhmCalc extends StatefulWidget {
  const _OhmCalc();
  @override
  State<_OhmCalc> createState() => _OhmCalcState();
}

class _OhmCalcState extends State<_OhmCalc> {
  final _v = TextEditingController();
  final _i = TextEditingController();
  final _r = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final v = _parse(_v), i = _parse(_i), r = _parse(_r);
    String result = 'دو مقدار را وارد کنید.';
    if (v != null && i != null && r == null) {
      result = 'مقاومت: ${_fmt(v / i, 2)} اهم • توان: ${_fmt(v * i)} وات';
    } else if (v != null && r != null && i == null) {
      result = 'جریان: ${_fmt(v / r, 2)} آمپر • توان: ${_fmt(v * v / r)} وات';
    } else if (i != null && r != null && v == null) {
      result = 'ولتاژ: ${_fmt(i * r, 2)} ولت • توان: ${_fmt(i * i * r)} وات';
    }
    return SectionCard(
      title: 'قانون اهم و توان',
      icon: Icons.bolt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _numField(_v, 'ولتاژ V', () => setState(() {})),
            const SizedBox(width: AppSpacing.sm),
            _numField(_i, 'جریان A', () => setState(() {})),
            const SizedBox(width: AppSpacing.sm),
            _numField(_r, 'مقاومت Ω', () => setState(() {})),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text(result, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

// ───────────── کد رنگی مقاومت

const _colors = <(String, Color)>[
  ('مشکی', Color(0xFF000000)),
  ('قهوه‌ای', Color(0xFF795548)),
  ('قرمز', Color(0xFFE53935)),
  ('نارنجی', Color(0xFFFB8C00)),
  ('زرد', Color(0xFFFDD835)),
  ('سبز', Color(0xFF43A047)),
  ('آبی', Color(0xFF1E88E5)),
  ('بنفش', Color(0xFF8E24AA)),
  ('خاکستری', Color(0xFF9E9E9E)),
  ('سفید', Color(0xFFFFFFFF)),
];

class _ResistorColors extends StatefulWidget {
  const _ResistorColors();
  @override
  State<_ResistorColors> createState() => _ResistorColorsState();
}

class _ResistorColorsState extends State<_ResistorColors> {
  final _bands = [1, 0, 2]; // قهوه‌ای مشکی قرمز = ۱ کیلواهم

  String _value() {
    final ohms = (_bands[0] * 10 + _bands[1]) * math.pow(10, _bands[2]);
    if (ohms >= 1e6) return '${_fmt(ohms / 1e6, 2)} مگااهم';
    if (ohms >= 1e3) return '${_fmt(ohms / 1e3, 2)} کیلواهم';
    return '${_fmt(ohms.toDouble(), 0)} اهم';
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['رقم اول', 'رقم دوم', 'ضریب'];
    return SectionCard(
      title: 'کد رنگی مقاومت',
      icon: Icons.palette_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var b = 0; b < 3; b++) ...[
            Text(titles[b], style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var c = 0; c < _colors.length; c++)
                  if (!(b == 0 && c == 0))
                    InkWell(
                      onTap: () => setState(() => _bands[b] = c),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _colors[c].$2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: _bands[b] == c ? 3 : 1,
                            color: _bands[b] == c
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            '${_colors[_bands[0]].$1}، ${_colors[_bands[1]].$1}، ${_colors[_bands[2]].$1} = ${_value()}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text('نوار چهارم (تلرانس): طلایی ±۵٪، نقره‌ای ±۱۰٪',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ───────────── جدول سیم و فیوز

class _CableTable extends StatelessWidget {
  const _CableTable();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('۱٫۵', '۱۰', 'روشنایی'),
      ('۲٫۵', '۱۶', 'پریزهای معمولی'),
      ('۴', '۲۰ تا ۲۵', 'کولر، آبگرمکن برقی'),
      ('۶', '۳۲', 'اجاق برقی، مسیر اصلی واحد'),
      ('۱۰', '۴۰ تا ۵۰', 'ورودی اصلی'),
    ];
    final style = Theme.of(context).textTheme.bodyMedium;
    return SectionCard(
      title: 'سیم مسی و فیوز مناسب',
      icon: Icons.cable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(children: [
                Text('سیم (mm²)', style: Theme.of(context).textTheme.labelLarge),
                Text('فیوز (A)', style: Theme.of(context).textTheme.labelLarge),
                Text('کاربرد', style: Theme.of(context).textTheme.labelLarge),
              ]),
              for (final r in rows)
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(r.$1, style: style),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(r.$2, style: style),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(r.$3, style: style),
                  ),
                ]),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'راهنمای عمومی برای سیم‌کشی ساختمان با مسیر کوتاه. برای مسیر طولانی یا شرایط خاص، با مبحث ۱۳ مقررات ملی ساختمان تطبیق دهید.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
