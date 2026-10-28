import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/services/share_image.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';

/// کارنامه‌ی ماهانه: تصویر ۱۰۸۰×۱۹۲۰ برای استوری اینستاگرام یا وضعیت واتس‌اپ.
class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final _key = GlobalKey();
  late int _year = Jalali.now().year;
  late int _month = Jalali.now().month;
  late final Future<(List<CaseRow>, ShopSettings)> _data = _load();

  static Future<(List<CaseRow>, ShopSettings)> _load() async =>
      (await appDb.getCases(), await appDb.getSettings());

  void _shift(int d) {
    var m = _month + d, y = _year;
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
      appBar: AppBar(title: const Text('کارنامه‌ی ماهانه')),
      body: FutureBuilder<(List<CaseRow>, ShopSettings)>(
        future: _data,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (cases, settings) = snap.data!;
          final (start, end) = jalaliMonthRange(_year, _month);
          final done = cases.where((r) {
            final d = r.repairCase.deliveredAt;
            return d != null && !d.isBefore(start) && d.isBefore(end);
          }).toList();
          final byCat = <String, (String, int)>{};
          for (final r in done) {
            final k = r.category.name;
            byCat[k] = (r.category.icon, (byCat[k]?.$2 ?? 0) + 1);
          }
          final top = byCat.entries.toList()
            ..sort((a, b) => b.value.$2.compareTo(a.value.$2));

          return ResponsiveListView(
            readable: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _shift(-1),
                  ),
                  Text('${jalaliMonthNames[_month - 1]} ${toFaDigits(_year)}',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _shift(1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: RepaintBoundary(
                  key: _key,
                  child: _Story(
                    shop: settings.shopName,
                    phone: settings.shopPhone,
                    monthLabel: '${jalaliMonthNames[_month - 1]} ${toFaDigits(_year)}',
                    total: done.length,
                    top: [for (final e in top.take(4)) (e.key, e.value.$1, e.value.$2)],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: done.isEmpty
                    ? null
                    : () async {
                        try {
                          await shareWidgetAsImage(_key,
                              fileName: 'kahroba-story', pixelRatio: 3);
                        } catch (e) {
                          if (context.mounted) {
                            showSnack(context, 'ساخت تصویر نشد: $e');
                          }
                        }
                      },
                icon: const Icon(Icons.share),
                label: const Text('اشتراک در استوری'),
              ),
              if (done.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'در این ماه هنوز دستگاهی تحویل داده نشده.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// خود تصویر استوری: ۳۶۰×۶۴۰ منطقی که با ضریب ۳ می‌شود ۱۰۸۰×۱۹۲۰.
class _Story extends StatelessWidget {
  const _Story({
    required this.shop,
    required this.phone,
    required this.monthLabel,
    required this.total,
    required this.top,
  });

  final String shop;
  final String phone;
  final String monthLabel;
  final int total;
  final List<(String, String, int)> top;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFB020);
    const text = Color(0xFFEEF2F8);
    const muted = Color(0xFF9AA6B8);

    Widget glow(double size, Color c) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)]),
          ),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 360,
        height: 640,
        child: Stack(
          children: [
            Container(color: const Color(0xFF0A0E18)),
            Positioned(top: -110, right: -90, child: glow(320, const Color(0x80FFB020))),
            Positioned(bottom: 60, left: -140, child: glow(340, const Color(0x5522D3EE))),
            Positioned(bottom: -120, right: -60, child: glow(280, const Color(0x4D8B5CF6))),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 56, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.bolt, color: amber, size: 40),
                  const SizedBox(height: 8),
                  Text(shop,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: text, fontSize: 24, fontWeight: FontWeight.w700)),
                  Text('کارنامه‌ی $monthLabel',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted, fontSize: 15)),
                  const Spacer(),
                  Text(toFaDigits(total),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: amber, fontSize: 96, fontWeight: FontWeight.w700, height: 1)),
                  const Text('دستگاه تعمیر و تحویل شد',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 28),
                  for (final (name, icon, n) in top)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                      ),
                      child: Row(
                        children: [
                          Icon(categoryIcon(icon), color: amber, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(name,
                                style: const TextStyle(color: text, fontSize: 16)),
                          ),
                          Text(toFaDigits(n),
                              style: const TextStyle(
                                  color: amber, fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  const Spacer(),
                  const Text('از اعتماد شما سپاسگزاریم',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: text, fontSize: 15)),
                  if (phone.isNotEmpty)
                    Text(toFaDigits(phone),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                            color: amber, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  const Text('ساخته‌شده با کهربا',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
