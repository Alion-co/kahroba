import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import 'brand.dart';

/// رنگ‌ها و تنظیمات طراحی شیشه‌ای.
///
/// برای سبک ماندن برنامه:
/// - هاله‌های نور پس‌زمینه ثابت‌اند و فقط یک بار کشیده می‌شوند.
/// - کارت‌های فهرست فقط رنگ نیمه‌شفاف و لبه‌ی روشن دارند (بدون محوسازی).
/// - محوسازی واقعی فقط روی چند جزء ثابت (مثل نوار پایین) است و
///   در «حالت سبک» کاملاً خاموش می‌شود.
@immutable
class GlassPalette extends ThemeExtension<GlassPalette> {
  const GlassPalette({
    required this.base,
    required this.glow1,
    required this.glow2,
    required this.glow3,
    required this.fill,
    required this.fillStrong,
    required this.border,
    required this.blur,
    this.accent = const Color(0xFFFFB020),
    this.onAccent = const Color(0xFF1A1000),
    this.accentGradient = const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFFFFC23D), Color(0xFFFF8A1F)],
    ),
    this.champagne = false,
  });

  /// رنگ پایه‌ی پس‌زمینه
  final Color base;

  /// سه هاله‌ی نور پشت صفحه
  final Color glow1;
  final Color glow2;
  final Color glow3;

  /// رنگ شیشه‌ی کارت‌ها
  final Color fill;

  /// شیشه‌ی پررنگ‌تر برای نوار پایین و پنل‌ها
  final Color fillStrong;

  /// لبه‌ی روشن شیشه
  final Color border;

  /// محوسازی واقعی روشن است یا نه (در حالت سبک خاموش)
  final bool blur;

  /// رنگ تأکید (دکمه‌ها، انتخاب‌ها): کهربایی در تیره، طلایی شامپاینی در روشن
  final Color accent;

  /// رنگ متن و آیکن روی [accent]
  final Color onAccent;

  /// گرادیان دکمه‌های اصلی
  final Gradient accentGradient;

  /// پس‌زمینه‌ی عاجی با کمان‌های باریک طلایی (تم روشن)
  final bool champagne;

  static GlassPalette of(BuildContext context) =>
      Theme.of(context).extension<GlassPalette>()!;

  /// تم مشکی کامل (OLED) فعال است
  bool get isBlack => base == const Color(0xFF000000);

  static GlassPalette dark({required bool blur}) => GlassPalette(
        // سرمه‌ای عمیق با هاله‌های ملایم (مطابق طرح «شب کارگاه»).
        // در حالت سبک هاله‌ها و خطوط نور حذف می‌شوند (پس‌زمینه‌ی یکدست،
        // بدون نقاشی اضافه برای هر صفحه)
        base: const Color(0xFF0B1120),
        glow1: blur ? const Color(0x40FFB020) : const Color(0x00000000),
        glow2: blur ? const Color(0x2922D3EE) : const Color(0x00000000),
        glow3: blur ? const Color(0x268B5CF6) : const Color(0x00000000),
        fill: const Color(0xE6151D2F),
        fillStrong: const Color(0xF0111827),
        border: const Color(0x1AFFFFFF),
        blur: blur,
      );

  /// تم مشکی کامل برای صفحه‌های OLED: پیکسل‌های سیاه خاموش‌اند، پس
  /// باتری کمتری مصرف می‌شود. بدون هاله و بدون محوسازی.
  static GlassPalette black({required bool blur}) => GlassPalette(
        base: const Color(0xFF000000),
        glow1: const Color(0x00000000),
        glow2: const Color(0x00000000),
        glow3: const Color(0x00000000),
        fill: const Color(0xFF0E0E10),
        fillStrong: const Color(0xF7060607),
        border: const Color(0x1FFFFFFF),
        blur: false,
      );

  /// تم روشن «شامپاینی»: زمینه‌ی عاجی، کارت‌های کرم، تأکید طلایی
  /// (هماهنگ با صفحه‌های معرفی).
  static GlassPalette light({required bool blur}) => GlassPalette(
        base: const Color(0xFFF4ECDF),
        glow1: const Color(0x00000000),
        glow2: const Color(0x00000000),
        glow3: const Color(0x00000000),
        fill: const Color(0xFFFCF8F2),
        fillStrong: const Color(0xF5FCF8F2),
        border: const Color(0x1F9C7140),
        blur: blur,
        accent: const Color(0xFFB08550),
        onAccent: Colors.white,
        accentGradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFFCDA770), Color(0xFFA5764A)],
        ),
        champagne: true,
      );

  @override
  GlassPalette copyWith({
    Color? base,
    Color? glow1,
    Color? glow2,
    Color? glow3,
    Color? fill,
    Color? fillStrong,
    Color? border,
    bool? blur,
    Color? accent,
    Color? onAccent,
    Gradient? accentGradient,
    bool? champagne,
  }) =>
      GlassPalette(
        base: base ?? this.base,
        glow1: glow1 ?? this.glow1,
        glow2: glow2 ?? this.glow2,
        glow3: glow3 ?? this.glow3,
        fill: fill ?? this.fill,
        fillStrong: fillStrong ?? this.fillStrong,
        border: border ?? this.border,
        blur: blur ?? this.blur,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        accentGradient: accentGradient ?? this.accentGradient,
        champagne: champagne ?? this.champagne,
      );

  @override
  GlassPalette lerp(ThemeExtension<GlassPalette>? other, double t) =>
      other is GlassPalette ? (t < 0.5 ? this : other) : this;
}

