import 'dart:math' as math;

import 'package:flutter/material.dart';

/// سیستم واکنش‌گرای «کهربا».
///
/// همه‌ی تصمیم‌های اندازه‌ی صفحه از همین‌جا گرفته می‌شود تا هیچ صفحه‌ای
/// عدد دستی برای گوشی/تبلت/وب نداشته باشد.
///
/// استفاده:
/// ```dart
/// final rs = context.rs;
/// padding: EdgeInsets.symmetric(horizontal: rs.gutter)
/// final cols = rs.value(compact: 2, medium: 3, expanded: 4);
/// if (rs.isExpanded) ...
/// ```
///
/// مرزها (مطابق Material 3):
/// - compact: کمتر از ۶۰۰ — گوشی
/// - medium: ۶۰۰ تا ۸۴۰ — تبلت کوچک، گوشی افقی، پنجره‌ی باریک وب
/// - expanded: ۸۴۰ به بالا — تبلت بزرگ و دسکتاپ
enum ScreenSize { compact, medium, expanded }

abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  /// حداکثر عرض محتوا در هر اندازه
  static const double mediumContent = 760;
  static const double expandedContent = 1120;
}

@immutable
class Responsive {
  const Responsive._(this.width, this.height);

  /// اندازه‌ها از MediaQuery خوانده می‌شود. چون [ResponsiveWidth] اندازه‌ی
  /// MediaQuery را به عرض واقعی محتوا محدود می‌کند، داخل صفحه‌ها همیشه
  /// عرض قابل‌استفاده‌ی واقعی برگردانده می‌شود.
  factory Responsive.of(BuildContext context) {
    final s = MediaQuery.sizeOf(context);
    return Responsive._(s.width, s.height);
  }

  /// برای وقتی که فقط محدودیت‌های والد را داریم (داخل LayoutBuilder)
  factory Responsive.fromConstraints(BoxConstraints c) =>
      Responsive._(c.maxWidth, c.maxHeight.isFinite ? c.maxHeight : c.maxWidth);

  final double width;
  final double height;

  ScreenSize get size => width >= Breakpoints.expanded
      ? ScreenSize.expanded
      : width >= Breakpoints.medium
          ? ScreenSize.medium
          : ScreenSize.compact;

  bool get isCompact => size == ScreenSize.compact;
  bool get isMedium => size == ScreenSize.medium;
  bool get isExpanded => size == ScreenSize.expanded;

  /// تبلت یا بزرگ‌تر
  bool get isWide => !isCompact;

  bool get isLandscape => width > height;

  /// ارتفاع کم (گوشی افقی): باید چیزها فشرده‌تر شوند
  bool get isShort => height < 520;

  /// ضلع کوچک‌تر صفحه
  double get shortestSide => math.min(width, height);

  /// انتخاب مقدار بر اساس اندازه‌ی صفحه. اگر [medium] یا [expanded] داده
  /// نشود، مقدار اندازه‌ی کوچک‌تر استفاده می‌شود.
  T value<T>({required T compact, T? medium, T? expanded}) => switch (size) {
        ScreenSize.compact => compact,
        ScreenSize.medium => medium ?? compact,
        ScreenSize.expanded => expanded ?? medium ?? compact,
      };

  /// فاصله‌ی افقی صفحه از لبه‌ها
  double get gutter => value(compact: 16, medium: 24, expanded: 32);

  /// فاصله‌ی بین کارت‌ها
  double get gap => value(compact: 8, medium: 12, expanded: 16);

  /// حداکثر عرض محتوای صفحه‌ها
  double get contentMaxWidth => value(
        compact: double.infinity,
        medium: Breakpoints.mediumContent,
        expanded: Breakpoints.expandedContent,
      );

  /// حداکثر عرض متن خواندنی (پاراگراف، فرم)
  double get readableWidth => 620;

  /// حداکثر عرض فهرست‌های تک‌ستونه (پرونده‌ها، مشتری‌ها، …)
  double get listMaxWidth => 840;

  /// فاصله‌ی داخلی صفحه: روی گوشی همان [base]، روی صفحه‌ی پهن آن‌قدر از
  /// دو طرف فاصله می‌گیرد که محتوا بیشتر از [maxWidth] پهن نشود.
  /// (پیش‌فرض [listMaxWidth])
  EdgeInsets centered(EdgeInsets base, {double? maxWidth}) {
    final side = math.max(0.0, (width - (maxWidth ?? listMaxWidth)) / 2);
    return EdgeInsets.fromLTRB(
      math.max(base.left, side),
      base.top,
      math.max(base.right, side),
      base.bottom,
    );
  }

  /// فاصله‌ی صفحه‌های فرم و متن: عرض خواندنی و حاشیه‌ی [gutter]
  EdgeInsets readable({double top = 16, double bottom = 16}) => centered(
        EdgeInsets.fromLTRB(gutter, top, gutter, bottom),
        maxWidth: readableWidth,
      );

  /// فاصله‌ی افقی استاندارد صفحه با فاصله‌ی عمودی دلخواه
  EdgeInsets page({double top = 0, double bottom = 0}) =>
      EdgeInsets.fromLTRB(gutter, top, gutter, bottom);

  /// ضریب بزرگ‌نمایی برای اجزای نمایشی (لوگو، تصویرسازی، عنوان‌های بزرگ)
  double get scale => value(compact: 1.0, medium: 1.12, expanded: 1.2);

