import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/responsive/responsive.dart';
import '../../core/services/launcher.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';

/// فصل کمپین و دسته‌های دستگاهی که شامل می‌شود
enum Season {
  winter('پیش از زمستان', 'گرمایشی: بخاری، پکیج، آبگرمکن', {'BK', 'PK', 'AG'},
      Icons.ac_unit, SettingKeys.tplWinter),
  summer('پیش از تابستان', 'سرمایشی: کولر آبی و گازی', {'KA', 'KG'},
      Icons.wb_sunny_outlined, SettingKeys.tplSummer);

  const Season(this.label, this.hint, this.prefixes, this.icon, this.tplKey);
  final String label;
  final String hint;
  final Set<String> prefixes;
  final IconData icon;
  final String tplKey;

  /// فصل پیشنهادی بر اساس ماه شمسی: شهریور تا آذر زمستان، اسفند تا تیر تابستان
  static Season suggested() {
    final m = Jalali.now().month;
    return (m >= 6 && m <= 9) ? Season.winter : (m >= 12 || m <= 4) ? Season.summer : Season.winter;
  }
}

/// یک دستگاه هدف کمپین
class _Target {
  _Target(this.row, this.lastAt, this.count);
  final CaseRow row; // آخرین پرونده‌ی این دستگاه
  final DateTime lastAt;
  final int count;

  int get deviceId => row.device.id;
  String get phone =>
      row.customer.phone.isNotEmpty ? row.customer.phone : row.customer.phone2;
}