/// پس‌زمینه‌ی نورانی پشت هر صفحه.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final g = GlassPalette.of(context);
    if (g.champagne) {
      // عاجی با گرادیان ملایم و دو کمان طلایی (یک بار کشیده می‌شود)
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F2E8), Color(0xFFF0E6D6)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: ChampagneLinesPainter()),
              ),
            ),
            child,
          ],
        ),
      );
    }
    final hasGlow = g.glow1.a > 0 || g.glow2.a > 0 || g.glow3.a > 0;
    if (!hasGlow) return ColoredBox(color: g.base, child: child);
    return ColoredBox(
      color: g.base,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Stack(
              children: [
                _glow(top: -150, right: -120, size: 400, color: g.glow1),
                _glow(bottom: 140, left: -180, size: 440, color: g.glow2),
                _glow(bottom: -160, right: -70, size: 340, color: g.glow3),
                // خطوط نور کهربایی گوشه‌ها، هماهنگ با صفحه‌ی آغاز
                const Positioned.fill(
                  child: CustomPaint(
                    painter: BrandStreaksPainter(intensity: 0.45),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  static Widget _glow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// پنل شیشه‌ای با محوسازی واقعی. فقط برای اجزای ثابت و کم‌تعداد استفاده شود.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 24,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;

  /// اگر داده شود به‌جای [radius] استفاده می‌شود (مثلاً فقط گوشه‌های بالا)
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final g = GlassPalette.of(context);
    final shape = borderRadius ?? BorderRadius.circular(radius);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: g.blur ? g.fillStrong : g.fillStrong.withValues(alpha: 0.9),
        borderRadius: shape,
        border: Border.all(color: g.border),
      ),
      child: child,
    );
    return Padding(
      padding: margin,
      child: g.blur
          ? ClipRRect(
              borderRadius: shape,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: box,
              ),
            )
          : box,
    );
  }
}

/// انتقال بین صفحه‌ها که به هر صفحه پس‌زمینه‌ی نورانی خودش را می‌دهد.
/// به این ترتیب Scaffoldها شفاف‌اند ولی صفحه‌ها روی هم دیده نمی‌شوند.
/// نام مسیرهایی که نباید عرضشان محدود شود
const fullBleedRoute = 'full-bleed';
const _fullBleed = {'/', fullBleedRoute};

class GlassPageTransitionsBuilder extends FadeForwardsPageTransitionsBuilder {
  const GlassPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return super.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      GlassBackground(
        // صفحه‌ی آغاز ('/') و معرفی تمام‌عرض‌اند؛ بقیه روی تبلت محدود می‌شوند
        child: _fullBleed.contains(route?.settings.name)
            ? child
            : ResponsiveWidth(child: child),
      ),
    );
  }
}


/// دکمه‌ی اصلی «جرقه»: گرادیان کهربایی به نارنجی.
class SparkButton extends StatelessWidget {
  const SparkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  static const sparkGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFFFC23D), Color(0xFFFF8A1F)],
  );
  static const onSpark = Color(0xFF1A1000);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final g = GlassPalette.of(context);
    final onSpark = g.onAccent;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: g.accentGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: g.accent.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: onSpark, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: onSpark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// دو کمان باریک طلایی در گوشه‌های بالا-چپ و پایین-راست (تم روشن و معرفی)
class ChampagneLinesPainter extends CustomPainter {
  const ChampagneLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0x55C9A46A)
      ..isAntiAlias = true;
    final w = size.width, h = size.height;
    final r1 = math.min(w * 0.62, 360.0);
    final r2 = math.min(w * 0.55, 320.0);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(-r1 * 0.24, -h * 0.05), radius: r1),
      0, math.pi / 2, false, p,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w + r2 * 0.2, h * 1.02), radius: r2),
      math.pi, math.pi / 2, false, p,
    );
  }

  @override
  bool shouldRepaint(ChampagneLinesPainter old) => false;
}
