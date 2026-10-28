import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/text_utils.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';

/// طول رمز قفل
const pinLength = 4;

/// اثر رمز. خود رمز هیچ‌جا ذخیره نمی‌شود.
/// هش ۳۲بیتی FNV-1a با نمک و تکرار؛ ضرب طوری نوشته شده که روی وب هم
/// (اعداد ۵۳بیتی) همان نتیجه را بدهد.
String hashPin(String pin) {
  int round(int h, int byte) {
    h ^= byte;
    // h * 16777619 به پیمانه‌ی ۲^۳۲ (16777619 = 2^24 + 403)
    return (((h & 0xFF) << 24) + h * 403) & 0xFFFFFFFF;
  }

  String run(int seed) {
    var h = seed;
    final bytes = 'kahroba:$pin'.codeUnits;
    for (var i = 0; i < 2000; i++) {
      for (final b in bytes) {
        h = round(h, b & 0xFF);
      }
      h = round(h, i & 0xFF);
    }
    return h.toRadixString(16).padLeft(8, '0');
  }

  return run(0x811C9DC5) + run(0x01000193);
}

/// قفل برنامه: روی همه‌ی صفحه‌ها می‌نشیند. هنگام باز شدن برنامه و وقتی
/// برنامه بیش از [relockAfter] در پس‌زمینه بوده، رمز می‌خواهد.
class AppLockGate extends StatefulWidget {
  const AppLockGate({
    super.key,
    required this.pinHash,
    required this.ready,
    required this.child,
  });

  /// اثر رمز؛ خالی یعنی قفل خاموش
  final String pinHash;

  /// تنظیمات از پایگاه داده خوانده شده است
  final bool ready;
  final Widget child;

  static const relockAfter = Duration(seconds: 30);

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  late bool _locked = widget.ready && widget.pinHash.isNotEmpty;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(AppLockGate old) {
    super.didUpdateWidget(old);
    // بار اولی که تنظیمات خوانده می‌شود: اگر رمز دارد، قفل کن
    if (!old.ready && widget.ready) _locked = widget.pinHash.isNotEmpty;
    // قفل خاموش شد: باز کن. (روشن شدنش تازه، صفحه را قفل نمی‌کند)
    if (widget.pinHash.isEmpty && _locked) _locked = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.pinHash.isEmpty) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _pausedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final at = _pausedAt;
      _pausedAt = null;
      if (at != null &&
          DateTime.now().difference(at) > AppLockGate.relockAfter) {
        setState(() => _locked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // زیر قفل، صفحه‌ها نه دیده می‌شوند و نه لمس می‌گیرند
        ExcludeSemantics(
          excluding: _locked,
          child: IgnorePointer(ignoring: _locked, child: widget.child),
        ),
        if (_locked)
          Positioned.fill(
            child: PinPad(
              title: 'رمز کهربا را وارد کنید',
              showLogo: true,
              onComplete: (pin) async {
                if (hashPin(pin) == widget.pinHash) {
                  setState(() => _locked = false);
                  return true;
                }
                return false;
              },
            ),
          ),
      ],
    );
  }
}

