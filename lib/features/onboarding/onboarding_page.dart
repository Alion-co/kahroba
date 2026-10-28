import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/glass.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';
import '../home/home_shell.dart';

/// سه صفحه‌ی معرفی که بار اول نشان داده می‌شود.
/// طراحی: زمینه‌ی عاجی و شامپاینی، خطوط باریک طلایی، نشان K طلایی.
/// [replay] برای نمایش دوباره (فعلاً دکمه‌ای در برنامه ندارد).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.replay = false});

  /// اگر true باشد در پایان فقط برمی‌گردد (به‌جای رفتن به خانه)
  final bool replay;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

// ───────── رنگ‌های این صفحه‌ها (هماهنگ با بسته‌ی برند کهربا)
abstract final class _C {
  static const bgTop = Color(0xFFF8F2E8);
  static const bgBottom = Color(0xFFEFE4D3);
  static const gold = Color(0xFFB98D52);
  static const goldLight = Color(0xFFD9B57C);
  static const goldDark = Color(0xFF9C7140);
  static const ink = Color(0xFF3A2A1C);
  static const muted = Color(0xFF8B7D70);
  static const line = Color(0x66C9A46A);
  static const card = Color(0xFFFBF7F0);
  static const goldGradient = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: [Color(0xFFC9A26A), Color(0xFFA9784A)],
  );
}

class _Slide {
  const _Slide(this.title, this.body, this.art, {this.brand = false});
  final String title;
  final String body;
  final Widget Function(double active, double float) art;

  /// صفحه‌ی اول: نام برند طلایی به‌جای عنوان معمولی
  final bool brand;
}

final _slides = <_Slide>[
  _Slide(
    'کهربا',
    'دفتر دیجیتال تعمیرکاران؛\nهمیشه در دسترس، برای کارهای شما',
    (a, f) => _BrandArt(active: a, float: f),
    brand: true,
  ),
  _Slide(
    'ثبت سریع پرونده',
    'با چند لمس پرونده‌ی جدید بسازید،\nعکس بگیرید و رسید بفرستید.',
    (a, f) => _QuickCaseArt(active: a, float: f),
  ),
  _Slide(
    'کنترل کامل و مدیریت حرفه‌ای',
    'از وضعیت تعمیر تا هزینه‌ها و طلب‌ها،\nهمه در دسترس شماست.',
    (a, f) => _ControlArt(active: a, float: f),
  ),
];

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _pages = PageController();
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  Future<void> _finish() async {
    await appDb.setSetting(SettingKeys.onboardingDone, '1');
    if (!mounted) return;
    if (widget.replay) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const GlassBackground(
          child: ResponsiveWidth(child: HomeShell()),
        ),
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_isLast) {
      _finish();
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _C.bgBottom,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_C.bgTop, _C.bgBottom],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // خطوط باریک طلایی گوشه‌ها (ثابت؛ یک بار کشیده می‌شوند)
              const IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _GoldLinesPainter()),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // رد شدن
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AnimatedOpacity(
                        opacity: _isLast ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: TextButton(
                          onPressed: _isLast ? null : _finish,
                          style: TextButton.styleFrom(
                            foregroundColor: _C.muted,
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                          child: const Text('رد شدن'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_pages, _float]),
                        builder: (context, _) {
                          final page = _pages.hasClients &&
                                  _pages.position.haveDimensions
                              ? _pages.page ?? 0
                              : _index.toDouble();
                          return PageView.builder(
                            controller: _pages,
                            itemCount: _slides.length,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemBuilder: (context, i) => _SlideView(
                              slide: _slides[i],
                              delta: page - i,
                              float: _float.value,
                            ),
                          );
                        },
                      ),
                    ),
                    // نقطه‌ها
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _slides.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _index ? 8 : 6,
                            height: i == _index ? 8 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _index
                                  ? _C.gold
                                  : const Color(0xFFD9CCB9),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: rs.isShort ? 12 : 22),
                    _CtaButton(
                      label: _isLast ? 'شروع' : 'بعدی',
                      onTap: _next,
                    ),
                    SizedBox(height: rs.isShort ? 12 : 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// یک صفحه‌ی معرفی با جابه‌جایی عمقی (parallax) هنگام ورق زدن.
class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.delta,
    required this.float,
  });

  final _Slide slide;

  /// فاصله‌ی این صفحه از صفحه‌ی فعلی (۰ یعنی همین صفحه)
  final double delta;
  final double float;

  @override
  Widget build(BuildContext context) {
    final d = delta.clamp(-1.0, 1.0);
    final active = 1 - d.abs();
    // در راست‌به‌چپ صفحه‌ی بعدی سمت چپ است، پس جهت جابه‌جایی برعکس می‌شود
    final w = context.rs.width *
        (Directionality.of(context) == TextDirection.rtl ? -1 : 1);
    final rs = context.rs;
    final art = Transform.translate(
      offset: Offset(d * w * 0.35, 0),
      child: Opacity(
        opacity: (0.2 + 0.8 * active).clamp(0.0, 1.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: rs.sized(330),
              maxHeight: rs.sized(400),
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: slide.art(active, float),
              ),
            ),
          ),
        ),
      ),
    );

    final text = Transform.translate(
      offset: Offset(d * w * 0.15, 0),
      child: Opacity(
        opacity: active.clamp(0.0, 1.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: rs.readableWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rs.gutter + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (slide.brand) ...[
                  Container(width: 26, height: 1.5, color: _C.gold),
                  const SizedBox(height: 14),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_C.goldLight, _C.goldDark],
                    ).createShader(r),
                    child: Text(
                      slide.title,
                      style: TextStyle(
                        fontSize: rs.sized(36),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ] else
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rs.sized(22),
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                      color: _C.ink,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  slide.body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: rs.sized(14),
                    height: 1.9,
                    color: _C.muted,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        // افقی یا تبلت پهن: تصویر و متن کنار هم
        if (Responsive.fromConstraints(c).isLandscape &&
            c.maxWidth > c.maxHeight * 1.15) {
          return Row(
            children: [
              Expanded(child: art),
              Expanded(
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: text),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            Expanded(child: art),
            text,
          ],
        );
      },
    );
  }
}

