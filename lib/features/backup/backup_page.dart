import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';
import '../sync/sync_service.dart';

/// پشتیبان‌گیری و بازیابی کل دفتر (پرونده‌ها، مشتری‌ها، حساب‌ها، عکس‌ها و
/// امضاها، نرخ‌نامه و تنظیمات) در یک فایل. فایل را در تلگرام، ایتا، گوگل‌درایو
/// یا حافظه‌ی گوشی نگه دارید.
class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final _settings = appDb.watchSettings();
  bool _busy = false;
  String? _status;

  Future<void> _backup() async {
    setState(() {
      _busy = true;
      _status = 'در حال آماده کردن فایل…';
    });
    try {
      final data = await buildBackup(appDb);
      final bytes = utf8.encode(jsonEncode(data));
      final j = Jalali.now();
      final name =
          'kahroba-backup-${j.year}${j.month.toString().padLeft(2, '0')}${j.day.toString().padLeft(2, '0')}.json';
      final XFile file;
      if (kIsWeb) {
        file = XFile.fromData(bytes, name: name, mimeType: 'application/json');
      } else {
        final dir = await getTemporaryDirectory();
        final f = File(p.join(dir.path, name));
        await f.writeAsBytes(bytes, flush: true);
        file = XFile(f.path, mimeType: 'application/json');
      }
      await SharePlus.instance.share(ShareParams(
        files: [file],
        text: 'پشتیبان دفتر کهربا — ${formatDate(DateTime.now())}',
      ));
      await appDb.setSetting(
          SettingKeys.lastBackupAt, DateTime.now().toIso8601String());
      if (mounted) {
        setState(() => _status =
            'فایل پشتیبان (${_size(bytes.length)}) ساخته شد. جای امنی نگهش دارید.');
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'پشتیبان ساخته نشد: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile();
    } catch (e) {
      if (mounted) showSnack(context, 'فایل باز نشد: $e');
      return;
    }
    if (picked == null || !mounted) return;

    setState(() {
      _busy = true;
      _status = 'در حال خواندن فایل…';
    });
    try {
      final raw = utf8.decode(await picked.readAsBytes());
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic> || data['format'] != backupFormat) {
        throw const FormatException('این فایل، پشتیبان کهربا نیست.');
      }
      final info = describeBackup(data);
      if (!mounted) return;
      setState(() => _busy = false);
      final ok = await showConfirmDialog(
        context,
        title: 'بازیابی دفتر',
        message: 'پشتیبان ${info.created == null ? '' : 'تاریخ ${formatDateTime(info.created!)} '}'
            'با ${toFaDigits(info.cases)} پرونده و ${toFaDigits(info.customers)} مشتری.\n\n'
            'همه‌ی اطلاعات فعلی این گوشی پاک و با این فایل جایگزین می‌شود. ادامه می‌دهید؟',
        confirmLabel: 'بازیابی',
        destructive: true,
      );
      if (!ok || !mounted) {
        setState(() => _status = null);
        return;
      }
      setState(() {
        _busy = true;
        _status = 'در حال بازیابی…';
      });
      await applyBackup(appDb, data);
      if (mounted) {
        setState(() => _status =
            'دفتر بازیابی شد: ${toFaDigits(info.cases)} پرونده و ${toFaDigits(info.customers)} مشتری.');
      }
    } on FormatException catch (e) {
      if (mounted) setState(() => _status = e.message);
    } catch (e) {
      if (mounted) setState(() => _status = 'بازیابی نشد: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _size(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${toFaDigits((bytes / 1024).ceil())} کیلوبایت';
    }
    return '${toFaDigits((bytes / 1024 / 1024).toStringAsFixed(1))} مگابایت';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('پشتیبان‌گیری')),
      body: StreamBuilder<ShopSettings>(
        stream: _settings,
        builder: (context, snap) {
          final last = snap.data?.lastBackupAt;
          final days = last == null ? null : daysSince(last);
          final stale = days == null || days >= 7;
          return ResponsiveListView(
            readable: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // وضعیت آخرین پشتیبان
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: (stale ? scheme.error : scheme.primary)
                      .withValues(alpha: 0.10),
                  border: Border.all(
                    color: (stale ? scheme.error : scheme.primary)
                        .withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      stale ? Icons.warning_amber_rounded : Icons.verified_outlined,
                      color: stale ? scheme.error : scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        last == null
                            ? 'هنوز پشتیبانی نگرفته‌اید. اگر گوشی خراب یا گم شود، دفتر از دست می‌رود.'
                            : days == 0
                                ? 'آخرین پشتیبان: امروز'
                                : 'آخرین پشتیبان: ${toFaDigits(days!)} روز پیش (${formatDate(last)})',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'فایل پشتیبان همه‌چیز را دارد: پرونده‌ها، مشتری‌ها، حساب‌ها، '
                'عکس‌ها و امضاها، نرخ‌نامه و تنظیمات. آن را برای خودتان در '
                'تلگرام یا ایتا بفرستید یا در حافظه ذخیره کنید. هفته‌ای یک بار کافی است.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _busy ? null : _backup,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('ساخت پشتیبان و ارسال'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _busy ? null : _restore,
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text('بازیابی از فایل'),
              ),
              if (_busy) ...[
                const SizedBox(height: AppSpacing.lg),
                const LinearProgressIndicator(),
              ],
              if (_status != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _status!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
