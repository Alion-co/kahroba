import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/motion.dart';
import '../kb_repository.dart';
import 'equivalents_page.dart';
import 'kb_browse_page.dart';
import 'kb_entry_page.dart';

/// بانک فنی، مرحله‌ی اول: برندها.
/// مسیر: برند ← نوع دستگاه ← کد خطا. عیب‌یابی عمومی (بر اساس علامت) جداست.
/// جستجو همیشه در کل بانک انجام می‌شود.
/// در [pickMode]، مورد انتخاب‌شده به پرونده برگردانده می‌شود.
class KbPage extends StatefulWidget {
  const KbPage({super.key, this.pickMode = false, this.initialDevice});
  final bool pickMode;

  /// پیشوند دسته‌ی دستگاه پرونده (برای استفاده‌های بعدی نگه داشته شده)
  final String? initialDevice;

  @override
  State<KbPage> createState() => _KbPageState();
}

class _KbPageState extends State<KbPage> {
  final _search = TextEditingController();
  late final Future<(List<KbEntry>, List<KbBrand>)> _data = _load();
  String _query = '';

  static Future<(List<KbEntry>, List<KbBrand>)> _load() async {
    final repo = KbRepository.instance;
    return (await repo.all(), await repo.brands());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openEntry(KbEntry e) => pushKb(
        context,
        KbEntryPage(entry: e, pickMode: widget.pickMode),
        widget.pickMode,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? 'انتخاب از بانک فنی' : 'بانک فنی'),
        actions: [
          if (!widget.pickMode)
            IconButton(
              tooltip: 'قطعات معادل',
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EquivalentsPage()),
              ),
            ),
        ],
      ),
      body: FutureBuilder<(List<KbEntry>, List<KbBrand>)>(
        future: _data,
        builder: (context, snap) {
          if (snap.hasError) {
            return EmptyState(message: 'بانک فنی خوانده نشد: ${snap.error}');
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (entries, brands) = snap.data!;
          return Column(
            children: [
              Padding(
                padding: context.rs.centered(
                  EdgeInsets.fromLTRB(context.rs.gutter, AppSpacing.sm,
                      context.rs.gutter, AppSpacing.sm),
                ),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'جستجو در کل بانک: کد خطا یا علامت',
                    prefixIcon: const Icon(Icons.search),
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
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              Expanded(
                child: _query.isEmpty
                    ? _browse(context, entries, brands)
                    : _results(entries),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _results(List<KbEntry> entries) {
    final results = KbRepository.instance.search(entries, query: _query);
    if (results.isEmpty) {
      return const EmptyState(
        message:
            'موردی پیدا نشد.\nبانک فنی در حال تکمیل است؛ می‌توانید مورد جدید را در صفحه‌ی GitHub پروژه پیشنهاد دهید.',
      );
    }
    return ListView.separated(
      padding: context.rs.centered(const EdgeInsets.only(bottom: AppSpacing.xl)),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, i) =>
          KbEntryTile(entry: results[i], onTap: _openEntry),
    );
  }

  Widget _browse(
    BuildContext context,
    List<KbEntry> entries,
    List<KbBrand> brands,
  ) {
    final theme = Theme.of(context);
    final counts = KbRepository.countByBrand(entries);
    final general = counts[''] ?? 0;
    // برندی که هنوز کدی ندارد نشان داده نمی‌شود
    final iranian =
        brands.where((b) => b.iranian && (counts[b.id] ?? 0) > 0).toList();
    final foreign =
        brands.where((b) => !b.iranian && (counts[b.id] ?? 0) > 0).toList();

    Widget header(String text) => Padding(
          padding: context.rs.page(top: AppSpacing.lg, bottom: AppSpacing.sm),
          child: Text(text, style: theme.textTheme.titleMedium),
        );

    // گوشی ۳ ستون؛ با پهن شدن صفحه تا ۶ ستون
    Widget grid(List<KbBrand> list) => Padding(
          padding: context.rs.page(),
          child: AdaptiveWrap(
          minTileWidth: 104,
          minColumns: 3,
          maxColumns: 6,
          builder: (w) => [
            for (final b in list)
              SizedBox(
              width: w,
              height: w * 1.02,
              child: _BrandTile(
                brand: b,
                count: counts[b.id] ?? 0,
                onTap: () => pushKb(
                  context,
                  KbDevicesPage(
                    brand: b,
                    entries: entries,
                    pickMode: widget.pickMode,
                  ),
                  widget.pickMode,
                ),
              ),
              ),
          ],
          ),
        );

    return ResponsiveListView(
      columns: 1,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.troubleshoot, color: theme.colorScheme.primary),
            ),
            title: const Text('عیب‌یابی بر اساس علامت'),
            subtitle: Text(
              'بخاری، سماور، اتو و... — مستقل از برند • ${toFaDigits(general)} مورد',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => pushKb(
              context,
              KbDevicesPage(
                brand: null,
                entries: entries,
                pickMode: widget.pickMode,
              ),
              widget.pickMode,
            ),
          ),
        ),
        header('برندهای ایرانی'),
        grid(iranian),
        header('برندهای خارجی'),
        grid(foreign),
      ],
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({
    required this.brand,
    required this.count,
    required this.onTap,
  });

  final KbBrand brand;
  final int count;
  final VoidCallback onTap;

  /// رنگ ثابت و ملایم برای هر برند (از روی شناسه‌اش)
  static Color _tint(String id) {
    var h = 0;
    for (final c in id.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return HSLColor.fromAHSL(1, (h % 360).toDouble(), 0.55, 0.55).toColor();
  }

  /// حرف نشان: اولین حرف نام لاتین (یا فارسی)
  String get _letter {
    final src = brand.en.trim().isNotEmpty ? brand.en.trim() : brand.fa.trim();
    return src.isEmpty ? '?' : src.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final tint = _tint(brand.id);
    final radius = BorderRadius.circular(18);
    return PressScale(
      child: Material(
        color: dark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFFCF8F2),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0x14000000),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tint.withValues(alpha: dark ? 0.22 : 0.14),
                    ),
                    child: Text(
                      _letter,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: dark
                            ? HSLColor.fromColor(tint).withLightness(0.75).toColor()
                            : HSLColor.fromColor(tint).withLightness(0.38).toColor(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      brand.fa,
                      maxLines: 1,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${toFaDigits(count)} کد',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