/// صفحه‌ی ورود رمز با صفحه‌کلید عددی. [onComplete] اگر false برگرداند،
/// نقطه‌ها می‌لرزند و پاک می‌شوند.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.title,
    required this.onComplete,
    this.subtitle,
    this.showLogo = false,
  });

  final String title;
  final String? subtitle;
  final bool showLogo;
  final Future<bool> Function(String pin) onComplete;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _busy = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _tap(String d) async {
    if (_busy || _pin.length >= pinLength) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += d);
    if (_pin.length < pinLength) return;
    _busy = true;
    final ok = await widget.onComplete(_pin);
    if (!mounted) return;
    if (!ok) {
      HapticFeedback.heavyImpact();
      await _shake.forward(from: 0);
      if (!mounted) return;
      setState(() => _pin = '');
    }
    _busy = false;
  }

  void _back() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget key(String d) => _Key(
          label: toFaDigits(d),
          onTap: () => _tap(d),
        );

    return Material(
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF0A0E12)
          : const Color(0xFFF6EFE4),
      child: SafeArea(
        // همه‌چیز در یک قاب ثابت ۲۸۰ پیکسلی چیده می‌شود و اگر صفحه کوتاه یا
        // باریک بود (گوشی کوچک، افقی، فونت بزرگ) کل قاب کوچک می‌شود؛
        // پس هیچ‌وقت بیرون نمی‌زند.
        child: LayoutBuilder(
          builder: (context, box) => Center(
            child: SizedBox(
              width: box.maxWidth,
              height: box.maxHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: SizedBox(
                    width: 280,
                    child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showLogo) ...[
                    Image.asset('assets/brand/logo_dark.png', height: 64),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  // نقطه‌های رمز (با لرزش هنگام اشتباه)
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) {
                      final t = _shake.value;
                      final dx = t == 0 ? 0.0 : 10 * (1 - t) * _wave(t);
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < pinLength; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 9),
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _pin.length
                                    ? scheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: i < _pin.length
                                      ? scheme.primary
                                      : scheme.outline,
                                  width: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // صفحه‌کلید؛ مثل ماشین‌حساب چپ‌به‌راست
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      children: [
                        for (final row in const [
                          ['1', '2', '3'],
                          ['4', '5', '6'],
                          ['7', '8', '9'],
                        ])
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [for (final d in row) key(d)],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 72, height: 72),
                            key('0'),
                            // بدون Tooltip: قفل بالای Navigator است و Overlay ندارد
                            Semantics(
                              button: true,
                              label: 'پاک کردن',
                              child: InkResponse(
                                onTap: _back,
                                radius: 32,
                                child: const SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: Icon(Icons.backspace_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                    ), // Column
                  ), // SizedBox(280)
                ), // Padding
              ), // FittedBox
            ), // SizedBox
          ), // Center
        ), // LayoutBuilder
      ), // SafeArea
    );
  }

  static double _wave(double t) {
    // چند نوسان کوتاه
    const n = 4;
    final x = (t * n * 2) % 2;
    return x < 1 ? (x * 2 - 1) : (3 - x * 2);
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Text(label, style: theme.textTheme.headlineSmall),
            ),
          ),
        ),
      ),
    );
  }
}

/// تنظیم یا تغییر رمز: دو بار وارد می‌شود. اثر رمز را برمی‌گرداند.
class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  static Future<String?> open(BuildContext context) =>
      Navigator.of(context).push<String>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PinSetupPage(),
      ));

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String? _first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمز قفل')),
      body: PinPad(
        key: ValueKey(_first == null),
        title: _first == null ? 'یک رمز ۴ رقمی انتخاب کنید' : 'رمز را دوباره وارد کنید',
        subtitle: _first == null
            ? 'اگر رمز را فراموش کنید، فقط با پاک کردن برنامه باز می‌شود. '
                'پیش از آن پشتیبان بگیرید.'
            : null,
        onComplete: (pin) async {
          if (_first == null) {
            setState(() => _first = pin);
            return true;
          }
          if (pin != _first) {
            setState(() => _first = null);
            return false;
          }
          Navigator.of(context).pop(hashPin(pin));
          return true;
        },
      ),
    );
  }
}

/// پرسیدن رمز فعلی (برای خاموش کردن یا تغییر رمز)
Future<bool> confirmCurrentPin(BuildContext context) async {
  final s = await appDb.getSettings();
  final stored = s.raw[SettingKeys.lockPin] ?? '';
  if (stored.isEmpty || !context.mounted) return true;
  final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (ctx) => Scaffold(
      appBar: AppBar(title: const Text('رمز فعلی')),
      body: PinPad(
        title: 'رمز فعلی را وارد کنید',
        onComplete: (pin) async {
          if (hashPin(pin) != stored) return false;
          Navigator.of(ctx).pop(true);
          return true;
        },
      ),
    ),
  ));
  return ok ?? false;
}
