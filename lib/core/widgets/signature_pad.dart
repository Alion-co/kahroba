import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';

/// صفحه‌ی گرفتن امضای مشتری. گوشی را به مشتری بدهید تا با انگشت امضا کند.
/// خروجی: تصویر PNG با زمینه‌ی شفاف و جوهر تیره (روی رسید سفید خوانا).
class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  /// باز می‌کند و بایت‌های PNG امضا را برمی‌گرداند (یا null اگر منصرف شد).
  static Future<Uint8List?> open(
    BuildContext context, {
    required String title,
    String? subtitle,
  }) =>
      Navigator.of(context).push<Uint8List>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SignaturePage(title: title, subtitle: subtitle),
      ));

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final _strokes = <List<Offset>>[];
  Size _size = Size.zero;
  bool _saving = false;

  bool get _empty => _strokes.every((s) => s.length < 2);

  void _start(Offset p) => setState(() => _strokes.add([p]));
  void _move(Offset p) => setState(() => _strokes.last.add(p));

  Future<void> _save() async {
    if (_empty || _saving) return;
    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    final bytes = await _render();
    if (mounted) Navigator.of(context).pop(bytes);
  }

  /// فقط محدوده‌ی امضا (با کمی حاشیه) به تصویر تبدیل می‌شود
  Future<Uint8List> _render() async {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final s in _strokes) {
      for (final p in s) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    }
    const pad = 12.0, scale = 2.0;
    final rect = Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.scale(scale);
    canvas.translate(-rect.left, -rect.top);
    _SignaturePainter(_strokes, const Color(0xFF111111)).paint(canvas, _size);
    final img = await rec.endRecording().toImage(
          (rect.width * scale).ceil(),
          (rect.height * scale).ceil(),
        );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _empty ? null : () => setState(_strokes.clear),
            child: const Text('پاک کردن'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              if (widget.subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    // زمینه‌ی سفید مثل کاغذ تا امضا همان‌طور که روی رسید
                    // دیده می‌شود دیده شود
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: LayoutBuilder(
                      builder: (context, box) {
                        _size = box.biggest;
                        return Stack(
                          children: [
                            // خط راهنمای امضا
                            Positioned(
                              left: 32,
                              right: 32,
                              bottom: box.maxHeight * 0.28,
                              child: Container(
                                height: 1,
                                color: const Color(0x33000000),
                              ),
                            ),
                            if (_strokes.isEmpty)
                              const Center(
                                child: Text(
                                  'اینجا امضا کنید',
                                  style: TextStyle(
                                    color: Color(0x55000000),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onPanStart: (d) => _start(d.localPosition),
                                onPanUpdate: (d) => _move(d.localPosition),
                                child: CustomPaint(
                                  painter: _SignaturePainter(
                                    _strokes,
                                    const Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _empty || _saving ? null : _save,
                icon: const Icon(Icons.check),
                label: const Text('ثبت امضا'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes, this.color);
  final List<List<Offset>> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      // خط نرم با نقطه‌ی وسط هر دو نقطه (منحنی درجه‌ی دو)
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (var i = 1; i < s.length - 1; i++) {
        final mid = (s[i] + s[i + 1]) / 2;
        path.quadraticBezierTo(s[i].dx, s[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(s.last.dx, s.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  // فهرست خطوط درجا تغییر می‌کند، پس همیشه دوباره کشیده می‌شود
  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
