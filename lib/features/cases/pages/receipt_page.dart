import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/services/share_image.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/stored_image.dart';
import '../../../data/database.dart';
import '../../../data/defaults.dart';

/// متن QR رسید؛ اسکنر برنامه (بسته‌ی بعدی) پرونده را با آن پیدا می‌کند.
String caseQrData(String code) => 'KAHROBA-CASE:$code';

/// رسید تصویری پرونده برای واتس‌اپ، ایتا یا چاپگر حرارتی.
/// چاپ: تصویر را با برنامه‌ی چاپگر بلوتوثی (مثل RawBT یا برنامه‌ی خود چاپگر)
/// به اشتراک بگذارید.
class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key, required this.caseId});
  final int caseId;

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _key = GlobalKey();
  bool _thermal = false;
  late final Future<_ReceiptData?> _data = _load();

  Future<_ReceiptData?> _load() async {
    final row = await appDb.watchCase(widget.caseId).first;
    if (row == null) return null;
    final settings = await appDb.getSettings();
    final parts = await appDb.watchParts(widget.caseId).first;
    final payments = await appDb.watchPayments(widget.caseId).first;
    final total =
        row.repairCase.labor + parts.fold<int>(0, (s, p) => s + p.qty * p.unitPrice);
    final paid = payments.fold<int>(0, (s, p) => s + p.amount);
    final photos = await appDb.watchPhotos(widget.caseId).first;
    String? sig(PhotoKind k) {
      String? path;
      for (final p in photos) {
        if (p.kind == k) path = p.path;
      }
      return path;
    }

    return _ReceiptData(row, settings, total, paid,
        signIn: sig(PhotoKind.signatureIn),
        signOut: sig(PhotoKind.signatureOut));
  }

  Future<void> _share() async {
    try {
      final d = await _data;
      await shareWidgetAsImage(
        _key,
        fileName: 'kahroba-${d?.row.repairCase.code ?? 'receipt'}',
        pixelRatio: _thermal ? 2 : 3,
      );
    } catch (e) {
      if (mounted) showSnack(context, 'ساخت تصویر نشد: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رسید تصویری')),
      body: FutureBuilder<_ReceiptData?>(
        future: _data,
        builder: (context, snap) {
          final d = snap.data;
          if (d == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ResponsiveListView(
            readable: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('برای پیام‌رسان')),
                  ButtonSegment(value: true, label: Text('چاپگر ۵۸ میلی‌متری')),
                ],
                selected: {_thermal},
                onSelectionChanged: (v) => setState(() => _thermal = v.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: RepaintBoundary(
                  key: _key,
                  child: _Receipt(data: d, thermal: _thermal),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share),
                label: Text(_thermal ? 'ارسال به برنامه‌ی چاپگر' : 'ارسال رسید'),
              ),
              if (_thermal)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'تصویر را با برنامه‌ی چاپگر بلوتوثی خود (مثلاً RawBT) به اشتراک بگذارید تا چاپ شود.',
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

class _ReceiptData {
  _ReceiptData(this.row, this.settings, this.total, this.paid,
      {this.signIn, this.signOut});
  final CaseRow row;
  final ShopSettings settings;
  final int total;
  final int paid;

  /// مسیر تصویر امضای مشتری هنگام پذیرش و تحویل (اگر گرفته شده)
  final String? signIn;
  final String? signOut;
}

class _Receipt extends StatelessWidget {
  const _Receipt({required this.data, required this.thermal});
  final _ReceiptData data;
  final bool thermal;

  @override
  Widget build(BuildContext context) {
    final c = data.row.repairCase;
    final s = data.settings;
    const ink = Color(0xFF111111);
    final accent = thermal ? ink : const Color(0xFFB86E00);
    final due = data.total - data.paid;

    Widget line(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 13,
                    color: ink,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );

    final divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 1,
        color: thermal ? ink : const Color(0xFFE0E0E0),
      ),
    );

    return Container(
      width: thermal ? 288 : 330,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(thermal ? 0 : 18),
        border: thermal ? null : Border.all(color: const Color(0xFFFFB020), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.shopName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink)),
          if (s.shopPhone.isNotEmpty)
            Text(toFaDigits(s.shopPhone),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 13, color: ink)),
          if (s.shopAddress.isNotEmpty)
            Text(s.shopAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF555555))),
          divider,
          const Text('رسید پذیرش دستگاه',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
          Text(
            toFaDigits(c.code),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.w700, color: accent, letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          Center(
            child: QrImageView(
              data: caseQrData(c.code),
              size: thermal ? 110 : 120,
              backgroundColor: Colors.white,
            ),
          ),
          divider,
          line('مشتری', data.row.customer.name),
          line('دستگاه', '${data.row.deviceTitle} (${data.row.device.code})'),
          if (c.reportedProblem.isNotEmpty) line('ایراد', c.reportedProblem),
          line('تاریخ پذیرش', formatDate(c.receivedAt)),
          if (c.deliveredAt != null) line('تاریخ تحویل', formatDate(c.deliveredAt!)),
          if (data.total > 0 || data.paid > 0) ...[
            divider,
            if (data.total > 0) line('هزینه', formatToman(data.total)),
            if (data.paid > 0) line('پرداخت‌شده', formatToman(data.paid)),
            if (data.total > 0)
              line(due > 0 ? 'مانده' : 'وضعیت', due > 0 ? formatToman(due) : 'تسویه',
                  bold: true),
          ],
          if (c.warrantyDays > 0) ...[
            divider,
            line(
              'گارانتی تعمیر',
              c.deliveredAt == null
                  ? '${toFaDigits(c.warrantyDays)} روز از تاریخ تحویل'
                  : '${toFaDigits(c.warrantyDays)} روز — تا ${formatDate(c.deliveredAt!.add(Duration(days: c.warrantyDays)))}',
            ),
          ],
          if (data.signIn != null || data.signOut != null) ...[
            divider,
            Row(
              children: [
                for (final (label, path) in [
                  ('امضای پذیرش', data.signIn),
                  ('امضای تحویل', data.signOut),
                ])
                  if (path != null)
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 54,
                            child: storedImage(path, fit: BoxFit.contain),
                          ),
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF555555))),
                        ],
                      ),
                    ),
              ],
            ),
          ],
          divider,
          const Text('لطفاً این رسید را تا زمان تحویل نگه دارید.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF555555))),
          const SizedBox(height: 4),
          const Text('ساخته‌شده با کهربا',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Color(0xFF999999))),
        ],
      ),
    );
  }
}