/// دکمه‌ی قرصی طلایی شامپاینی با فلش
class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _C.goldGradient,
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33A9784A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            width: 172,
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// دو کمان باریک طلایی در گوشه‌های صفحه
class _GoldLinesPainter extends CustomPainter {
  const _GoldLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = _C.line
      ..isAntiAlias = true;
    final w = size.width, h = size.height;
    // بالا-چپ
    canvas.drawArc(
      Rect.fromCircle(center: Offset(-w * 0.15, -h * 0.05), radius: w * 0.62),
      0, math.pi / 2, false, p,
    );
    // پایین-راست
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 1.12, h * 1.02), radius: w * 0.55),
      math.pi, math.pi / 2, false, p,
    );
  }

  @override
  bool shouldRepaint(_GoldLinesPainter old) => false;
}

// ═══════════════════════ تصویرسازی‌ها ═══════════════════════
// همه با ویجت ساخته شده‌اند (بدون عکس) تا برنامه سبک بماند.

double _bob(double float, double phase, [double amp = 6]) =>
    math.sin((float + phase) * 2 * math.pi) * amp;

/// ورود پله‌ای اجزای تصویر وقتی صفحه فعال می‌شود
Widget _pop(double active, double at, Widget child) {
  final t = ((active - at) / (1 - at)).clamp(0.0, 1.0);
  final c = Curves.easeOutBack.transform(t);
  return Opacity(
    opacity: t,
    child: Transform.scale(scale: 0.7 + 0.3 * c, child: child),
  );
}

