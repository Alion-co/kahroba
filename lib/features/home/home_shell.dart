import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

import '../../core/responsive/responsive.dart';
import '../../core/services/notifications.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';
import '../../core/theme/glass.dart';
import '../../core/widgets/motion.dart';
import '../cases/pages/case_form_page.dart';
import '../cases/pages/cases_page.dart';
import '../customers/pages/customers_page.dart';
import '../dashboard/dashboard_page.dart';
import '../knowledge_base/pages/kb_page.dart';
import '../schedule/calendar_page.dart';
import '../settings/more_page.dart';

/// اسکلت اصلی: نوار پایین پنج‌بخشی و دکمه‌ی شناور «+» سمت راست.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _quickActions = const QuickActions();

  /// بخش‌هایی که یک بار باز شده‌اند. بقیه تا اولین بازدید ساخته نمی‌شوند
  /// (بانک فنی و فهرست‌ها هنگام باز شدن برنامه بار نمی‌گیرند).
  final _visited = <int>{0};

  // ── اعلان نوبت‌ها: با هر تغییر پرونده‌ها یا تنظیمات از نو چیده می‌شود
  final _subs = <StreamSubscription<Object?>>[];
  Timer? _notifTimer;
  List<CaseRow>? _cases;
  ShopSettings? _settings;

  void _queueNotifications() {
    _notifTimer?.cancel();
    _notifTimer = Timer(const Duration(seconds: 2), () {
      final c = _cases, s = _settings;
      if (c == null || s == null) return;
      Notifications.sync(
        cases: c,
        jobsOn: s.notifyJobs,
        lastBackupAt: s.lastBackupAt,
      );
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _notifTimer?.cancel();
    super.dispose();
  }

  void _openCases() => setState(() {
        _index = 1;
        _visited.add(1);
      });

  @override
  void initState() {
    super.initState();
    if (Notifications.supported) {
      _subs.add(appDb.watchCases().listen((c) {
        _cases = c;
        _queueNotifications();
      }));
      _subs.add(appDb.watchSettings().listen((s) {
        _settings = s;
        _queueNotifications();
      }));
    }
    // میانبرهای آیکن برنامه (نگه داشتن انگشت روی آیکن)
    if (!kIsWeb) {
      _quickActions.initialize(_onShortcut);
      _quickActions.setShortcutItems(const [
        ShortcutItem(type: 'new_case', localizedTitle: 'پرونده جدید'),
        ShortcutItem(type: 'search', localizedTitle: 'جستجوی پرونده'),
        ShortcutItem(type: 'today', localizedTitle: 'تقویم کارها'),
      ]);
    }
  }

  void _onShortcut(String type) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (type) {
        case 'new_case':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CaseFormPage()),
          );
        case 'search':
          _openCases();
        case 'today':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CalendarPage()),
          );
      }
    });
  }

  void _add() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CaseFormPage()),
      );

  @override
  Widget build(BuildContext context) {
    Widget page(int i) {
      if (!_visited.contains(i)) return const SizedBox.shrink();
      return switch (i) {
        0 => DashboardPage(onOpenCases: _openCases),
        1 => const CasesPage(),
        // «مشتری جدید» در نوار بالا، تا با «+» شناور اشتباه نشود
        2 => const CustomersPage(embedded: true),
        3 => const KbPage(),
        _ => const MorePage(),
      };
    }

    final pages = IndexedStack(
      index: _index,
      children: [for (var i = 0; i < _navItems.length; i++) page(i)],
    );
    void select(int i) => setState(() {
          _index = i;
          _visited.add(i);
        });

    // صفحه‌ی بزرگ (تبلت افقی، وب): نوار کناری به‌جای نوار پایین
    if (context.rs.isExpanded) {
      return Scaffold(
        body: Row(
          children: [
            _FazRail(index: _index, onTap: select, onAdd: _add),
            // بخش‌ها روی صفحه‌ی خیلی پهن بیش از حد کشیده نشوند
            Expanded(child: ResponsiveWidth(child: pages)),
          ],
        ),
      );
    }
    return Scaffold(
      // تبلت عمودی: عرض محتوا محدود و وسط‌چین
      body: ResponsiveWidth(child: pages),
      bottomNavigationBar: _FazNavBar(index: _index, onTap: select),
      // «+» شناور سمت راست صفحه (در راست‌به‌چپ، «start» یعنی راست)
      floatingActionButton:
          PressScale(scale: 0.9, child: _AddButton(onTap: _add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _navItems = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'خانه'),
  _NavItem(Icons.folder_outlined, Icons.folder, 'پرونده‌ها'),
  _NavItem(Icons.people_outline, Icons.people, 'مشتری‌ها'),
  _NavItem(Icons.menu_book_outlined, Icons.menu_book, 'بانک فنی'),
  // نوار پایین افقی است: سه‌نقطه‌ی افقی؛ در نوار کناری عمودی می‌شود
  _NavItem(Icons.more_horiz, Icons.more_horiz, 'بیشتر'),
];

class _FazNavBar extends StatelessWidget {
  const _FazNavBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const double _barHeight = 62;

  Widget _item(BuildContext context, int i) {
    final scheme = Theme.of(context).colorScheme;
    final selected = i == index;
    final item = _navItems[i];
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // قرص روشن پشت آیکن انتخاب‌شده، با حرکت نرم
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 16 : 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: color,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            children: [
              for (var i = 0; i < _navItems.length; i++) _item(context, i),
            ],
          ),
        ),
      ),
    );
  }
}

/// دکمه‌ی «پرونده جدید»: مربع گرد کهربایی، با هاله‌ی نرم هم‌رنگ.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = GlassPalette.of(context);
    final radius = BorderRadius.circular(18);
    return Semantics(
      button: true,
      label: 'پرونده جدید',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: g.accentGradient,
          boxShadow: [
            BoxShadow(
              color: g.accent.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.add_rounded, size: 30, color: g.onAccent),
            ),
          ),
        ),
      ),
    );
  }
}

/// نوار کناری برای صفحه‌های بزرگ؛ همان بخش‌ها و همان دکمه‌ی «+».
class _FazRail extends StatelessWidget {
  const _FazRail({
    required this.index,
    required this.onTap,
    required this.onAdd,
  });

  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassPanel(
      borderRadius: const BorderRadiusDirectional.horizontal(
        end: Radius.circular(24),
      ).resolve(Directionality.of(context)),
      child: SafeArea(
        child: NavigationRail(
          backgroundColor: Colors.transparent,
          selectedIndex: index,
          onDestinationSelected: onTap,
          labelType: NavigationRailLabelType.all,
          groupAlignment: -0.7,
          indicatorColor: scheme.primary.withValues(alpha: 0.16),
          selectedIconTheme: IconThemeData(color: scheme.primary),
          selectedLabelTextStyle: TextStyle(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
          ),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Image.asset('assets/brand/logo_dark.png', height: 40),
                const SizedBox(height: 16),
                PressScale(scale: 0.9, child: _AddButton(onTap: onAdd)),
              ],
            ),
          ),
          destinations: [
            for (final item in _navItems)
              NavigationRailDestination(
                icon: Icon(_railIcon(item.icon)),
                selectedIcon: Icon(_railIcon(item.selectedIcon)),
                label: Text(item.label),
              ),
          ],
        ),
      ),
    );
  }
}

/// نوار کناری عمودی است: سه‌نقطه‌ی «بیشتر» هم عمودی نشان داده می‌شود
IconData _railIcon(IconData icon) =>
    icon == Icons.more_horiz ? Icons.more_vert : icon;