/// کمپین فصلی: مشتری‌هایی که دستگاه گرمایشی/سرمایشی‌شان را قبلاً سرویس
/// کرده‌اید، با پیامک آماده یکی‌یکی دعوت می‌شوند. بدون سرور: هر پیامک با
/// برنامه‌ی پیامک خود گوشی فرستاده می‌شود.
class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  final _cases = appDb.watchCases();
  final _settings = appDb.watchSettings();
  Season _season = Season.suggested();

  /// فقط دستگاه‌هایی که در این بازه سرویس شده‌اند (ماه)
  int _months = 18;

  /// شناسه‌ی دور کمپین، مثل winter-1405 (فهرست ارسال‌شده‌ها جدا نگه داشته می‌شود)
  String get _round => '${_season.name}-${Jalali.now().year}';

  Map<String, dynamic> _sentMap(ShopSettings s) {
    try {
      return jsonDecode(s.get(SettingKeys.campaignSent)) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Set<int> _sent(ShopSettings s) =>
      ((_sentMap(s)[_round] as List?) ?? const []).map((e) => e as int).toSet();

  Future<void> _markSent(ShopSettings s, int deviceId, bool sent) async {
    final map = _sentMap(s);
    final set = _sent(s);
    sent ? set.add(deviceId) : set.remove(deviceId);
    map[_round] = set.toList();
    await appDb.setSetting(SettingKeys.campaignSent, jsonEncode(map));
  }

  List<_Target> _targets(List<CaseRow> all) {
    final since = DateTime.now().subtract(Duration(days: _months * 30));
    // سرویس‌شده در ۶۰ روز اخیر لازم نیست دعوت شود
    final recent = DateTime.now().subtract(const Duration(days: 60));
    final byDevice = <int, List<CaseRow>>{};
    for (final r in all) {
      if (!_season.prefixes.contains(r.category.prefix)) continue;
      byDevice.putIfAbsent(r.device.id, () => []).add(r);
    }
    final out = <_Target>[];
    for (final list in byDevice.values) {
      list.sort((a, b) => b.repairCase.receivedAt.compareTo(a.repairCase.receivedAt));
      final last = list.first;
      final at = last.repairCase.receivedAt;
      if (at.isBefore(since) || at.isAfter(recent)) continue;
      out.add(_Target(last, at, list.length));
    }
    out.sort((a, b) => a.lastAt.compareTo(b.lastAt));
    return out;
  }

  String _message(ShopSettings s, _Target t) => fillTemplate(
        s.get(_season.tplKey),
        {
          'shop': s.shopName,
          'shopPhone': toFaDigits(s.shopPhone),
          'name': t.row.customer.name,
          'device': t.row.deviceTitle,
          'code': t.row.device.code,
          'amount': '',
        },
      ).trim();

  Future<void> _send(ShopSettings s, _Target t) async {
    if (t.phone.isEmpty) {
      showSnack(context, 'برای این مشتری شماره‌ای ثبت نشده.');
      return;
    }
    final ok = await Launcher.sms(t.phone, _message(s, t));
    if (ok) await _markSent(s, t.deviceId, true);
  }

  Future<void> _editTemplate(ShopSettings s) async {
    final v = await showTextEditDialog(
      context,
      title: 'متن پیامک ${_season.label}',
      initial: s.get(_season.tplKey),
      hint: '{name} نام • {device} دستگاه • {shop} مغازه • {shopPhone} تلفن',
      multiline: true,
    );
    if (v != null) await appDb.setSetting(_season.tplKey, v.trim());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShopSettings>(
      stream: _settings,
      builder: (context, sSnap) {
        final s = sSnap.data ?? const ShopSettings({});
        return Scaffold(
          appBar: AppBar(
            title: const Text('کمپین فصلی'),
            actions: [
              IconButton(
                tooltip: 'متن پیامک',
                icon: const Icon(Icons.edit_note),
                onPressed: () => _editTemplate(s),
              ),
            ],
          ),
          body: StreamBuilder<List<CaseRow>>(
            stream: _cases,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final targets = _targets(snap.data!);
              final sent = _sent(s);
              final done = targets.where((t) => sent.contains(t.deviceId)).length;
              final rs = context.rs;
              return ListView(
                padding: rs.centered(const EdgeInsets.only(bottom: 40)),
                children: [
                  Padding(
                    padding: rs.page(top: AppSpacing.sm, bottom: AppSpacing.sm),
                    child: SegmentedButton<Season>(
                      segments: [
                        for (final x in Season.values)
                          ButtonSegment(
                            value: x,
                            label: Text(x.label),
                            icon: Icon(x.icon),
                          ),
                      ],
                      selected: {_season},
                      onSelectionChanged: (v) => setState(() => _season = v.first),
                    ),
                  ),
                  Padding(
                    padding: rs.page(),
                    child: Text(
                      _season.hint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: rs.page(top: AppSpacing.sm),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('سرویس‌شده در:'),
                        for (final m in const [12, 18, 24])
                          ChoiceChip(
                            label: Text('${toFaDigits(m)} ماه اخیر'),
                            selected: _months == m,
                            onSelected: (_) => setState(() => _months = m),
                          ),
                      ],
                    ),
                  ),
                  if (targets.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${toFaDigits(done)} از ${toFaDigits(targets.length)} پیامک فرستاده شد',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: targets.isEmpty ? 0 : done / targets.length,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'روی «ارسال» بزنید؛ برنامه‌ی پیامک با متن آماده باز می‌شود. '
                              'بعد از فرستادن برگردید و سراغ نفر بعد بروید.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (targets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: EmptyState(
                        compact: true,
                        icon: Icons.campaign_outlined,
                        message:
                            'در این بازه دستگاهی از این دسته‌ها سرویس نشده.\nبازه‌ی زمانی را بیشتر کنید.',
                      ),
                    ),
                  for (final t in targets)
                    _TargetTile(
                      target: t,
                      sent: sent.contains(t.deviceId),
                      onSend: () => _send(s, t),
                      onToggle: (v) => _markSent(s, t.deviceId, v),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.target,
    required this.sent,
    required this.onSend,
    required this.onToggle,
  });

  final _Target target;
  final bool sent;
  final VoidCallback onSend;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = target.row;
    return Card(
      child: ListTile(
        leading: CategoryAvatar(iconKey: r.category.icon),
        title: Text(
          '${r.customer.name} • ${r.deviceTitle}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: sent
              ? TextStyle(color: theme.colorScheme.onSurfaceVariant)
              : null,
        ),
        subtitle: Text(
          'آخرین سرویس: ${formatDate(target.lastAt)}'
          '${target.count > 1 ? ' • ${toFaDigits(target.count)} بار' : ''}'
          '${target.phone.isEmpty ? ' • بدون شماره' : ''}',
        ),
        trailing: sent
            ? IconButton(
                tooltip: 'برگرداندن به فهرست ارسال‌نشده',
                icon: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                onPressed: () => onToggle(false),
              )
            : FilledButton.tonalIcon(
                onPressed: target.phone.isEmpty ? null : onSend,
                icon: const Icon(Icons.sms_outlined, size: 18),
                label: const Text('ارسال'),
              ),
      ),
    );
  }
}