  /// اندازه‌ی [base] با ضریب [scale]
  double sized(double base) => base * scale;

  /// تعداد ستون مناسب: هر خانه دست‌کم [minTileWidth] پهنا داشته باشد.
  /// [available] اگر داده نشود عرض صفحه منهای فاصله‌ی دو طرف است.
  int columns({
    required double minTileWidth,
    double? available,
    double? spacing,
    int min = 1,
    int max = 12,
  }) {
    final w = available ?? (width - gutter * 2);
    final g = spacing ?? gap;
    final n = ((w + g) / (minTileWidth + g)).floor();
    return n.clamp(min, max).toInt();
  }

  /// پهنای هر خانه وقتی [count] ستون با فاصله‌ی [spacing] در [available] جا شوند
  static double tileWidth(double available, int count, double spacing) =>
      (available - spacing * (count - 1)) / count;
}

extension ResponsiveContext on BuildContext {
  /// دسترسی سریع: `context.rs.gutter`
  Responsive get rs => Responsive.of(this);
}

/// محتوای صفحه را روی تبلت و وب وسط می‌گذارد و حداکثر عرض می‌دهد؛
/// اندازه‌ی MediaQuery هم به همان عرض محدود می‌شود تا `context.rs` داخل
/// صفحه عرض واقعی را ببیند. روی گوشی هیچ اثری ندارد.
class ResponsiveWidth extends StatelessWidget {
  const ResponsiveWidth({super.key, required this.child, this.maxWidth});
  final Widget child;

  /// اگر داده نشود از [Responsive.contentMaxWidth] گرفته می‌شود
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final max = maxWidth ?? Responsive.of(context).contentMaxWidth;
    if (mq.size.width <= max) return child;
    return Center(
      child: SizedBox(
        width: max,
        child: MediaQuery(
          data: mq.copyWith(size: Size(max, mq.size.height)),
          child: child,
        ),
      ),
    );
  }
}

/// چیدن خانه‌ها در ستون‌های مساوی که تعدادشان با عرض عوض می‌شود.
/// [builder] پهنای هر خانه را می‌گیرد و فهرست خانه‌ها را برمی‌گرداند.
class AdaptiveWrap extends StatelessWidget {
  const AdaptiveWrap({
    super.key,
    required this.minTileWidth,
    required this.builder,
    this.minColumns = 1,
    this.maxColumns = 12,
    this.spacing,
    this.runSpacing,
  });

  final double minTileWidth;
  final int minColumns;
  final int maxColumns;
  final double? spacing;
  final double? runSpacing;
  final List<Widget> Function(double tileWidth) builder;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final g = spacing ?? rs.gap;
    return LayoutBuilder(
      builder: (context, box) {
        final n = rs.columns(
          minTileWidth: minTileWidth,
          available: box.maxWidth,
          spacing: g,
          min: minColumns,
          max: maxColumns,
        );
        // کمی کمتر برای جلوگیری از شکستن خط به خاطر گرد کردن
        final w = Responsive.tileWidth(box.maxWidth, n, g) - 0.01;
        return Wrap(
          spacing: g,
          runSpacing: runSpacing ?? g,
          children: builder(w),
        );
      },
    );
  }
}

/// چند بخش که روی گوشی زیر هم و روی صفحه‌ی پهن در [columns] ستون
/// کنار هم چیده می‌شوند (به ترتیب، ستون‌به‌ستون متوازن).
class AdaptiveColumns extends StatelessWidget {
  const AdaptiveColumns({
    super.key,
    required this.children,
    this.columns,
    this.spacing,
  });

  final List<Widget> children;

  /// اگر داده نشود: گوشی ۱، تبلت ۱، صفحه‌ی بزرگ ۲
  final int? columns;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final n = columns ?? rs.value<int>(compact: 1, medium: 1, expanded: 2);
    if (n <= 1 || children.length < 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    final cols = List.generate(n, (_) => <Widget>[]);
    for (var i = 0; i < children.length; i++) {
      cols[i % n].add(children[i]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < n; c++)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cols[c],
            ),
          ),
      ],
    );
  }
}

/// ساخت ویجت متفاوت برای هر اندازه‌ی صفحه
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    final b = context.rs.value<WidgetBuilder>(
      compact: compact,
      medium: medium,
      expanded: expanded,
    );
    return b(context);
  }
}

/// فهرست اصلی صفحه‌ها (جایگزین ListView با children):
/// - گوشی و تبلت: یک ستون
/// - صفحه‌ی بزرگ: بخش‌ها در دو ستون کنار هم ([columns])
/// - [readable]: برای فرم و متن؛ یک ستون با عرض خواندنی وسط صفحه
class ResponsiveListView extends StatelessWidget {
  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
    this.columns,
    this.readable = false,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final int? columns;
  final bool readable;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    if (readable) {
      return ListView(
        padding: rs.centered(
          padding.copyWith(
            left: math.max(padding.left, rs.gutter),
            right: math.max(padding.right, rs.gutter),
          ),
          maxWidth: rs.readableWidth,
        ),
        children: children,
      );
    }
    final n = columns ?? rs.value<int>(compact: 1, medium: 1, expanded: 2);
    if (n <= 1) {
      return ListView(
        padding: rs.centered(padding),
        children: children,
      );
    }
    return ListView(
      padding: padding,
      children: [AdaptiveColumns(columns: n, children: children)],
    );
  }
}
