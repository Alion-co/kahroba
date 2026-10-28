import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/services/share_image.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';
import '../settings/settings_page.dart';

/// متن کارت تماس (vCard) مغازه؛ با اسکن، شماره در مخاطبین ذخیره می‌شود.
String shopVCard(ShopSettings s) {
  String esc(String v) => v.replaceAll(';', r'\;').replaceAll(',', r'\,');
  return [
    'BEGIN:VCARD',
    'VERSION:3.0',
    'FN:${esc(s.shopName)}',
    'ORG:${esc(s.shopName)}',
    if (s.shopPhone.isNotEmpty) 'TEL;TYPE=WORK,VOICE:${s.shopPhone}',
    if (s.shopAddress.isNotEmpty) 'ADR;TYPE=WORK:;;${esc(s.shopAddress)};;;;',
    'NOTE:${esc('تعمیر وسایل برقی')}',
    'END:VCARD',
  ].join('\n');
}

/// کارت ویزیت QR مغازه برای چسباندن روی پیشخوان یا فرستادن به مشتری.
class BusinessCardPage extends StatefulWidget {
  const BusinessCardPage({super.key});

  @override
  State<BusinessCardPage> createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  final _settings = appDb.watchSettings();
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کارت ویزیت QR')),
      body: StreamBuilder<ShopSettings>(
        stream: _settings,
        builder: (context, snap) {
          final s = snap.data;
          if (s == null) return const Center(child: CircularProgressIndicator());
          if (s.shopPhone.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EmptyState(
                    message: 'اول تلفن مغازه را در تنظیمات وارد کنید.'),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SettingsPage())),
                  child: const Text('رفتن به تنظیمات'),
                ),
              ],
            );
          }
          return ResponsiveListView(
            readable: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Center(
                child: RepaintBoundary(
                  key: _key,
                  child: _Card(settings: s),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'مشتری با دوربین گوشی این QR را اسکن کند تا شماره‌ی مغازه در مخاطبینش ذخیره شود.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await shareWidgetAsImage(_key, fileName: 'kahroba-card');
                  } catch (e) {
                    if (context.mounted) showSnack(context, 'ساخت تصویر نشد: $e');
                  }
                },
                icon: const Icon(Icons.share),
                label: const Text('اشتراک یا چاپ تصویر کارت'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.settings});
  final ShopSettings settings;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF18202E);
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB020), width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(settings.shopName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: ink)),
          const Text('تعمیر وسایل برقی و لوازم خانگی',
              style: TextStyle(fontSize: 13, color: Color(0xFF5B6474))),
          const SizedBox(height: 14),
          QrImageView(
            data: shopVCard(settings),
            size: 200,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(toFaDigits(settings.shopPhone),
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: ink)),
          if (settings.shopAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(settings.shopAddress,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: ink)),
            ),
          const SizedBox(height: 10),
          const Text('برای ذخیره‌ی شماره، QR را اسکن کنید',
              style: TextStyle(fontSize: 11, color: Color(0xFF8A93A3))),
        ],
      ),
    );
  }
}
