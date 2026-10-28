import 'package:flutter/material.dart';

import '../../../core/theme/status_colors.dart';
import '../../../data/enums.dart';

/// برچسب وضعیت: قرص کم‌رنگ با نقطه و متن به رنگ وضعیت.
class StatusChip extends StatelessWidget {
  final CaseStatus status;
  final bool dense;
  const StatusChip({super.key, required this.status, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color = context.statusColors.of(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
