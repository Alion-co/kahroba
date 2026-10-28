import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/section.dart';
import '../../data/database.dart';
import 'sync_service.dart';

/// همگام‌سازی با همکار از طریق Wi‑Fi محلی.
class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

enum _Mode { choose, host, client }

class _SyncPageState extends State<SyncPage> {
  _Mode _mode = _Mode.choose;

  // ── گوشی اصلی
  SyncHost? _host;
  List<String> _addresses = const [];
  final _log = <String>[];

  // ── گوشی همکار
  final _address = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  String _step = '';
  String _lastAt = '';

  @override
  void initState() {
    super.initState();
    appDb.getSettings().then((s) {
      if (!mounted) return;
      setState(() {
        _address.text = s.get(SyncKeys.lastHost);
        _lastAt = s.get(SyncKeys.lastAt);
      });
    });
  }

  @override
  void dispose() {
    _host?.stop();
    _address.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _startHost() async {
    final host = SyncHost(appDb, onLog: (m) {
      if (mounted) setState(() => _log.insert(0, '${_now()}  $m'));
    });
    try {
      final addrs = await host.start();
      setState(() {
        _host = host;
        _addresses = addrs;
        _mode = _Mode.host;
      });
    } catch (e) {
      if (mounted) showSnack(context, 'روشن کردن همگام‌سازی ممکن نشد: $e');
    }
  }

  Future<void> _stopHost() async {
    await _host?.stop();
    setState(() {
      _host = null;
      _mode = _Mode.choose;
    });
  }

  String _now() {
    final t = TimeOfDay.now();
    return toFaDigits(
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
  }

  Future<void> _runClient() async {
    final raw = toEnDigits(_address.text.trim());
    final code = toEnDigits(_code.text.trim());
    if (raw.isEmpty || code.length != 6) {
      showSnack(context, 'نشانی و کد ۶ رقمی گوشی اصلی را وارد کنید.');
      return;
    }
    var host = raw;
    var port = syncPort;
    final i = raw.lastIndexOf(':');
    if (i > 0) {
      host = raw.substring(0, i);
      port = int.tryParse(raw.substring(i + 1)) ?? syncPort;
    }
    setState(() {
      _busy = true;
      _step = '';
    });
    try {
      final stats = await syncWithHost(
        db: appDb,
        host: host,
        port: port,
        code: code,
        onStep: (s) {
          if (mounted) setState(() => _step = s);
        },
      );
      if (!mounted) return;
      setState(() => _lastAt = DateTime.now().toIso8601String());
      await _showResult(stats);
    } on SyncException catch (e) {
      if (mounted) showSnack(context, e.message);
    } catch (e) {
      if (mounted) showSnack(context, 'همگام‌سازی ناموفق بود: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showResult(SyncStats s) {
    String n(int x) => toFaDigits(x);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, size: 40),
        title: const Text('همگام‌سازی انجام شد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('کارهای این گوشی که به گوشی اصلی رفت:\n'
                  '${n(s.inserted)} مورد جدید، ${n(s.updated)} ویرایش، ${n(s.deleted)} حذف'
                  '${s.merged > 0 ? '، ${n(s.merged)} مورد تکراری یکی شد' : ''}.'),
              const SizedBox(height: AppSpacing.sm),
              const Text('دفتر این گوشی هم با گوشی اصلی یکی شد.'),
              if (s.renamed.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Text('کدهای تکراری که عوض شدند:',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                for (final r in s.renamed) Text('• ${toFaDigits(r)}'),
              ],
              if (s.conflicts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Text('تعارض‌ها (نسخه‌ی گوشی اصلی ماند):',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                for (final c in s.conflicts) Text('• ${toFaDigits(c)}'),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = kIsWeb
        ? const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'همگام‌سازی Wi‑Fi فقط در نسخه‌ی اندروید هست؛ مرورگر اجازه‌ی باز کردن سرویس شبکه را نمی‌دهد.',
              textAlign: TextAlign.center,
            ),
          )
        : switch (_mode) {
            _Mode.choose => _chooser(),
            _Mode.host => _hostView(),
            _Mode.client => _clientView(),
          };
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('همگام‌سازی با همکار'),
          leading: _mode == _Mode.choose || _busy
              ? null
              : BackButton(
                  onPressed: () async {
                    if (_mode == _Mode.host) await _stopHost();
                    setState(() => _mode = _Mode.choose);
                  },
                ),
        ),
        body: body,
      ),
    );
  }

  Widget _chooser() {
    final theme = Theme.of(context);
    Widget option(IconData icon, String title, String text, VoidCallback onTap) =>
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(icon, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(text, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );

    return ResponsiveListView(
      readable: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Text(
          'دو گوشی را به یک Wi‑Fi وصل کنید (یا یکی هات‌اسپات روشن کند و دیگری به آن وصل شود). '
          'اینترنت لازم نیست و هیچ اطلاعاتی از مغازه بیرون نمی‌رود.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        option(Icons.store_mall_directory_outlined, 'این گوشی اصلی است',
            'گوشی اوستا؛ دفتر اصلی مغازه روی این گوشی است', _startHost),
        option(Icons.phone_android, 'این گوشی همکار است',
            'کارهای این گوشی به گوشی اصلی می‌رود و دفتر به‌روز برمی‌گردد',
            () => setState(() => _mode = _Mode.client)),
        const SizedBox(height: AppSpacing.md),
        Text(
          'اگر یک مورد در هر دو گوشی ویرایش شده باشد، نسخه‌ی گوشی اصلی می‌ماند و در گزارش نشان داده می‌شود. '
          'مشتری‌های تکراری با شماره تلفن یکی می‌شوند و کدهای تکراری کد تازه می‌گیرند.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _hostView() {
    final theme = Theme.of(context);
    final host = _host!;
    final big = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );
    return ResponsiveListView(
      readable: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        SectionCard(
          title: 'در گوشی همکار این‌ها را وارد کنید',
          icon: Icons.wifi_tethering,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const Text('نشانی:'),
              if (_addresses.isEmpty)
                const Text('این گوشی به هیچ شبکه‌ای وصل نیست. Wi‑Fi یا هات‌اسپات را روشن کنید.')
              else
                for (final a in _addresses)
                  SelectableText(
                    host.port == syncPort ? a : '$a:${host.port}',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: big,
                  ),
              const SizedBox(height: AppSpacing.md),
              const Text('کد:'),
              SelectableText(
                toFaDigits('${host.code.substring(0, 3)} ${host.code.substring(3)}'),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: big?.copyWith(letterSpacing: 4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'تا وقتی این صفحه باز است، همکار می‌تواند همگام شود. بعد از تمام شدن، صفحه را ببندید.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'گزارش',
          icon: Icons.history,
          child: _log.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text('منتظر گوشی همکار…'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final l in _log) Text(l)],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _stopHost,
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('پایان همگام‌سازی'),
        ),
      ],
    );
  }

  Widget _clientView() {
    final theme = Theme.of(context);
    return ResponsiveListView(
      readable: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Text(
          'در گوشی اصلی «همگام‌سازی با همکار ← این گوشی اصلی است» را بزنید و نشانی و کدی را که نشان می‌دهد این‌جا بنویسید.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _address,
          enabled: !_busy,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹٠-٩.:]')),
          ],
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'نشانی گوشی اصلی',
            hintText: '192.168.1.5',
            prefixIcon: Icon(Icons.router_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _code,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹٠-٩]')),
            LengthLimitingTextInputFormatter(6),
          ],
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'کد ۶ رقمی',
            prefixIcon: Icon(Icons.password),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: _busy ? null : _runClient,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          label: Text(_busy ? (_step.isEmpty ? 'در حال همگام‌سازی…' : _step) : 'همگام‌سازی'),
        ),
        if (_lastAt.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'آخرین همگام‌سازی: ${_formatLast(_lastAt)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'نکته: کارهایی که در این گوشی ثبت می‌کنید اول به گوشی اصلی فرستاده می‌شود و بعد دفتر کامل '
          'از گوشی اصلی برمی‌گردد؛ پس چیزی از دست نمی‌رود. یک نسخه‌ی پشتیبان از تغییرات هم روی همین گوشی می‌ماند.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatLast(String iso) {
    final dt = DateTime.tryParse(iso);
    return dt == null ? '' : formatDateTime(dt);
  }
}