// ───────── ۱: نشان طلایی کهربا
class _BrandArt extends StatelessWidget {
  const _BrandArt({required this.active, required this.float});
  final double active;
  final double float;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // هاله‌ی گرم پشت نشان
          Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, _bob(float, 0, 4)),
            child: _pop(
              active,
              0.2,
              Image.asset(
                'assets/brand/logo_hd.png',
                width: 210,
                height: 210,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────── ۲: گوشی شیشه‌ای کج با کاشی‌های کار
class _QuickCaseArt extends StatelessWidget {
  const _QuickCaseArt({required this.active, required this.float});
  final double active;
  final double float;

  static const _tiles = [
    (Icons.add_box_outlined, 'پرونده جدید'),
    (Icons.photo_camera_outlined, 'عکس قبل و بعد'),
    (Icons.sms_outlined, 'پیامک رسید'),
    (Icons.people_outline, 'مشتری‌ها'),
    (Icons.menu_book_outlined, 'بانک فنی'),
  ];

  Widget _tile(IconData icon, String label) => Container(
        width: 74,
        height: 70,
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A9C7140)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: _C.gold),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 8.5, color: _C.ink)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final phone = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(-0.32)
        ..rotateZ(-0.06),
      child: Container(
        width: 190,
        height: 340,
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6EFE3),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _C.goldLight, width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33826040),
              blurRadius: 30,
              offset: Offset(12, 18),
            ),
          ],
        ),
        child: Column(
          children: [
            // جستجو
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 13, color: _C.muted),
                  SizedBox(width: 6),
                  Text('جستجوی پرونده…',
                      style: TextStyle(fontSize: 8.5, color: _C.muted)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _tiles.length; i++)
                  _pop(active, 0.3 + i * 0.08,
                      _tile(_tiles[i].$1, _tiles[i].$2)),
              ],
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: 320,
      height: 380,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, _bob(float, 0.1, 5)),
            child: phone,
          ),
          // حلقه‌ی طلایی دور گوشی
          IgnorePointer(
            child: Transform.rotate(
              angle: -0.35 + 0.04 * math.sin(float * 2 * math.pi),
              child: CustomPaint(
                size: const Size(300, 150),
                painter: _OrbitPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = const LinearGradient(
          colors: [Color(0x00D9B57C), Color(0xFFD9B57C), Color(0x33D9B57C)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => false;
}

// ───────── ۳: کارت تیره‌ی گزارش ماهانه
class _ControlArt extends StatelessWidget {
  const _ControlArt({required this.active, required this.float});
  final double active;
  final double float;

  static const _bars = [0.55, 0.9, 0.6, 0.75, 0.45, 0.68];

  @override
  Widget build(BuildContext context) {
    final grow = Curves.easeOutCubic
        .transform(((active - 0.25) / 0.75).clamp(0.0, 1.0));
    final card = Container(
      width: 240,
      height: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A241E), Color(0xFF14110E)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x55D9B57C)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('گزارش ماهانه',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.goldLight),
                ),
                child: const Icon(Icons.north_east,
                    size: 13, color: _C.goldLight),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('درآمد این ماه',
              style: TextStyle(color: Color(0x99FFFFFF), fontSize: 9)),
          const SizedBox(height: 2),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('۳۲٬۰۰۰٬۰۰۰',
                  style: TextStyle(
                      color: _C.goldLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              SizedBox(width: 4),
              Text('تومان',
                  style: TextStyle(color: Color(0x99FFFFFF), fontSize: 8.5)),
            ],
          ),
          const Spacer(),
          // ستون‌های طلایی
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final v in _bars)
                  Container(
                    width: 16,
                    height: 120 * v * (0.15 + 0.85 * grow),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF0D6A2), Color(0xFFA9784A)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    // کارت کوچک شیشه‌ای راهنما
    final legend = Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xE63A322A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x44D9B57C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (label, color) in const [
            ('اجرت تعمیر', Color(0xFFD9B57C)),
            ('قطعات', Color(0xFFB8B0A4)),
            ('طلب از مشتری', Color(0xFFE8C766)),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Color(0xDDFFFFFF), fontSize: 9)),
                ],
              ),
            ),
        ],
      ),
    );

    return SizedBox(
      width: 320,
      height: 370,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(0, _bob(float, 0.2, 4)),
            child: card,
          ),
          PositionedDirectional(
            bottom: 18 + _bob(float, 0.55, 5),
            start: 18,
            child: _pop(active, 0.55, legend),
          ),
          PositionedDirectional(
            top: 150 + _bob(float, 0.8, 6),
            end: 6,
            child: _pop(
              active,
              0.7,
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.card,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.trending_up, color: _C.gold, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
