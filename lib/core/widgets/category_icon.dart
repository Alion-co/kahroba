import 'package:flutter/material.dart';

import '../theme/glass.dart';

/// آیکن هر دسته. کلید در جدول Categories ذخیره می‌شود.
const Map<String, IconData> categoryIcons = {
  'heater': Icons.fireplace,
  'samovar': Icons.coffee_maker,
  'boiler': Icons.local_fire_department,
  'waterHeater': Icons.hot_tub,
  'cooler': Icons.air,
  'ac': Icons.ac_unit,
  'washer': Icons.local_laundry_service,
  'dishwasher': Icons.wash,
  'fridge': Icons.kitchen,
  'vacuum': Icons.cleaning_services,
  'iron': Icons.iron,
  'microwave': Icons.microwave,
  'tv': Icons.tv,
  'tool': Icons.handyman,
  'dryer': Icons.local_laundry_service_outlined,
  'hood': Icons.air,
  'coffee': Icons.coffee,
  'airfryer': Icons.outdoor_grill,
  'airPurifier': Icons.air_outlined,
  'waterFilter': Icons.water_drop,
  'waterCooler': Icons.local_drink,
  'multicooker': Icons.restaurant,
  'other': Icons.devices_other,
};

IconData categoryIcon(String key) => categoryIcons[key] ?? Icons.devices_other;

/// دایره‌ی رنگی با آیکن دسته. اگر [color] داده شود (مثلاً رنگ وضعیت)،
/// دایره با همان رنگ کم‌رنگ و آیکن با همان رنگ کشیده می‌شود.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.iconKey,
    this.radius = 20,
    this.color,
  });
  final String iconKey;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? GlassPalette.of(context).accent;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: 0.16),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Icon(
        categoryIcon(iconKey),
        size: radius * 1.0,
        color: color ?? scheme.primary,
      ),
    );
  }
}
