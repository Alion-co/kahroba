/// داده‌های پیش‌فرض که بار اول در پایگاه داده نوشته می‌شوند.
library;

/// دسته‌های پیش‌فرض: (نام، پیشوند کد، کلید آیکن).
/// پیشوند همان چیزی است که در کد دستگاه می‌آید، مثل BK-0037.
/// پیشوندها با فیلد `device` در بانک فنی (assets/kb/kb.json) هم یکی‌اند.
const defaultCategories = <(String, String, String)>[
  ('بخاری', 'BK', 'heater'),
  ('سماور', 'SM', 'samovar'),
  ('پکیج', 'PK', 'boiler'),
  ('آبگرمکن', 'AG', 'waterHeater'),
  ('کولر آبی', 'KA', 'cooler'),
  ('کولر گازی', 'KG', 'ac'),
  ('لباسشویی', 'LS', 'washer'),
  ('ظرفشویی', 'ZS', 'dishwasher'),
  ('یخچال و فریزر', 'YK', 'fridge'),
  ('جاروبرقی', 'JB', 'vacuum'),
  ('اتو', 'AT', 'iron'),
  ('مایکروویو و اجاق', 'MW', 'microwave'),
  ('تلویزیون', 'TV', 'tv'),
  ('ابزار برقی', 'AB', 'tool'),
  ('خشک‌کن', 'KS', 'dryer'),
  ('هود', 'HD', 'hood'),
  ('قهوه‌ساز و اسپرسوساز', 'QS', 'coffee'),
  ('هواپز و سرخ‌کن', 'HP', 'airfryer'),
  ('تصفیه‌ی هوا', 'TH', 'airPurifier'),
  ('تصفیه‌ی آب', 'TA', 'waterFilter'),
  ('آبسردکن', 'AS', 'waterCooler'),
  ('پلوپز و زودپز برقی', 'PZ', 'multicooker'),
  ('سایر', 'OT', 'other'),
];

/// کلیدهای تنظیمات.
abstract final class SettingKeys {
  static const shopName = 'shop_name';
  static const shopPhone = 'shop_phone';
  static const shopAddress = 'shop_address';
  static const shopTagline = 'shop_tagline';
  static const abandonDays = 'abandon_days';
  static const defaultWarrantyDays = 'default_warranty_days';
  static const tplReceipt = 'tpl_receipt';
  static const tplReady = 'tpl_ready';
  static const tplApproval = 'tpl_approval';
  static const tplDebt = 'tpl_debt';
  static const themeMode = 'theme_mode';
  static const liteMode = 'lite_mode';
  static const onboardingDone = 'onboarding_done';
  static const tplWinter = 'tpl_winter';
  static const tplSummer = 'tpl_summer';

  /// فهرست دستگاه‌هایی که پیامک کمپین فصلی برایشان فرستاده شده (JSON)
  static const campaignSent = 'campaign_sent';

  /// نام این گوشی در همگام‌سازی (مثلاً «گوشی اوستا» یا «گوشی همکار»)
  static const deviceName = 'device_name';

  /// کارت «شروع سریع» خانه بسته شده
  static const welcomeDismissed = 'welcome_dismissed';

  /// اثر رمز قفل برنامه (خالی یعنی قفل خاموش). خود رمز ذخیره نمی‌شود.
  /// این کلید نه همگام می‌شود و نه در پشتیبان می‌رود.
  static const lockPin = 'lock_pin';

  /// اعلان نوبت‌های کار در محل ('1' روشن)
  static const notifyJobs = 'notify_jobs';

  /// زمان آخرین پشتیبان‌گیری (ISO)
  static const lastBackupAt = 'last_backup_at';

  /// درخواست امتیاز مایکت: زمان اولین اجرا، وضعیت (done/never) و نوبت بعدی
  static const firstOpenAt = 'first_open_at';
  static const rateState = 'rate_state';
  static const rateNextAt = 'rate_next_at';
}

