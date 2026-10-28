import 'package:flutter/material.dart';

/// هویت بصری «کهربا»: رنگ‌های صفحه‌ی آغاز و خطوط نور کهربایی گوشه‌ها.
/// صفحه‌ی آغاز، صفحه‌های معرفی و پس‌زمینه‌ی تم تیره همه از همین استفاده می‌کنند
/// تا برنامه از اولین لحظه یک‌دست دیده شود.
abstract final class Brand {
  /// پس‌زمینه‌ی صفحه‌ی آغاز (همان رنگ صفحه‌ی آغاز اندروید)
  static const night = Color(0xFF070A12);
  static const nightTop = Color(0xFF0E1320);
  static const amber = Color(0xFFFFB020);
  static const orange = Color(0xFFFF8A1F);
  static const gold = Color(0xFFFFE08A);
  static const textMuted = Color(0xFF9AA6B8);

  static const amberGradient = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: [Color(0xFFFFC23D), Color(0xFFFF8A1F)],
  );
}

/// خطوط نور کهربایی در گوشه‌ی بالا-چپ و پایین-راست (مثل صفحه‌ی آغاز).
/// [progress] مقدار کشیده‌شدن خط (۰ تا ۱) و [intensity] شدت نور است.
class BrandStreaksPainter extends CustomPainter {
  const BrandStreaksPainter({this.progress = 1, this.intensity = 1});

  final double progress;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || intensity <= 0) return;
    final w = size.width, h = size.height;

    // بالا-چپ: از لبه‌ی چپ به لبه‌ی بالا
    final top = Path()
      ..moveTo(-4, h * 0.155)
      ..cubicTo(w * 0.15, h * 0.135, w * 0.20, h * 0.06, w * 0.33, -4);
    // پایین-راست: قرینه
    final bottom = Path()
      ..moveTo(w + 4, h * 0.82)
      ..cubicTo(w * 0.84, h * 0.85, w * 0.78, h * 0.94, w * 0.64, h + 4);

    _stroke(canvas, top, Rect.fromLTWH(0, 0, w * 0.33, h * 0.16), true);
    _stroke(canvas, bottom, Rect.fromLTWH(w * 0.64, h * 0.82, w * 0.36, h * 0.18),
        false);
  }

  void _stroke(Canvas canvas, Path full, Rect bounds, bool fromStart) {
    // فقط بخشی از خط که تا الان کشیده شده
    final path = Path();
    for (final m in full.computeMetrics()) {
      path.addPath(m.extractPath(0, m.length * progress), Offset.zero);
    }
    final shader = LinearGradient(
      begin: fromStart ? Alignment.bottomLeft : Alignment.topRight,
      end: fromStart ? Alignment.topRight : Alignment.bottomLeft,
      colors: const [Color(0x00FFB020), Brand.amber, Brand.gold],
      stops: const [0, 0.55, 1],
    ).createShader(bounds.inflate(4));

    final a = intensity.clamp(0.0, 1.0);
    // هاله‌ی پهن
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = Brand.amber.withValues(alpha: 0.28 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    // خط اصلی
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..shader = shader
        ..colorFilter = ColorFilter.mode(
            Colors.white.withValues(alpha: a), BlendMode.modulate),
    );
    // مغز روشن
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0xFFFFF4D6).withValues(alpha: 0.8 * a),
    );
  }

  @override
  bool shouldRepaint(BrandStreaksPainter old) =>
      old.progress != progress || old.intensity != intensity;
}

/// پس‌زمینه‌ی تیره‌ی «کهربا» برای صفحه‌ی آغاز و معرفی:
/// شب سرمه‌ای، هاله‌ی کهربایی مورب از بالا و خطوط نور گوشه‌ها.
/// [glow] شدت هاله (برای تپش آرام) و [streaks] مقدار کشیده‌شدن خطوط است.
class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({
    super.key,
    this.glow = 1,
    this.streaks = 1,
    this.child,
  });

  final double glow;
  final double streaks;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Brand.nightTop, Brand.night],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // هاله‌ی مورب کهربایی بالا-راست
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: glow.clamp(0.0, 1.0),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.55, -0.55),
                      radius: 0.95,
                      colors: [Color(0x55FF9A1F), Color(0x14FF8A1F), Color(0x00FF8A1F)],
                      stops: [0, 0.45, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: BrandStreaksPainter(progress: streaks),
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

/// درخشش نرم پشت لوگو.
class LogoGlow extends StatelessWidget {
  const LogoGlow({super.key, required this.size, this.strength = 1});
  final double size;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Brand.amber.withValues(alpha: 0.38 * strength.clamp(0.0, 1.0)),
              const Color(0xFF3B82F6).withValues(alpha: 0.10 * strength.clamp(0.0, 1.0)),
              Colors.transparent,
            ],
            stops: const [0, 0.5, 1],
          ),
        ),
      ),
    );
  }
}
