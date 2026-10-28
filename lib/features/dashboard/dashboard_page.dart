import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/services/launcher.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/status_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/text_utils.dart';
import '../../core/theme/glass.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/section.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';
import '../cases/pages/case_detail_page.dart';
import '../cases/pages/cases_page.dart';
import '../cases/widgets/case_tile.dart';
import '../../core/widgets/appointment_picker.dart';
import '../customers/pages/customer_detail_page.dart';
import '../onboarding/splash_page.dart';
import '../schedule/today_page.dart';
import '../../core/services/rate_prompt.dart';
import 'quick_access.dart';
import 'welcome_card.dart';
import '../schedule/calendar_page.dart';

/// صفحه‌ی خانه: وضعیت کارها، وسایل آماده و هشدار وسایل جامانده.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onOpenCases});
  final VoidCallback onOpenCases;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _cases = appDb.watchCases();
  final _settings = appDb.watchSettings();
  final _money = appDb.watchMoney();

  /// ورود پله‌ای بخش‌ها فقط بار اولی که صفحه ساخته می‌شود
  bool _intro = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _intro = false);
    });
    // درخواست امتیاز مایکت (فقط اگر شرایطش برقرار باشد)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) RatePrompt.maybeAsk(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShopSettings>(
      stream: _settings,
      builder: (context, settingsSnap) {
        final settings = settingsSnap.data ?? const ShopSettings({});
        return StreamBuilder<List<CaseRow>>(
          stream: _cases,
          builder: (context, snap) {
            final all = snap.data;
            // نقطه‌ی زنگ: کار در محل امروز یا وسیله‌ی جامانده
            final alert = all != null &&
                (_TodayJobs.of(all).isNotEmpty ||
                    all.any((r) =>
                        r.repairCase.status == CaseStatus.ready &&
                        daysSince(r.repairCase.readyAt ??
                                r.repairCase.receivedAt) >=
                            settings.abandonDays));
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 92,
                centerTitle: false,
                titleSpacing: context.rs.gutter + 4,
                title: _HomeHeader(
                  alert: alert,
                  onBell: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarPage()),
                  ),
                ),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(40),
                  child: _Greeting(),
                ),
              ),
              body: all == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<Map<int, CaseMoney>>(
                      stream: _money,
                      builder: (context, moneySnap) => _body(
                        context,
                        all,
                        settings,
                        moneySnap.data ?? const {},
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    List<CaseRow> all,
    ShopSettings settings,
    Map<int, CaseMoney> money,
  ) {
    // بدهکارها: مانده‌ی پرونده‌های تحویل‌شده، به تفکیک مشتری
    final byId = {for (final r in all) r.repairCase.id: r};
    final debtors = <int, (Customer, int)>{};
    for (final m in money.values) {
      if (!m.isDebt) continue;
      final r = byId[m.caseId];
      if (r == null) continue;
      final prev = debtors[m.customerId]?.$2 ?? 0;
      debtors[m.customerId] = (r.customer, prev + m.due);
    }
    final debtorList = debtors.values.toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final totalDebt = debtorList.fold<int>(0, (s, d) => s + d.$2);
    final todayJobs = _TodayJobs.of(all);

    final theme = Theme.of(context);
    final open = all.where((r) => r.repairCase.status.isOpen).toList();
    final ready =
        all.where((r) => r.repairCase.status == CaseStatus.ready).toList();
    final abandoned = ready.where((r) {
      final since = r.repairCase.readyAt ?? r.repairCase.receivedAt;
      return daysSince(since) >= settings.abandonDays;
    }).toList();

    // آمار ماه جاری شمسی
    final now = Jalali.now();
    final (monthStart, monthEnd) = jalaliMonthRange(now.year, now.month);
    bool inMonth(DateTime? d) =>
        d != null && !d.isBefore(monthStart) && d.isBefore(monthEnd);
    final receivedThisMonth =
        all.where((r) => inMonth(r.repairCase.receivedAt)).length;

    final counts = <CaseStatus, int>{};
    for (final r in open) {
      counts[r.repairCase.status] = (counts[r.repairCase.status] ?? 0) + 1;
    }

    // ───── دفتر خالی: خوشامد + شروع سریع
    if (all.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: AppSpacing.fabClearance,
        ),
        children: [
          FadeSlideIn(
            child: Text(
              'به کهربا خوش آمدید',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FadeSlideIn(
            index: 2,
            child: Padding(
              padding: context.rs.page(),
              child: Text(
                'چهار قدم کوتاه تا دفتر تعمیرگاه‌تان آماده شود.\n'
                'هر کدام را انجام دهید، خودش تیک می‌خورد.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.7,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: FadeSlideIn(
                index: 3,
                child: WelcomeCard(
                  settings: settings,
                  hasCases: false,
                  showClose: false,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final sections = <Widget>[
        // ───── سربرگ مغازه با آمار زنده
        _HeaderCard(
          shopName: settings.shopName,
          tagline: settings.shopTagline,
          open: open.length,
          ready: ready.length,
          thisMonth: receivedThisMonth,
        ),

        // ───── هشدار وسایل جامانده
        if (abandoned.isNotEmpty)
          _AbandonedCard(
            abandoned: abandoned,
            days: settings.abandonDays,
          ),

        // ───── کارهای امروز در محل
        if (todayJobs.isNotEmpty)
          SectionCard(
            title: 'کارهای امروز در محل (${toFaDigits(todayJobs.length)})',
            icon: Icons.event,
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              ),
              child: const Text('همه'),
            ),
            child: Column(
              children: [
                for (final r in todayJobs.take(4))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      formatAppointment(r.repairCase.appointmentAt!)
                          .split(' ')
                          .last,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    title: Text('${r.customer.name} • ${r.deviceTitle}'),
                    subtitle: r.customer.address.isEmpty
                        ? null
                        : Text(r.customer.address,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          CaseDetailPage(caseId: r.repairCase.id),
                    )),
                  ),
              ],
            ),
          ),

        // ───── بدهکارها
        if (debtorList.isNotEmpty)
          SectionCard(
            title: 'طلب از مشتری‌ها: ${formatToman(totalDebt)}',
            icon: Icons.account_balance_wallet_outlined,
            child: Column(
              children: [
                for (final (cu, due) in debtorList.take(5))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(cu.name),
                    trailing: Text(
                      formatToman(due),
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CustomerDetailPage(customerId: cu.id),
                    )),
                  ),
              ],
            ),
          ),

        // ───── شمارش وضعیت‌ها
        SectionCard(
          title: 'کارهای در جریان: ${toFaDigits(open.length)}',
          icon: Icons.folder_outlined,
          trailing: TextButton(
            onPressed: widget.onOpenCases,
            child: const Text('همه'),
          ),
          child: open.isEmpty
              ? const Text('کار در جریانی ندارید.')
              // گوشی ۴ ستون؛ با پهن شدن صفحه تا ۶ ستون
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: AdaptiveWrap(
                    minTileWidth: 70,
                    minColumns: 4,
                    maxColumns: 6,
                    builder: (w) => [
                        for (final s in CaseStatus.values)
                          if ((counts[s] ?? 0) > 0)
                            SizedBox(
                              width: w,
                              child: _StatusTile(
                                status: s,
                                count: counts[s]!,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CasesPage(initialStatus: s),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
        ),

        // ───── آماده‌ی تحویل
        if (ready.isNotEmpty)
          SectionCard(
            title: 'آماده‌ی تحویل (${toFaDigits(ready.length)})',
            icon: Icons.check_circle_outline,
            child: Column(
              children: [for (final r in ready.take(5)) CaseTile(item: r, inset: true)],
            ),
          ),

    ];
    return ListView(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.fabClearance,
      ),
      children: [
        // سربرگ تمام‌عرض؛ بقیه روی صفحه‌ی بزرگ در دو ستون
        FadeSlideIn(enabled: _intro, child: sections.first),
        // کارت شروع سریع تا وقتی قدمی مانده و بسته نشده
        if (WelcomeCard.shouldShow(settings))
          FadeSlideIn(
            index: 1,
            enabled: _intro,
            child: WelcomeCard(settings: settings, hasCases: true),
          ),
        // ───── دسترسی سریع
        FadeSlideIn(index: 1, enabled: _intro, child: const QuickAccessRow()),
        AdaptiveColumns(
          children: [
            for (var i = 1; i < sections.length; i++)
              FadeSlideIn(index: i, enabled: _intro, child: sections[i]),
          ],
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.status,
    required this.count,
    required this.onTap,
  });
  final CaseStatus status;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.statusColors.of(status);
    final theme = Theme.of(context);
    return PressScale(
      scale: 0.94,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        // ارتفاع ثابت تا روی صفحه‌ی پهن کاشی دراز نشود
        child: SizedBox(
          height: 92,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.24),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_statusIcon(status), size: 20, color: color),
                AnimatedCount(
                  value: count,
                  format: toFaDigits,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                Text(
                  status.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _statusIcon(CaseStatus s) => switch (s) {
      CaseStatus.received => Icons.move_to_inbox_outlined,
      CaseStatus.diagnosing => Icons.search,
      CaseStatus.awaitingApproval => Icons.request_quote_outlined,
      CaseStatus.waitingParts => Icons.inventory_2_outlined,
      CaseStatus.repairing => Icons.build_outlined,
      CaseStatus.ready => Icons.check_circle_outline,
      CaseStatus.delivered => Icons.done_all,
      CaseStatus.unrepairable => Icons.block,
      CaseStatus.warrantyReturn => Icons.replay,
    };

/// سربرگ داشبورد: نام مغازه، تاریخ امروز و سه عدد زنده.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.shopName,
    required this.tagline,
    required this.open,
    required this.ready,
    required this.thisMonth,
  });

  final String shopName;
  final String tagline;
  final int open;
  final int ready;
  final int thisMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurfaceVariant;

    Widget stat(int v, String label, Color c) => Expanded(
          child: Column(
            children: [
              AnimatedCount(
                value: v,
                format: toFaDigits,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: c),
              ),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            ],
          ),
        );

    return Container(
      margin: context.rs.page(top: AppSpacing.xs, bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: dark
              ? (GlassPalette.of(context).isBlack
                  ? const [Color(0xFF141416), Color(0xFF070708)]
                  : const [Color(0xFF1A2236), Color(0xFF111827)])
              : const [Color(0xFFFFFCF6), Color(0xFFF4E8D4)],
        ),
        border: Border.all(
          color: GlassPalette.of(context).accent.withValues(alpha: dark ? 0.28 : 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: GlassPalette.of(context).accent.withValues(alpha: dark ? 0.10 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // هاله‌ی کهربایی گوشه، مثل صفحه‌ی آغاز
            PositionedDirectional(
              top: -60,
              end: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    GlassPalette.of(context).accent.withValues(alpha: dark ? 0.30 : 0.22),
                    GlassPalette.of(context).accent.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (tagline.isNotEmpty)
                              Text(
                                tagline,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: muted),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: GlassPalette.of(context).accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          formatDate(DateTime.now()),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      stat(open, 'در جریان', theme.colorScheme.primary),
                      _divider(theme),
                      stat(ready, 'آماده‌ی تحویل',
                          context.statusColors.of(CaseStatus.ready)),
                      _divider(theme),
                      stat(thisMonth, 'پذیرش این ماه', theme.colorScheme.onSurface),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) => Container(
        width: 1,
        height: 34,
        color: theme.colorScheme.outlineVariant,
      );
}

/// کارهای در محلِ زمان‌دارِ امروز
abstract final class _TodayJobs {
  static List<CaseRow> of(List<CaseRow> all) =>
      TodayPageJobs.forDay(all, DateTime.now());
}

/// کارت کهربایی «وسایل جامانده»
class _AbandonedCard extends StatelessWidget {
  const _AbandonedCard({required this.abandoned, required this.days});
  final List<CaseRow> abandoned;
  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = GlassPalette.of(context).accent;
    final first = abandoned.first;
    final phone = first.customer.phone.isNotEmpty
        ? first.customer.phone
        : first.customer.phone2;
    return Container(
      margin: context.rs.page(top: AppSpacing.sm, bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            amber.withValues(alpha: 0.30),
            amber.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: amber.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: amber, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وسایل جامانده',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.brightness == Brightness.dark
                            ? amber
                            : theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${toFaDigits(abandoned.length)} دستگاه بیش از ${toFaDigits(days)} روز آماده مانده',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final r in abandoned.take(3))
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CaseDetailPage(caseId: r.repairCase.id),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• ${r.customer.name} — ${r.deviceTitle} (${toFaDigits(daysSince(r.repairCase.readyAt ?? r.repairCase.receivedAt))} روز)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(120, 40)),
                onPressed: () => Launcher.call(phone),
                icon: const Icon(Icons.call, size: 18),
                label: Text('تماس با ${first.customer.name}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// سربرگ خانه: کاشی لوگو، «کهربا» و شعار، و زنگ یادآورها
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.alert, required this.onBell});
  final bool alert;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final g = GlassPalette.of(context);
    final bell = Material(
      color: g.fill,
      borderRadius: BorderRadius.circular(16),
      elevation: theme.brightness == Brightness.light ? 2 : 0,
      shadowColor: const Color(0x33826040),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onBell,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_none_rounded,
                  size: 24, color: scheme.onSurface),
              if (alert)
                PositionedDirectional(
                  top: 8,
                  end: 9,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: g.accent,
                      border: Border.all(color: g.fill, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    // راست‌به‌چپ: لوگو و نام سمت راست، زنگ سمت چپ
    return Row(
      children: [
        Hero(
          tag: brandLogoHeroTag,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset('assets/brand/logo_dark.png', height: 54),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'کهربا',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                  height: 1.2,
                ),
              ),
              Text(
                'دفتر دیجیتال تعمیرکاران',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        bell,
      ],
    );
  }
}

/// سلام کوتاه بر اساس ساعت روز
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = DateTime.now().hour;
    final day = h >= 5 && h < 17;
    final text = day
        ? 'سلام، روزت پربرکت'
        : h >= 17 && h < 21
            ? 'عصر بخیر، خسته نباشی'
            : 'شب بخیر، خسته نباشی';
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: context.rs.gutter + 4,
        end: context.rs.gutter + 4,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            day ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
            size: 22,
            color: GlassPalette.of(context).accent,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
