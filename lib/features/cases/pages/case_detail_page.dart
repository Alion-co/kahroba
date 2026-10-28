import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/launcher.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/services/messages.dart';
import '../../../core/services/photo_store.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/appointment_picker.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/photo_view_page.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/signature_pad.dart';
import '../../../core/widgets/stored_image.dart';
import '../../../data/database.dart';
import '../../customers/pages/customer_detail_page.dart';
import '../../devices/pages/device_detail_page.dart';
import '../../knowledge_base/kb_repository.dart';
import '../../knowledge_base/pages/kb_entry_page.dart';
import '../../knowledge_base/pages/kb_page.dart';
import '../../knowledge_base/pages/kb_wizard_page.dart';
import '../widgets/case_progress.dart';
import '../widgets/payments_section.dart';
import '../widgets/price_picker_sheet.dart';
import '../widgets/worth_dialog.dart';
import 'receipt_page.dart';
import '../widgets/part_dialog.dart';
import '../widgets/status_chip.dart';
import '../widgets/status_picker_sheet.dart';

/// صفحه‌ی کامل یک پرونده.
class CaseDetailPage extends StatefulWidget {
  const CaseDetailPage({super.key, required this.caseId});
  final int caseId;

  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage> {
  late final Stream<CaseRow?> _case = appDb.watchCase(widget.caseId);
  late final Stream<List<CasePart>> _parts = appDb.watchParts(widget.caseId);
  late final Stream<List<CasePhoto>> _photos =
  appDb.watchPhotos(widget.caseId);
  late final Stream<List<StatusEvent>> _events =
  appDb.watchEvents(widget.caseId);
  // جدا از تاریخچه، تا هر StreamBuilder شنونده‌ی خودش را داشته باشد
  late final Stream<List<StatusEvent>> _progressEvents =
  appDb.watchEvents(widget.caseId);

  /// آخرین قطعات، برای محاسبه‌ی جمع هنگام پیامک قیمت
  List<CasePart> _lastParts = const [];

  int get _partsTotal =>
      _lastParts.fold<int>(0, (sum, p) => sum + p.qty * p.unitPrice);

  Future<void> _update(RepairCasesCompanion fields) =>
      appDb.updateCaseFields(widget.caseId, fields);

  // ───────── وضعیت و پیامک

  Future<void> _changeStatus(CaseRow row) async {
    final next = await showStatusPickerSheet(context, row.repairCase.status);
    if (next == null || next == row.repairCase.status) return;
    await _applyStatus(row, next);
  }

  /// لمس یک مرحله در نوار مراحل
  Future<void> _onStepTap(CaseRow row, int step) async {
    final current = stepOf(row.repairCase.status);
    if (step == current) return _changeStatus(row);
    final target = caseSteps[step].status;
    if (step < current) {
      final ok = await showConfirmDialog(
        context,
        title: 'برگشت به مرحله‌ی قبل',
        message: 'وضعیت پرونده به «${target.label}» برگردد؟',
        confirmLabel: 'برگردد',
      );
      if (!ok || !mounted) return;
    } else if (target == CaseStatus.delivered) {
      // تحویل زمان ثبت می‌کند؛ با لمس اشتباهی ثبت نشود
      final ok = await showConfirmDialog(
        context,
        title: 'تحویل دستگاه',
        message: 'دستگاه به مشتری تحویل داده شد؟',
        confirmLabel: 'تحویل شد',
      );
      if (!ok || !mounted) return;
    }
    await _applyStatus(row, target);
  }

  Future<void> _applyStatus(CaseRow row, CaseStatus next) async {
    await appDb.setStatus(widget.caseId, next);
    if (!mounted) return;

    if (next == CaseStatus.ready) {
      showSnack(
        context,
        'وضعیت: ${next.label}',
        action: SnackBarAction(
          label: 'خبر به مشتری',
          onPressed: () => _sendReady(row),
        ),
      );
    } else if (next == CaseStatus.awaitingApproval) {
      await _sendApproval(row);
    } else if (next == CaseStatus.delivered) {
      showSnack(
        context,
        'وضعیت: ${next.label}',
        action: SnackBarAction(
          label: 'امضای تحویل',
          onPressed: () async {
            final photos = await appDb.watchPhotos(widget.caseId).first;
            if (mounted) await _sign(PhotoKind.signatureOut, photos);
          },
        ),
      );
    } else {
      showSnack(context, 'وضعیت: ${next.label}');
    }
  }

  Future<void> _sendReady(CaseRow row) async {
    final settings = await appDb.getSettings();
    final ok = await CaseMessages.send(row, CaseMessages.ready(row, settings));
    if (!ok && mounted) showSnack(context, 'شماره‌ای برای مشتری ثبت نشده.');
  }

  Future<void> _sendApproval(CaseRow row) async {
    var amount = row.repairCase.labor + _partsTotal;
    if (amount == 0) {
      final entered = await showNumberEditDialog(
        context,
        title: 'هزینه‌ی برآوردی (تومان)',
        money: true,
      );
      if (entered == null) return;
      amount = entered;
    }
    final settings = await appDb.getSettings();
    final ok = await CaseMessages.send(
      row,
      CaseMessages.approval(row, settings, amount),
    );
    if (!ok && mounted) showSnack(context, 'شماره‌ای برای مشتری ثبت نشده.');
  }

  Future<void> _sendCustom(CaseRow row) async {
    final settings = await appDb.getSettings();
    if (!mounted) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('رسید پذیرش'),
              onTap: () => Navigator.of(ctx).pop('receipt'),
            ),
            ListTile(
              leading: const Icon(Icons.request_quote_outlined),
              title: const Text('اعلام هزینه و درخواست تأیید'),
              onTap: () => Navigator.of(ctx).pop('approval'),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('آماده‌ی تحویل'),
              onTap: () => Navigator.of(ctx).pop('ready'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('پیام آزاد'),
              onTap: () => Navigator.of(ctx).pop('free'),
            ),
          ],
        ),
      ),
    );
    switch (choice) {
      case 'receipt':
        await CaseMessages.send(row, CaseMessages.receipt(row, settings));
      case 'approval':
        await _sendApproval(row);
      case 'ready':
        await _sendReady(row);
      case 'free':
        await CaseMessages.send(row, '');
    }
  }

  // ───────── بانک فنی

  Future<void> _pickKb(CaseRow row) async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => KbPage(
          pickMode: true,
          initialDevice: row.category.prefix,
        ),
      ),
    );
    if (id == null) return;
    // نتیجه‌ی عیب‌یاب قدم‌به‌قدم: «شناسه|||علت» ← عیب واقعی هم ثبت می‌شود
    final parts = id.split(kbWizardSeparator);
    if (parts.length == 2) {
      await _update(RepairCasesCompanion(
        kbRef: Value(parts[0]),
        actualFault: Value(parts[1]),
      ));
    } else {
      await _update(RepairCasesCompanion(kbRef: Value(id)));
    }
  }

  /// تعداد مراجعه‌های اخیر همین دستگاه (برای هشدار تکرار)
  Future<int>? _visits;

  // ───────── عکس

  Future<void> _addPhoto(PhotoKind kind) async {
    try {
      final path = await PhotoStore.capture();
      if (path != null) await appDb.addPhoto(widget.caseId, path, kind);
    } catch (e) {
      if (mounted) showSnack(context, 'عکس گرفته نشد: $e');
    }
  }

  // ───────── امضا

  Future<void> _sign(PhotoKind kind, List<CasePhoto> photos) async {
    final bytes = await SignaturePage.open(
      context,
      title: kind.label,
      subtitle: kind == PhotoKind.signatureIn
          ? 'با امضا، مشتری مشخصات دستگاه و ایراد اعلام‌شده را تأیید می‌کند.'
          : 'با امضا، مشتری تحویل سالم دستگاه را تأیید می‌کند.',
    );
    if (bytes == null) return;
    // امضای قبلی همین نوع جایگزین می‌شود
    for (final p in photos.where((p) => p.kind == kind)) {
      await appDb.deletePhoto(p.id);
      await PhotoStore.delete(p.path);
    }
    final path = await PhotoStore.saveBytes(bytes);
    await appDb.addPhoto(widget.caseId, path, kind);
    if (mounted) showSnack(context, '${kind.label} ثبت شد.');
  }

  // ───────── حذف

  Future<void> _delete(CaseRow row) async {
    final ok = await showConfirmDialog(
      context,
      title: 'حذف پرونده',
      message:
      'پرونده ${toFaDigits(row.repairCase.code)} با همه‌ی قطعات، عکس‌ها و پرداخت‌هایش پاک شود؟ این کار برگشت‌پذیر نیست.',
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (!ok) return;
    try {
      final paths = await appDb.deleteCase(widget.caseId);
      for (final p in paths) {
        await PhotoStore.delete(p);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, 'حذف نشد: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CaseRow?>(
      stream: _case,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final row = snapshot.data;
        if (row == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.search_off,
              title: 'این پرونده پیدا نشد',
              message: 'شاید پاک شده باشد.',
              actionLabel: 'برگشت',
              actionIcon: Icons.arrow_back,
              onAction: () => Navigator.of(context).maybePop(),
            ),
          );
        }
        return _buildPage(context, row);
      },
    );
  }

  Widget _buildPage(BuildContext context, CaseRow row) {
    final c = row.repairCase;
    final theme = Theme.of(context);
    final hasPhone =
        row.customer.phone.isNotEmpty || row.customer.phone2.isNotEmpty;
    final phone =
    row.customer.phone.isNotEmpty ? row.customer.phone : row.customer.phone2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          toFaDigits(c.code),
          textDirection: TextDirection.ltr,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') _delete(row);
              if (v == 'receipt') {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReceiptPage(caseId: c.id),
                ));
              }
              if (v == 'copy') {
                Clipboard.setData(ClipboardData(text: c.code));
                showSnack(context, 'کد پرونده کپی شد.');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'receipt', child: Text('رسید تصویری و چاپ')),
              PopupMenuItem(value: 'copy', child: Text('کپی کد پرونده')),
              PopupMenuItem(value: 'delete', child: Text('حذف پرونده')),
            ],
          ),
        ],
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.fabClearance,
        ),
        children: [
          // ───── سربرگ: وضعیت و کارهای سریع
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      StatusChip(status: c.status),
                      const Spacer(),
                      Text(
                        c.jobType.label,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // ───── نوار مراحل
                  StreamBuilder<List<StatusEvent>>(
                    stream: _progressEvents,
                    builder: (context, snap) => CaseProgressBar(
                      status: c.status,
                      receivedAt: c.receivedAt,
                      events: snap.data ?? const [],
                      onStepTap: (i) => _onStepTap(row, i),
                    ),
                  ),
                  const Divider(height: AppSpacing.xl),
                  Text(
                    'پذیرش: ${formatDateTime(c.receivedAt)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (c.readyAt != null)
                    Text('آماده: ${formatDateTime(c.readyAt!)}'),
                  if (c.deliveredAt != null)
                    Text('تحویل: ${formatDateTime(c.deliveredAt!)}'),
                  if (c.jobType == JobType.onSite)
                    InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      onTap: () async {
                        final at = await pickAppointment(context,
                            initial: c.appointmentAt);
                        if (at != null) {
                          await _update(
                              RepairCasesCompanion(appointmentAt: Value(at)));
                        }
                      },
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Row(
                          children: [
                            Icon(Icons.event, size: 18,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              c.appointmentAt == null
                                  ? 'زمان قرار را تعیین کنید'
                                  : 'قرار: ${formatAppointment(c.appointmentAt!)}',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                          hasPhone ? () => Launcher.call(phone) : null,
                          icon: const Icon(Icons.call),
                          label: const Text('تماس'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: hasPhone ? () => _sendCustom(row) : null,
                          icon: const Icon(Icons.sms_outlined),
                          label: const Text('پیامک'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: () => _changeStatus(row),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('تغییر وضعیت'),
                  ),
                ],
              ),
            ),
          ),

          // ───── هشدار تکرار مراجعه
          FutureBuilder<int>(
            future: _visits ??= appDb.recentVisits(row.device.id),
            builder: (context, snap) {
              final n = snap.data ?? 0;
              if (n < 3) return const SizedBox.shrink();
              return Card(
                color: theme.colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.repeat,
                      color: theme.colorScheme.onErrorContainer),
                  title: Text(
                    'این دستگاه ${toFaDigits(n)} بار در ۶ ماه اخیر آمده است',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                  subtitle: Text(
                    'شاید ایراد ریشه‌ای دارد؛ سابقه‌ی تعمیرات را ببینید.',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DeviceDetailPage(deviceId: row.device.id),
                  )),
                ),
              );
            },
          ),

          // ───── مشتری و دستگاه
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(row.customer.name),
                  subtitle: Text(
                    hasPhone ? toFaDigits(phone) : 'بدون شماره',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CustomerDetailPage(customerId: row.customer.id),
                  )),
                ),
                const Divider(),
                ListTile(
                  leading: CategoryAvatar(iconKey: row.category.icon),
                  title: Text(row.deviceTitle),
                  subtitle: Text('کد دستگاه: ${row.device.code}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DeviceDetailPage(deviceId: row.device.id),
                  )),
                ),
              ],
            ),
          ),

          // ───── ایراد و عیب
          SectionCard(
            title: 'ایراد و عیب‌یابی',
            icon: Icons.build_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoRow(
                  label: 'ایراد مشتری',
                  value: c.reportedProblem,
                  onTap: () async {
                    final v = await showTextEditDialog(
                      context,
                      title: 'ایراد از زبان مشتری',
                      initial: c.reportedProblem,
                      multiline: true,
                    );
                    if (v != null) {
                      await _update(
                          RepairCasesCompanion(reportedProblem: Value(v.trim())));
                    }
                  },
                ),
                InfoRow(
                  label: 'عیب واقعی',
                  value: c.actualFault,
                  placeholder: 'هنوز ثبت نشده',
                  onTap: () async {
                    final v = await showTextEditDialog(
                      context,
                      title: 'عیبی که پیدا کردید',
                      initial: c.actualFault,
                      hint: 'مثلاً ترموکوپل سوخته',
                    );
                    if (v != null) {
                      await _update(
                          RepairCasesCompanion(actualFault: Value(v.trim())));
                    }
                  },
                ),
                _KbLink(
                  kbRef: c.kbRef,
                  onPick: () => _pickKb(row),
                  onClear: () =>
                      _update(const RepairCasesCompanion(kbRef: Value(''))),
                ),
              ],
            ),
          ),

          // ───── قطعات و هزینه
          StreamBuilder<List<CasePart>>(
            stream: _parts,
            builder: (context, snap) {
              final parts = snap.data ?? const <CasePart>[];
              _lastParts = parts;
              final partsTotal = _partsTotal;
              final total = c.labor + partsTotal;
              return Column(children: [
                SectionCard(
                  title: 'قطعات و هزینه',
                  icon: Icons.receipt_long_outlined,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'از نرخ‌نامه',
                        icon: const Icon(Icons.playlist_add),
                        onPressed: () =>
                            showPricePickerSheet(context, widget.caseId),
                      ),
                      IconButton(
                        tooltip: 'افزودن قطعه',
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final part = await showPartDialog(context);
                          if (part != null) {
                            await appDb.addPart(widget.caseId, part.name,
                                part.qty, part.unitPrice);
                          }
                        },
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (parts.isEmpty)
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Text(
                            'قطعه‌ای ثبت نشده.',
                            style: TextStyle(color: theme.colorScheme.outline),
                          ),
                        ),
                      for (final p in parts)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(p.name),
                          subtitle: Text(
                            '${toFaDigits(p.qty)} × ${formatToman(p.unitPrice)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(formatToman(p.qty * p.unitPrice)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => appDb.deletePart(p.id),
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      InfoRow(
                        label: 'اجرت',
                        value: formatToman(c.labor),
                        onTap: () async {
                          final v = await showNumberEditDialog(
                            context,
                            title: 'اجرت (تومان)',
                            initial: c.labor,
                            money: true,
                          );
                          if (v != null) {
                            await _update(RepairCasesCompanion(labor: Value(v)));
                          }
                        },
                      ),
                      InfoRow(label: 'جمع قطعات', value: formatToman(partsTotal)),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            Text('جمع کل', style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Text(
                              formatToman(c.labor + partsTotal),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                        ),
                      ),
                      InfoRow(
                        label: 'گارانتی تعمیر',
                        value: c.warrantyDays == 0
                            ? 'ندارد'
                            : '${toFaDigits(c.warrantyDays)} روز'
                            '${c.deliveredAt == null ? '' : ' — تا ${formatDate(c.deliveredAt!.add(Duration(days: c.warrantyDays)))}'}',
                        onTap: () async {
                          final v = await showNumberEditDialog(
                            context,
                            title: 'مدت گارانتی (روز)',
                            initial: c.warrantyDays,
                          );
                          if (v != null) {
                            await _update(
                                RepairCasesCompanion(warrantyDays: Value(v)));
                          }
                        },
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => showWorthDialog(context, row, total),
                          icon: const Icon(Icons.balance),
                          label: const Text('ارزش تعمیر دارد؟'),
                        ),
                      ),
                    ],
                  ),
                ),
                PaymentsSection(row: row, total: total),
              ]);
            },
          ),

          // ───── عکس‌ها
          StreamBuilder<List<CasePhoto>>(
            stream: _photos,
            builder: (context, snap) {
              final all = snap.data ?? const <CasePhoto>[];
              final photos = all.where((p) => !p.kind.isSignature).toList();
              final photosSection = SectionCard(
                title: 'عکس‌ها',
                icon: Icons.photo_camera_outlined,
                trailing: PopupMenuButton<PhotoKind>(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  onSelected: _addPhoto,
                  itemBuilder: (_) => [
                    for (final k in PhotoKind.values)
                      if (!k.isSignature)
                        PopupMenuItem(value: k, child: Text(k.label)),
                  ],
                ),
                child: photos.isEmpty
                    ? Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'عکسی ثبت نشده.',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                )
                    : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final p in photos)
                      _PhotoThumb(
                        photo: p,
                        onDelete: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'حذف عکس',
                            message: 'این عکس پاک شود؟',
                            confirmLabel: 'حذف',
                            destructive: true,
                          );
                          if (!ok) return;
                          await appDb.deletePhoto(p.id);
                          await PhotoStore.delete(p.path);
                        },
                      ),
                  ],
                ),
              );
              // ───── امضای مشتری
              final signSection = SectionCard(
                title: 'امضای مشتری',
                icon: Icons.draw_outlined,
                child: Row(
                  children: [
                    for (final k in const [
                      PhotoKind.signatureIn,
                      PhotoKind.signatureOut,
                    ]) ...[
                      if (k == PhotoKind.signatureOut)
                        const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SignatureSlot(
                          label: k.label,
                          photo: _lastOfKind(all, k),
                          onSign: () => _sign(k, all),
                        ),
                      ),
                    ],
                  ],
                ),
              );
              return Column(children: [photosSection, signSection]);
            },
          ),

          // ───── یادداشت خصوصی
          SectionCard(
            title: 'یادداشت خصوصی',
            icon: Icons.lock_outline,
            child: InfoRow(
              label: 'فقط برای شما',
              value: c.privateNote,
              onTap: () async {
                final v = await showTextEditDialog(
                  context,
                  title: 'یادداشت خصوصی',
                  initial: c.privateNote,
                  multiline: true,
                );
                if (v != null) {
                  await _update(
                      RepairCasesCompanion(privateNote: Value(v.trim())));
                }
              },
            ),
          ),

          // ───── تاریخچه
          StreamBuilder<List<StatusEvent>>(
            stream: _events,
            builder: (context, snap) {
              final events = snap.data ?? const <StatusEvent>[];
              return SectionCard(
                title: 'تاریخچه',
                icon: Icons.history,
                child: Column(
                  children: [
                    for (final e in events.reversed)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.circle,
                          size: 12,
                          color: context.statusColors.of(e.status),
                        ),
                        title: Text(e.status.label),
                        trailing: Text(formatDateTime(e.at)),
                      ),
                  ],
                ),
              );
            },
          ),

          // ───── حذف پرونده
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: OutlinedButton.icon(
              onPressed: () => _delete(row),
              icon: const Icon(Icons.delete_outline),
              label: const Text('حذف پرونده'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نمایش مورد بانک فنی وصل‌شده به پرونده
class _KbLink extends StatelessWidget {
  const _KbLink({
    required this.kbRef,
    required this.onPick,
    required this.onClear,
  });

  final String kbRef;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (kbRef.isEmpty) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('جستجو در بانک فنی'),
        ),
      );
    }
    return FutureBuilder<KbEntry?>(
      future: KbRepository.instance.byId(kbRef),
      builder: (context, snap) {
        final entry = snap.data;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.menu_book),
          title: Text(entry?.displayTitle ?? kbRef),
          subtitle: const Text('مورد بانک فنی'),
          onTap: entry == null
              ? null
              : () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => KbEntryPage(entry: entry),
          )),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'برداشتن',
            onPressed: onClear,
          ),
        );
      },
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.photo, required this.onDelete});
  final CasePhoto photo;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PhotoViewPage(path: photo.path, title: photo.kind.label),
      )),
      onLongPress: onDelete,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            child: storedImage(
              photo.path,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 96,
                height: 96,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(photo.kind.label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// خانه‌ی یک امضا: تصویر امضا یا دکمه‌ی گرفتن امضا
class _SignatureSlot extends StatelessWidget {
  const _SignatureSlot({
    required this.label,
    required this.photo,
    required this.onSign,
  });

  final String label;
  final CasePhoto? photo;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onSign,
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          // زمینه‌ی سفید تا جوهر تیره‌ی امضا در تم تیره هم دیده شود
          color: photo == null ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Expanded(
              child: photo == null
                  ? Icon(Icons.gesture, color: scheme.primary)
                  : storedImage(photo!.path, fit: BoxFit.contain),
            ),
            const SizedBox(height: 4),
            Text(
              photo == null ? 'گرفتن $label' : label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: photo == null ? scheme.primary : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

CasePhoto? _lastOfKind(List<CasePhoto> photos, PhotoKind kind) {
  CasePhoto? found;
  for (final p in photos) {
    if (p.kind == kind) found = p;
  }
  return found;
}