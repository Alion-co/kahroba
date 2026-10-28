import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../data/database.dart';
import '../kb_repository.dart';

/// جداکننده‌ی نتیجه‌ی عیب‌یاب وقتی به پرونده برمی‌گردد: «شناسه|||علت»
const kbWizardSeparator = '|||';

/// عیب‌یاب قدم‌به‌قدم: علت‌ها یکی‌یکی، به ترتیب احتمال، با روش بررسی.
/// اگر از پرونده باز شده باشد ([pickMode])، علتِ پیداشده به‌عنوان «عیب واقعی»
/// به پرونده برمی‌گردد.
class KbWizardPage extends StatefulWidget {
  const KbWizardPage({super.key, required this.entry, this.pickMode = false});
  final KbEntry entry;
  final bool pickMode;

  @override
  State<KbWizardPage> createState() => _KbWizardPageState();
}

class _KbWizardPageState extends State<KbWizardPage> {
  int _i = 0;
  bool _notFound = false;

  List<String> get _causes => widget.entry.causes;

  String? _howTo(int i) {
    final steps = widget.entry.steps;
    if (steps.isEmpty) return null;
    return i < steps.length ? steps[i] : null;
  }

  void _found() {
    final cause = _causes[_i];
    if (widget.pickMode) {
      Navigator.of(context)
          .pop('${widget.entry.id}$kbWizardSeparator$cause');
    } else {
      showSnack(context, 'علت: $cause');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = widget.entry;
    final total = _causes.length;

    if (total == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('عیب‌یاب قدم‌به‌قدم')),
        body: const Center(child: Text('برای این مورد علتی ثبت نشده.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('عیب‌یاب قدم‌به‌قدم')),
      body: Padding(
        padding: context.rs.readable(),
        child: _notFound
            ? _NotFound(entry: e, onRestart: () => setState(() {
                  _i = 0;
                  _notFound = false;
                }))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(e.displayTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(
                    value: (_i + 1) / total,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('علت ${toFaDigits(_i + 1)} از ${toFaDigits(total)}',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xl),
                  if (e.safety != null && _i == 0)
                    Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(e.safety!,
                            style: TextStyle(
                                color: theme.colorScheme.onErrorContainer)),
                      ),
                    ),
                  Text('آیا این است؟', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(_causes[_i],
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  if (_howTo(_i) != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.search, color: theme.colorScheme.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(_howTo(_i)!)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _found,
                    icon: const Icon(Icons.check),
                    label: Text(widget.pickMode
                        ? 'همین بود — ثبت در پرونده'
                        : 'همین بود'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                    onPressed: () => setState(() {
                      if (_i + 1 < total) {
                        _i++;
                      } else {
                        _notFound = true;
                      }
                    }),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('نه، بعدی'),
                  ),
                  if (_i > 0)
                    TextButton(
                      onPressed: () => setState(() => _i--),
                      child: const Text('برگشت به علت قبلی'),
                    ),
                ],
              ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.entry, required this.onRestart});
  final KbEntry entry;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.help_outline,
            size: 56, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'علت در این فهرست نبود.\nوقتی پیدایش کردید، در «یادداشت من» ثبتش کنید تا دفعه‌ی بعد کمکتان کند.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () async {
            final v = await showTextEditDialog(
              context,
              title: 'یادداشت من',
              multiline: true,
              hint: 'علت واقعی چه بود؟',
            );
            if (v != null) await appDb.saveKbNote(entry.id, v);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('ثبت در یادداشت من'),
        ),
        TextButton(onPressed: onRestart, child: const Text('شروع دوباره')),
      ],
    );
  }
}
