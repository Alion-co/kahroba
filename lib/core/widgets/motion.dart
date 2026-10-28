import 'dart:async';

import 'package:flutter/material.dart';

/// ابزارهای حرکت و پویایی برنامه.
///
/// همه‌چیز کوتاه و سبک است و اگر کاربر در تنظیمات گوشی «حذف انیمیشن»
/// را روشن کرده باشد، انیمیشن‌ها اجرا نمی‌شوند.

/// ورود نرم: محو شدن و کمی بالا آمدن، با تأخیر پله‌ای بر اساس [index].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.enabled = true,
    this.offset = 18,
    this.duration = const Duration(milliseconds: 420),
    this.step = const Duration(milliseconds: 55),
  });

  final Widget child;

  /// ترتیب در فهرست؛ هر چه بزرگ‌تر، دیرتر (حداکثر ۸ پله)
  final int index;

  /// اگر false باشد بدون انیمیشن نمایش داده می‌شود
  final bool enabled;
  final double offset;
  final Duration duration;
  final Duration step;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.enabled || reduce) {
      _c.value = 1;
      return;
    }
    final i = widget.index.clamp(0, 8);
    if (i == 0) {
      _c.forward();
    } else {
      _timer = Timer(widget.step * i, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _t.value)),
          child: child,
        ),
      ),
    );
  }
}

/// کمی کوچک شدن هنگام لمس؛ حس «دکمه‌ی واقعی» به کارت‌ها می‌دهد.
/// لمس را نمی‌گیرد، پس InkWell و onTap داخلش مثل قبل کار می‌کنند.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.scale = 0.97});
  final Widget child;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// عدد شمارنده که از مقدار قبلی به مقدار جدید می‌شمارد.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  final int value;
  final String Function(int) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(format(v.round()), style: style),
    );
  }
}
