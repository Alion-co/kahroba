import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/section.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';
import '../../core/services/notifications.dart';
import '../../core/utils/format.dart';
import '../backup/backup_page.dart';
import '../lock/app_lock.dart';
import '../sync/sync_page.dart';
import 'categories_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settings = appDb.watchSettings();

  Future<void> _editText(
    ShopSettings s,
    String key,
    String title, {
    bool multiline = false,
    bool phone = false,
  }) async {
    final v = await showTextEditDialog(
      context,
      title: title,
      initial: phone ? formatPhoneInput(s.get(key)) : s.get(key),
      multiline: multiline,
      inputFormatters: phone ? InputKinds.phoneFormatters : null,
      textDirection: phone ? InputKinds.phoneDirection : null,
      keyboardType: phone ? TextInputType.phone : null,
    );
    if (v == null) return;
    // شماره همیشه یکسان‌شده (رقم انگلیسی، بدون فاصله) ذخیره می‌شود
    await appDb.setSetting(key, phone ? normalizePhone(v) : v.trim());
  }

  Future<void> _editNumber(ShopSettings s, String key, String title) async {
    final v = await showNumberEditDialog(
      context,
      title: title,
      initial: int.tryParse(s.get(key)) ?? 0,
    );
    if (v != null) await appDb.setSetting(key, v.toString());
  }

  void _go(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: StreamBuilder<ShopSettings>(
        stream: _settings,
        builder: (context, snap) {
          final s = snap.data ?? const ShopSettings({});
          return ResponsiveListView(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 40),
            children: [
              SectionCard(
                title: 'ظاهر',
                icon: Icons.palette_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    // چهار گزینه؛ فقط متن تا روی گوشی باریک هم جا شود
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 'system', label: Text('خودکار')),
                        ButtonSegment(value: 'light', label: Text('روشن')),
                        ButtonSegment(value: 'dark', label: Text('تیره')),
                        ButtonSegment(value: 'black', label: Text('مشکی')),
                      ],
                      selected: {s.themeModeName},
                      onSelectionChanged: (v) =>
                          appDb.setSetting(SettingKeys.themeMode, v.first),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('حالت سبک'),
                      subtitle: const Text(
                          'بدون محوسازی و هاله‌های نور؛ سریع‌تر و کم‌مصرف‌تر'),
                      value: s.liteMode,
                      onChanged: (v) =>
                          appDb.setSetting(SettingKeys.liteMode, v ? '1' : '0'),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'مغازه',
                icon: Icons.storefront_outlined,
                child: Column(
                  children: [
                    InfoRow(
                      label: 'نام مغازه',
                      value: s.shopName,
                      onTap: () => _editText(s, SettingKeys.shopName, 'نام مغازه'),
                    ),
                    InfoRow(
                      label: 'تلفن مغازه',
                      value: toFaDigits(s.shopPhone),
                      onTap: () => _editText(
                          s, SettingKeys.shopPhone, 'تلفن مغازه',
                          phone: true),
                    ),
                    InfoRow(
                      label: 'شعار مغازه',
                      value: s.shopTagline,
                      onTap: () =>
                          _editText(s, SettingKeys.shopTagline, 'شعار مغازه'),
                    ),
                    InfoRow(
                      label: 'آدرس مغازه',
                      value: s.shopAddress,
                      onTap: () => _editText(
                          s, SettingKeys.shopAddress, 'آدرس مغازه',
                          multiline: true),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'پرونده‌ها',
                icon: Icons.folder_outlined,
                child: Column(
                  children: [
                    InfoRow(
                      label: 'گارانتی پیش‌فرض',
                      value: '${toFaDigits(s.defaultWarrantyDays)} روز',
                      onTap: () => _editNumber(s,
                          SettingKeys.defaultWarrantyDays, 'گارانتی پیش‌فرض (روز)'),
                    ),
                    InfoRow(
                      label: 'هشدار جاماندگی',
                      value: 'بعد از ${toFaDigits(s.abandonDays)} روز',
                      onTap: () => _editNumber(s, SettingKeys.abandonDays,
                          'دستگاه آماده بعد از چند روز «جامانده» حساب شود؟'),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'امنیت و پشتیبان',
                icon: Icons.shield_outlined,
                child: Column(
                  children: [
                    _NavTile(
                      icon: Icons.cloud_upload_outlined,
                      title: 'پشتیبان‌گیری و بازیابی',
                      subtitle: s.lastBackupAt == null
                          ? 'هنوز پشتیبانی گرفته نشده'
                          : 'آخرین پشتیبان: ${formatDate(s.lastBackupAt!)}',
                      onTap: () => _go(const BackupPage()),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.lock_outline),
                      title: const Text('قفل برنامه'),
                      subtitle: const Text('با باز شدن برنامه رمز ۴ رقمی می‌خواهد'),
                      value: s.lockOn,
                      onChanged: (on) async {
                        if (on) {
                          final hash = await PinSetupPage.open(context);
                          if (hash != null) {
                            await appDb.setSetting(SettingKeys.lockPin, hash);
                            if (context.mounted) showSnack(context, 'قفل برنامه روشن شد.');
                          }
                        } else if (await confirmCurrentPin(context)) {
                          await appDb.setSetting(SettingKeys.lockPin, '');
                        }
                      },
                    ),
                    if (s.lockOn)
                      _NavTile(
                        icon: Icons.password,
                        title: 'تغییر رمز',
                        onTap: () async {
                          if (!await confirmCurrentPin(context)) return;
                          if (!context.mounted) return;
                          final hash = await PinSetupPage.open(context);
                          if (hash != null) {
                            await appDb.setSetting(SettingKeys.lockPin, hash);
                          }
                        },
                      ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('اعلان نوبت‌ها'),
                      subtitle: Text(Notifications.supported
                          ? 'یک ساعت پیش از کار در محل، و خلاصه‌ی صبح'
                          : 'فقط در نسخه‌ی اندروید'),
                      value: s.notifyJobs,
                      onChanged: Notifications.supported
                          ? (v) => appDb.setSetting(
                              SettingKeys.notifyJobs, v ? '1' : '0')
                          : null,
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'دفتر',
                icon: Icons.menu_book_outlined,
                child: Column(
                  children: [
                    _NavTile(
                      icon: Icons.category_outlined,
                      title: 'دسته‌بندی دستگاه‌ها',
                      onTap: () => _go(const CategoriesPage()),
                    ),
                    _NavTile(
                      icon: Icons.sync,
                      title: 'همگام‌سازی با همکار',
                      subtitle: 'یکی کردن دفتر دو گوشی با Wi‑Fi، بدون اینترنت',
                      onTap: () => _go(const SyncPage()),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'متن پیامک‌ها',
                icon: Icons.sms_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'این کلمه‌ها خودکار جایگزین می‌شوند:\n'
                      '{name} نام مشتری • {code} کد پرونده • {device} دستگاه • '
                      '{amount} مبلغ • {shop} نام مغازه • {shopPhone} تلفن مغازه',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    InfoRow(
                      label: 'رسید پذیرش',
                      value: s.get(SettingKeys.tplReceipt),
                      onTap: () => _editText(
                          s, SettingKeys.tplReceipt, 'پیامک رسید پذیرش',
                          multiline: true),
                    ),
                    InfoRow(
                      label: 'اعلام هزینه',
                      value: s.get(SettingKeys.tplApproval),
                      onTap: () => _editText(
                          s, SettingKeys.tplApproval, 'پیامک اعلام هزینه',
                          multiline: true),
                    ),
                    InfoRow(
                      label: 'یادآوری بدهی',
                      value: s.get(SettingKeys.tplDebt),
                      onTap: () => _editText(
                          s, SettingKeys.tplDebt, 'پیامک یادآوری بدهی',
                          multiline: true),
                    ),
                    InfoRow(
                      label: 'کمپین زمستان',
                      value: s.get(SettingKeys.tplWinter),
                      onTap: () => _editText(
                          s, SettingKeys.tplWinter, 'پیامک کمپین پیش از زمستان',
                          multiline: true),
                    ),
                    InfoRow(
                      label: 'کمپین تابستان',
                      value: s.get(SettingKeys.tplSummer),
                      onTap: () => _editText(
                          s, SettingKeys.tplSummer, 'پیامک کمپین پیش از تابستان',
                          multiline: true),
                    ),
                    InfoRow(
                      label: 'آماده‌ی تحویل',
                      value: s.get(SettingKeys.tplReady),
                      onTap: () => _editText(
                          s, SettingKeys.tplReady, 'پیامک آماده‌ی تحویل',
                          multiline: true),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ردیف رفتن به یک صفحه‌ی دیگر داخل کارت تنظیمات
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
