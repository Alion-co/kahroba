import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/responsive/responsive.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'data/database.dart';
import 'data/defaults.dart';
import 'features/lock/app_lock.dart';
import 'features/onboarding/splash_page.dart';

/// ریشه‌ی برنامه: تم (روشن، تیره، حالت سبک)، زبان و صفحه‌ی شروع.
/// انتخاب تم از تنظیمات خوانده می‌شود و بلافاصله اعمال می‌شود.
class FazApp extends StatefulWidget {
  const FazApp({super.key});

  @override
  State<FazApp> createState() => _FazAppState();
}

class _FazAppState extends State<FazApp> {
  final _settings = appDb.watchSettings();

  static ThemeMode _mode(String name) => switch (name) {
        'light' => ThemeMode.light,
        'dark' || 'black' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShopSettings>(
      stream: _settings,
      builder: (context, snap) {
        final s = snap.data ?? const ShopSettings({});
        return MaterialApp(
          title: 'کهربا',
          debugShowCheckedModeBanner: false,
          // فارسی و راست‌به‌چپ
          locale: const Locale('fa', 'IR'),
          supportedLocales: const [Locale('fa', 'IR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(lite: s.liteMode),
          darkTheme: s.themeModeName == 'black'
              ? AppTheme.black(lite: s.liteMode)
              : AppTheme.dark(lite: s.liteMode),
          themeMode: _mode(s.themeModeName),
          // فونت خیلی بزرگ گوشی صفحه‌ها را به هم نریزد
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final theme = Theme.of(context);
            final rs = context.rs;
            return MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
              ),
              // فاصله‌ی کارت‌ها از لبه‌ی صفحه بر اساس اندازه‌ی صفحه
              child: Theme(
                data: theme.copyWith(
                  cardTheme: theme.cardTheme.copyWith(
                    margin: EdgeInsets.symmetric(
                      horizontal: rs.gutter,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
                // قفل برنامه روی همه‌ی صفحه‌ها
                child: AppLockGate(
                  pinHash: s.lockPin,
                  ready: snap.hasData,
                  child: child!,
                ),
              ),
            );
          },
          // صفحه‌ی آغاز → (بار اول) معرفی → خانه
          home: const SplashPage(),
        );
      },
    );
  }
}