/// مقدار پیش‌فرض هر تنظیم. در الگوی پیامک‌ها این‌ها جایگزین می‌شوند:
/// {shop} نام مغازه، {shopPhone} تلفن مغازه، {name} نام مشتری،
/// {code} کد پرونده، {device} نام دستگاه، {amount} مبلغ (یا مانده در پیامک بدهی).
const settingDefaults = <String, String>{
  SettingKeys.shopName: 'تعمیرگاه من',
  SettingKeys.shopPhone: '',
  SettingKeys.shopAddress: '',
  SettingKeys.shopTagline: 'تخصص ما، اعتماد شما',
  SettingKeys.tplDebt:
      '{name} عزیز، مانده‌ی حساب پرونده‌ی {code} ({device}) مبلغ {amount} است. لطفاً برای تسویه اقدام کنید.\n{shop} {shopPhone}',
  SettingKeys.abandonDays: '30',
  SettingKeys.defaultWarrantyDays: '30',
  SettingKeys.themeMode: 'system',
  // پیش‌فرض: سبک (بدون محوسازی) تا روی همه‌ی گوشی‌ها روان باشد
  SettingKeys.liteMode: '1',
  SettingKeys.onboardingDone: '0',
  SettingKeys.tplWinter:
      '{name} عزیز، فصل سرما نزدیک است. برای سرویس و بازدید ایمنی {device} پیش از زمستان نوبت بگیرید.\n{shop} {shopPhone}',
  SettingKeys.tplSummer:
      '{name} عزیز، پیش از گرم شدن هوا {device} را سرویس کنید تا تابستان راحت باشد. برای نوبت تماس بگیرید.\n{shop} {shopPhone}',
  SettingKeys.campaignSent: '{}',
  SettingKeys.deviceName: '',
  SettingKeys.welcomeDismissed: '0',
  SettingKeys.lockPin: '',
  SettingKeys.notifyJobs: '1',
  SettingKeys.lastBackupAt: '',
  SettingKeys.tplReceipt:
      '{name} عزیز، {device} شما با کد پرونده {code} در {shop} پذیرش شد.\nلطفاً این کد را نگه دارید.',
  SettingKeys.tplReady:
      '{name} عزیز، {device} شما (پرونده {code}) آماده‌ی تحویل است.\n{shop} {shopPhone}',
  SettingKeys.tplApproval:
      '{name} عزیز، هزینه‌ی تعمیر {device} (پرونده {code}) حدود {amount} برآورد شد. برای تأیید لطفاً تماس بگیرید.\n{shop} {shopPhone}',
};

/// دسترسی راحت به تنظیمات با مقدار پیش‌فرض.
class ShopSettings {
  const ShopSettings(this.raw);
  final Map<String, String> raw;

  String get(String key) {
    final v = raw[key];
    return (v == null || v.isEmpty) ? (settingDefaults[key] ?? '') : v;
  }

  String get shopName => get(SettingKeys.shopName);
  String get shopPhone => raw[SettingKeys.shopPhone] ?? '';
  String get shopAddress => raw[SettingKeys.shopAddress] ?? '';
  String get shopTagline => get(SettingKeys.shopTagline);
  int get abandonDays => int.tryParse(get(SettingKeys.abandonDays)) ?? 30;
  int get defaultWarrantyDays =>
      int.tryParse(get(SettingKeys.defaultWarrantyDays)) ?? 30;

  /// system، light یا dark
  String get themeModeName => get(SettingKeys.themeMode);

  /// حالت سبک: محوسازی شیشه خاموش
  bool get liteMode => get(SettingKeys.liteMode) == '1';

  /// صفحه‌های معرفی یک بار دیده شده‌اند
  bool get onboardingDone => get(SettingKeys.onboardingDone) == '1';

  /// اثر رمز قفل؛ خالی یعنی قفل خاموش
  String get lockPin => raw[SettingKeys.lockPin] ?? '';
  bool get lockOn => lockPin.isNotEmpty;

  bool get notifyJobs => get(SettingKeys.notifyJobs) == '1';

  DateTime? get lastBackupAt =>
      DateTime.tryParse(raw[SettingKeys.lastBackupAt] ?? '');
}
