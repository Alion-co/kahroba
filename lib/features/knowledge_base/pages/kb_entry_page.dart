import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/section.dart';
import '../../../data/database.dart';
import '../kb_repository.dart';
import 'kb_wizard_page.dart';

/// جزئیات یک مورد بانک فنی: معنی، علت‌ها، مراحل بررسی (قابل تیک زدن)،
/// قطعات، یادداشت شخصی و آمار تعمیرات خود تعمیرکار.
class KbEntryPage extends StatefulWidget {
  const KbEntryPage({super.key, required this.entry, this.pickMode = false});
  final KbEntry entry;
  final bool pickMode;

  @override
  State<KbEntryPage> createState() => _KbEntryPageState();
}

class _KbEntryPageState extends State<KbEntryPage> {
  late final _note = appDb.watchKbNote(widget.entry.id);
  late final _stats = appDb.faultStatsForKb(widget.entry.id);
  final _checked = <int>{};

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(e.type == KbType.code ? 'کد ${e.code}' : e.type.label),
      ),
      body: ResponsiveListView(
        columns: 1,
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.fabClearance,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    [
                      KbEntry.deviceName(e.device),
                      if (e.brand.isNotEmpty) e.brand,
                      if (e.aliases.isNotEmpty) 'کدهای مشابه: ${e.aliasText}',
                    ].join(' • '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (e.series.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'سری/مدل: ${e.series}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (e.meaning.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(e.meaning, style: theme.textTheme.bodyLarge),
                  ],
                  if (!e.verified) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: theme.colorScheme.outline),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            [
                              if (e.sourceText.isNotEmpty) 'منبع: ${e.sourceText}',
                              if (e.confidenceLabel.isNotEmpty) e.confidenceLabel,
                              'هنوز توسط تعمیرکار باتجربه بازبینی نشده است.',
                            ].join(' — '),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (e.safety != null)
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    color: theme.colorScheme.onErrorContainer),
                title: Text(
                  e.safety!,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
          if (e.causes.length > 1)
            Padding(
              padding: context.rs.page(top: AppSpacing.xs, bottom: AppSpacing.xs),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) =>
                          KbWizardPage(entry: e, pickMode: widget.pickMode),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.of(context).pop(result);
                  }
                },
                icon: const Icon(Icons.alt_route),
                label: const Text('عیب‌یاب قدم‌به‌قدم'),
              ),
            ),
          if (e.causes.isNotEmpty)
            SectionCard(
              title: 'علت‌های محتمل (به ترتیب احتمال)',
              icon: Icons.troubleshoot,
              child: Column(
                children: [
                  for (var i = 0; i < e.causes.length; i++)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 12,
                        child: Text(toFaDigits(i + 1),
                            style: theme.textTheme.labelSmall),
                      ),
                      title: Text(e.causes[i]),
                    ),
                ],
              ),
            ),
          if (e.steps.isNotEmpty)
            SectionCard(
              title: 'مراحل بررسی',
              icon: Icons.checklist,
              child: Column(
                children: [
                  for (var i = 0; i < e.steps.length; i++)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _checked.contains(i),
                      onChanged: (v) => setState(() {
                        if (v ?? false) {
                          _checked.add(i);
                        } else {
                          _checked.remove(i);
                        }
                      }),
                      title: Text(e.steps[i]),
                    ),
                ],
              ),
            ),
          if (e.parts.isNotEmpty)
            SectionCard(
              title: 'قطعات مرتبط',
              icon: Icons.settings_input_component_outlined,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [for (final p in e.parts) Chip(label: Text(p))],
              ),
            ),

          // ───── آمار شخصی
          FutureBuilder<Map<String, int>>(
            future: _stats,
            builder: (context, snap) {
              final stats = snap.data ?? const <String, int>{};
              if (stats.isEmpty) return const SizedBox.shrink();
              final total = stats.values.fold<int>(0, (a, b) => a + b);
              final sorted = stats.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              return SectionCard(
                title: 'تجربه‌ی خود شما',
                icon: Icons.insights,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final s in sorted.take(5))
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Text(
                          'در ${toFaDigits(s.value)} مورد از ${toFaDigits(total)} مورد: ${s.key}',
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // ───── یادداشت شخصی
          StreamBuilder<KbNote?>(
            stream: _note,
            builder: (context, snap) {
              final note = snap.data?.body ?? '';
              return SectionCard(
                title: 'یادداشت من',
                icon: Icons.edit_note,
                child: InfoRow(
                  label: 'تجربه‌ی شخصی',
                  value: note,
                  placeholder: 'مثلاً «در این مدل معمولاً برد است»',
                  onTap: () async {
                    final v = await showTextEditDialog(
                      context,
                      title: 'یادداشت من',
                      initial: note,
                      multiline: true,
                    );
                    if (v != null) await appDb.saveKbNote(e.id, v);
                  },
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: widget.pickMode
          ? SafeArea(
              child: Padding(
                padding: context.rs.readable(),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(e.id),
                  icon: const Icon(Icons.check),
                  label: const Text('ثبت در پرونده'),
                ),
              ),
            )
          : null,
    );
  }
}
