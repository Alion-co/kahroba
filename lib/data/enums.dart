/// وضعیت پرونده‌ی تعمیر.
/// با اسم ذخیره می‌شود (textEnum)، پس می‌شود وضعیت جدید اضافه کرد یا ترتیب را
/// عوض کرد بدون اینکه پرونده‌های قبلی خراب شوند. فقط اسم‌ها را عوض نکنید.
enum CaseStatus {
  received('پذیرش شده'),
  diagnosing('در حال عیب‌یابی'),
  awaitingApproval('منتظر تأیید قیمت'),
  waitingParts('منتظر قطعه'),
  repairing('در حال تعمیر'),
  ready('آماده‌ی تحویل'),
  delivered('تحویل داده شد'),
  unrepairable('مرجوعی / تعمیرنشدنی'),
  warrantyReturn('برگشتی در گارانتی');

  const CaseStatus(this.label);
  final String label;

  /// پرونده هنوز در جریان است و دستگاه دست تعمیرکار است.
  bool get isOpen => this != delivered && this != unrepairable;
}

/// محل انجام کار.
enum JobType {
  shop('در مغازه'),
  onSite('در محل مشتری');

  const JobType(this.label);
  final String label;
}

/// نوع عکس پرونده. امضای مشتری هم به‌صورت تصویر کنار عکس‌ها نگه داشته
/// می‌شود (بدون تغییر جدول پایگاه داده).
enum PhotoKind {
  before('قبل از تعمیر'),
  after('بعد از تعمیر'),
  signatureIn('امضای پذیرش'),
  signatureOut('امضای تحویل');

  const PhotoKind(this.label);
  final String label;

  bool get isSignature => this == signatureIn || this == signatureOut;
}
