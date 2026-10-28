import 'package:flutter/material.dart';

import '../../../core/theme/status_colors.dart';
import '../../../data/enums.dart';

/// برگه‌ی پایین صفحه برای انتخاب وضعیت جدید. وضعیت انتخاب‌شده را برمی‌گرداند.
Future<CaseStatus?> showStatusPickerSheet(
  BuildContext context,
  CaseStatus current,
) {
  return showModalBottomSheet<CaseStatus>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            for (final s in CaseStatus.values)
              ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 14,
                  color: ctx.statusColors.of(s),
                ),
                title: Text(s.label),
                trailing: s == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(s),
              ),
          ],
        ),
      ),
    ),
  );
}
