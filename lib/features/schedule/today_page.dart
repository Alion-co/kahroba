import 'package:flutter/material.dart';

import '../../core/services/launcher.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/appointment_picker.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../cases/pages/case_detail_page.dart';

/// کارهای در محلِ یک روز، به ترتیب ساعت، با مسیریابی و تماس.
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final _cases = appDb.watchCases();
  int _offset = 0; // ۰ امروز، ۱ فردا

  /// کارهای در محل در جریان برای روز انتخاب‌شده (+ بدون زمان در «امروز»)
  static List<CaseRow> jobsFor(List<CaseRow> all, DateTime day,
      {bool includeUnscheduled = false}) {
    final d = DateUtils.dateOnly(day);
    final list = all.where((r) {
      final c = r.repairCase;
      if (c.jobType != JobType.onSite || !c.status.isOpen) return false;
      final a = c.appointmentAt;
      if (a == null) return includeUnscheduled;
      return DateUtils.isSameDay(a, d);
    }).toList()
      ..sort((a, b) {
        final x = a.repairCase.appointmentAt, y = b.repairCase.appointmentAt;
        if (x == null) return 1;
        if (y == null) return -1;
        return x.compareTo(y);
      });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now().add(Duration(days: _offset));
    return Scaffold(
      appBar: AppBar(title: const Text('کارهای در محل')),
      body: Column(
        children: [
          Padding(
            padding: context.rs.readable(),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text('امروز ${formatDayMonth(DateTime.now())}')),
                ButtonSegment(
                    value: 1,
                    label: Text(
                        'فردا ${formatDayMonth(DateTime.now().add(const Duration(days: 1)))}')),
              ],
              selected: {_offset},
              onSelectionChanged: (v) => setState(() => _offset = v.first),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CaseRow>>(
              stream: _cases,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final jobs = jobsFor(snap.data!, day,
                    includeUnscheduled: _offset == 0);
                if (jobs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'کار در محلی نیست',
                    message:
                        'در پرونده‌های «در محل مشتری» زمان قرار را ثبت کنید تا اینجا بیاید.',
                  );
                }
                return ListView.builder(
                  padding: context.rs.centered(
                      const EdgeInsets.only(bottom: AppSpacing.xl)),
                  itemCount: jobs.length,
                  itemBuilder: (context, i) => JobCard(row: jobs[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// کارت کار در محل با مسیریابی و تماس (در تقویم کارها هم به‌کار می‌رود)
class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.row});
  final CaseRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = row.repairCase;
    final cu = row.customer;
    final phone = cu.phone.isNotEmpty ? cu.phone : cu.phone2;
    final hasPlace =
        cu.address.isNotEmpty || (cu.latitude != null && cu.longitude != null);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CaseDetailPage(caseId: c.id),
        )),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryAvatar(iconKey: row.category.icon),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.appointmentAt == null
                              ? 'بدون زمان'
                              : formatAppointment(c.appointmentAt!),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                        Text('${cu.name} • ${row.deviceTitle}'),
                      ],
                    ),
                  ),
                ],
              ),
              if (cu.address.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(cu.address, style: theme.textTheme.bodyMedium),
              ],
              if (cu.note.isNotEmpty)
                Text(cu.note,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: hasPlace
                          ? () => Launcher.map(
                                lat: cu.latitude,
                                lng: cu.longitude,
                                address: cu.address,
                              )
                          : null,
                      icon: const Icon(Icons.directions),
                      label: const Text('مسیریابی'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          phone.isEmpty ? null : () => Launcher.call(phone),
                      icon: const Icon(Icons.call),
                      label: const Text('تماس'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// دسترسی عمومی به فهرست کارهای یک روز (برای داشبورد)
abstract final class TodayPageJobs {
  static List<CaseRow> forDay(List<CaseRow> all, DateTime day) =>
      _TodayPageState.jobsFor(all, day);
}
