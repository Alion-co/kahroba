import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/theme/glass.dart';
import '../../data/database.dart';
import '../home/home_shell.dart';
import 'onboarding_page.dart';

/// برچسب Hero لوگو؛ لوگو از صفحه‌ی آغاز به نوار بالای خانه پرواز می‌کند.
const brandLogoHeroTag = 'brand-logo';

/// صفحه‌ی آغاز مینیمال: آیکن کهربا با هاله‌ی کهربایی کم‌رنگ، نام، و یک
/// خط بارگذاری باریک.
/// هم‌زمان تنظیمات خوانده می‌شود و بعد به معرفی (بار اول) یا خانه می‌رود.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // خط زمانی اصلی (یک بار)
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  // تپش آرام هاله
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  bool? _onboardingDone;
  bool _left = false;

  Animation<double> _seg(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: curve));

  late final _logoIn = _seg(0.0, 0.45);
  late final _title = _seg(0.25, 0.6);
  late final _subtitle = _seg(0.35, 0.7);
  late final _bar = _seg(0.3, 1.0, Curves.easeInOutCubic);

  @override
  void initState() {
    super.initState();
    _intro.addStatusListener((s) {
      if (s == AnimationStatus.completed) _maybeLeave();
    });
    appDb.getSettings().then((s) {
      _onboardingDone = s.onboardingDone;
      _maybeLeave();
    }).catchError((_) {
      _onboardingDone = true;
      _maybeLeave();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // اگر انیمیشن‌ها در گوشی خاموش است، معطل نکن
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _intro.value = 1;
      _pulse.stop();
      _maybeLeave();
    } else if (!_intro.isAnimating && _intro.value == 0) {
      _intro.forward();
    }
  }

  void _maybeLeave() {
    if (_left || !mounted) return;
    if (_onboardingDone == null || !_intro.isCompleted) return;
    _left = true;
    // ناوبری بعد از فریم فعلی، تا وسط ساخت صفحه انجام نشود
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _go())
      ..scheduleFrame();
  }

  void _go() {
    if (!mounted) return;
    final Widget next =
        _onboardingDone! ? const HomeShell() : const OnboardingPage();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) =>
            _onboardingDone!
                ? GlassBackground(child: ResponsiveWidth(child: next))
                : next,
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// زمینه‌ی صفحه‌ی آغاز (همان رنگ صفحه‌ی آغاز سیستمی اندروید):
  /// تیره در تم تیره، عاجی در تم روشن
  static const _bgDark = Color(0xFF0A0A0C);
  static const _bgLight = Color(0xFFF6EFE4);

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    // اندازه‌ی آیکن از ضلع کوچک‌تر صفحه (گوشی، افقی، تبلت)
    final logoSize = math.min(rs.shortestSide * 0.30, 132.0);
    final light = Theme.of(context).brightness == Brightness.light;
    final glow = light ? const Color(0x33D9B57C) : const Color(0x26FFB020);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: light ? Brightness.dark : Brightness.light,
        statusBarBrightness: light ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            light ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: light ? _bgLight : _bgDark,
        body: AnimatedBuilder(
          animation: Listenable.merge([_intro, _pulse]),
          builder: (context, _) {
            final pulse = Curves.easeInOut.transform(_pulse.value);
            final logoT = _logoIn.value;
            // StackFit.expand: محتوا کل صفحه را می‌گیرد و وسط‌چین می‌ماند
            return Stack(
              fit: StackFit.expand,
              children: [
                // هاله‌ی کهربایی کم‌رنگ پشت آیکن، با تپش خیلی آرام
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: logoT * (0.75 + 0.25 * pulse),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.12),
                            radius: 0.65,
                            colors: [glow, glow.withValues(alpha: 0)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 5),
                      // ───── آیکن
                      Opacity(
                        opacity: logoT,
                        child: Transform.scale(
                          scale: 0.92 + 0.08 * logoT,
                          child: Hero(
                            tag: brandLogoHeroTag,
                            child: Image.asset(
                              'assets/brand/logo_dark.png',
                              width: logoSize,
                              height: logoSize,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // ───── نام و شعار
                      _Rise(
                        t: _title.value,
                        child: Text(
                          'کهربا',
                          style: TextStyle(
                            fontSize: 30,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: light
                                ? const Color(0xFF3A2A1C)
                                : const Color(0xFFF5F2EC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _Rise(
                        t: _subtitle.value,
                        child: Text(
                          'دفتر دیجیتال تعمیرکاران',
                          style: TextStyle(
                            fontSize: 14,
                            color: light
                                ? const Color(0xFF8B7D70)
                                : const Color(0xFF8A8F98),
                          ),
                        ),
                      ),
                      const Spacer(flex: 6),
                      // ───── بارگذاری: یک خط باریک
                      Opacity(
                        opacity: _subtitle.value,
                        child: _LoadingLine(value: _bar.value),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// بالا آمدن و ظاهر شدن متن
class _Rise extends StatelessWidget {
  const _Rise({required this.t, required this.child});
  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
      );
}

/// خط بارگذاری مینیمال: ۵۶ پیکسل، ۲ پیکسل ضخامت
class _LoadingLine extends StatelessWidget {
  const _LoadingLine({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    const width = 56.0;
    final light = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        color: light ? const Color(0x22826040) : const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: width * value.clamp(0.0, 1.0),
        decoration: BoxDecoration(
          color: light ? const Color(0xFFB08550) : Brand.amber,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
