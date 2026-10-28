import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'glass.dart';
import 'status_colors.dart';

/// تنها جایی که ظاهر کلی برنامه تعریف می‌شود.
/// طراحی: شیشه‌ای روی هاله‌های نور، با رنگ اصلی کهربایی (جرقه).
/// [lite] یعنی «حالت سبک»: محوسازی شیشه خاموش می‌شود.
abstract final class AppTheme {
  static const String fontFamily = 'Vazirmatn';

  static ThemeData light({bool lite = false}) => _build(
        brightness: Brightness.light,
        glass: GlassPalette.light(blur: !lite),
        status: StatusColors.standard,
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.light,
        ).copyWith(
          // شامپاینی: متن قهوه‌ای تیره، تأکید طلایی (تیره‌تر تا خوانا بماند)
          primary: const Color(0xFF8C6234),
          onPrimary: Colors.white,
          primaryContainer: const Color(0x33C9A26A),
          onPrimaryContainer: const Color(0xFF6B4720),
          secondary: const Color(0xFF8B7D70),
          surface: const Color(0xFFFCF8F2),
          onSurface: const Color(0xFF3A2A1C),
          onSurfaceVariant: const Color(0xFF7D6E60),
          outline: const Color(0xFFB5A592),
          outlineVariant: const Color(0x1F3A2A1C),
          surfaceContainerHighest: const Color(0xFFEFE5D6),
        ),
      );

  static ThemeData dark({bool lite = false}) => _build(
        brightness: Brightness.dark,
        glass: GlassPalette.dark(blur: !lite),
        status: StatusColors.bright,
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFFFB020),
          onPrimary: const Color(0xFF1A1000),
          primaryContainer: const Color(0x33FFB020),
          onPrimaryContainer: const Color(0xFFFFC857),
          surface: const Color(0xFF131A27),
          onSurface: const Color(0xFFEEF2F8),
          onSurfaceVariant: const Color(0xFF9AA6B8),
          outline: const Color(0xFF6B7689),
          outlineVariant: const Color(0x1FFFFFFF),
          surfaceContainerHighest: const Color(0xFF1E2636),
        ),
      );

  /// مشکی کامل (OLED): مثل تیره، با سطح‌های سیاه
  static ThemeData black({bool lite = false}) => _build(
        brightness: Brightness.dark,
        glass: GlassPalette.black(blur: false),
        status: StatusColors.bright,
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFFFB020),
          onPrimary: const Color(0xFF1A1000),
          primaryContainer: const Color(0x33FFB020),
          onPrimaryContainer: const Color(0xFFFFC857),
          surface: const Color(0xFF000000),
          onSurface: const Color(0xFFEEF2F8),
          onSurfaceVariant: const Color(0xFF9AA6B8),
          outline: const Color(0xFF5F6878),
          outlineVariant: const Color(0x24FFFFFF),
          surfaceContainerHighest: const Color(0xFF16161A),
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required GlassPalette glass,
    required StatusColors status,
  }) {
    final radius = BorderRadius.circular(AppSpacing.radius);
    final glassBorder = BorderSide(color: glass.border);
    final spark = glass.accent;
    final onSpark = glass.onAccent;
    final popupColor = brightness == Brightness.dark
        ? const Color(0xF2131A27)
        : const Color(0xF8FCF8F2);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,

      // صفحه‌ها شفاف‌اند؛ پس‌زمینه‌ی نورانی را انتقال صفحه می‌دهد.
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // همه‌ی سکوها (وب روی ویندوز/مک/لینوکس هم) تا پس‌زمینه و عرض
          // واکنش‌گرا همه‌جا اعمال شود
          TargetPlatform.android: GlassPageTransitionsBuilder(),
          TargetPlatform.iOS: GlassPageTransitionsBuilder(),
          TargetPlatform.windows: GlassPageTransitionsBuilder(),
          TargetPlatform.macOS: GlassPageTransitionsBuilder(),
          TargetPlatform.linux: GlassPageTransitionsBuilder(),
          TargetPlatform.fuchsia: GlassPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        // نوار وضعیت و نوار سیستم شفاف؛ برنامه تا لبه‌ی صفحه کشیده می‌شود.
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),

      // دکمه‌ی برگشت به سبک آیفون (در راست‌به‌چپ خودکار به راست اشاره می‌کند)
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) =>
            const Icon(Icons.arrow_back_ios_new, size: 20),
      ),

      cardTheme: CardThemeData(
        color: glass.fill,
        // در تم روشن سایه‌ی نرم، در تیره بدون سایه (مطابق طرح)
        elevation: brightness == Brightness.light ? 1.5 : 0,
        shadowColor: brightness == Brightness.light
            ? const Color(0x1F826040)
            : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: glassBorder,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glass.fill,
        border: OutlineInputBorder(borderRadius: radius, borderSide: glassBorder),
        enabledBorder:
            OutlineInputBorder(borderRadius: radius, borderSide: glassBorder),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: spark,
          foregroundColor: onSpark,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: glass.fill,
          side: glassBorder,
          shape: RoundedRectangleBorder(borderRadius: radius),
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: spark,
        foregroundColor: onSpark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: glass.fill,
        selectedColor: spark.withValues(alpha: brightness == Brightness.light ? 0.22 : 0.28),
        side: glassBorder,
        shape: RoundedRectangleBorder(borderRadius: radius),
        showCheckmark: false,
        // انتخاب‌ها جمع‌وجور
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: glass.fill,
          selectedBackgroundColor: spark.withValues(alpha: brightness == Brightness.light ? 0.22 : 0.28),
          side: glassBorder,
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 58,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: fontFamily, fontSize: 11),
        ),
        indicatorColor: spark.withValues(alpha: brightness == Brightness.light ? 0.22 : 0.26),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: popupColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: glassBorder,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: popupColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: popupColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius, side: glassBorder),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),

      dividerTheme: DividerThemeData(space: 1, color: glass.border),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
      extensions: [status, glass],
    );
  }
}
