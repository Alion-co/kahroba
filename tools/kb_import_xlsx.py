# -*- coding: utf-8 -*-
"""وارد کردن بانک کدهای خطا از فایل اکسل کاربر به assets/kb/kb.json.

ورودی: برگه‌ی «بانک یکپارچه» با ستون‌های
  دسته | برند | سری/مدل | کد نمایشگر | معنی احتمالی | علت/توضیح |
  اقدام پیشنهادی | نوع | اطمینان | منبع بررسی

قواعد:
- موردهای فعلی kb.json (که مرحله‌به‌مرحله و دستی تکمیل شده‌اند) نگه داشته
  می‌شوند؛ ردیف اکسلی که همان برند + دستگاه + کد را دارد اضافه نمی‌شود.
- نام برندها یکسان می‌شود (مثلاً «Samsung»، «سامسونگ» و «سامسونگ (Samsung)»
  همه سامسونگ‌اند) و برندهای تازه به فهرست برندها اضافه می‌شوند.
- همه‌ی موردها verified=false هستند و منبع و میزان اطمینان‌شان ثبت می‌شود.

اجرا (نیازمند openpyxl):  python tools/kb_import_xlsx.py path/to/file.xlsx
"""
import json, os, re, sys
import openpyxl

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
KB = os.path.join(ROOT, "assets", "kb", "kb.json")

GAS = "پیش از هر کار شیر گاز و برق دستگاه را ببندید. دستکاری شیر گاز، مشعل و دودکش فقط کار تکنسین مجاز است. بعد از تعمیر همه‌ی اتصالات را با کف صابون نشت‌یابی کنید؛ هرگز با شعله."
ELEC = "همیشه با دوشاخه‌ی کشیده‌شده کار کنید."
AC = "پیش از باز کردن یونیت‌ها برق را قطع کنید و چند دقیقه صبر کنید تا خازن‌ها تخلیه شوند. شارژ گاز فقط با ابزار و آموزش مناسب."

# دسته‌ی اکسل ← پیشوند دسته در برنامه
CATEGORY = {
    "یخچال و فریزر": "YK",
    "لباسشویی": "LS",
    "کولر گازی": "KG",
    "پکیج و بویلر": "PK",
    "ظرفشویی": "ZS",
    "خشک‌کن": "KS",
    "فر": "MW",
    "هود": "HD",
    "اجاق القایی": "MW",
    "اسپرسوساز": "QS",
    "مایکروویو": "MW",
    "هواپز": "HP",
    "جاروبرقی": "JB",
    "آبگرمکن برقی": "AG",
    "تصفیه‌کننده هوا": "TH",
    "تصفیه‌کننده آب (RO)": "TA",
    "تلویزیون": "TV",
    "آبسردکن": "AS",
    "اجاق گاز": "MW",
}
GAS_CATEGORIES = {"پکیج و بویلر", "اجاق گاز"}

# برندهای تازه: شناسه ← (نام فارسی، نام لاتین، خاستگاه)
NEW_BRANDS = {
    "electrolux": ("الکترولوکس", "Electrolux", "foreign"),
    "aux": ("آکس", "AUX", "foreign"),
    "bwt": ("بی‌دبلیوتی", "BWT", "foreign"),
    "siemens": ("زیمنس", "Siemens", "foreign"),
    "candy": ("کندی / هوور", "Candy / Hoover", "foreign"),
    "fisherpaykel": ("فیشر اند پایکل", "Fisher & Paykel", "foreign"),
    "ge": ("جنرال الکتریک", "GE", "foreign"),
    "haier": ("هایر", "Haier", "foreign"),
    "hitachi": ("هیتاچی", "Hitachi", "foreign"),
    "indesit": ("زانوسی / ایندزیت / هات‌پوینت", "Zanussi / Indesit / Hotpoint", "foreign"),
    "liebherr": ("لیبهر", "Liebherr", "foreign"),
    "miele": ("میله", "Miele", "foreign"),
    "subzero": ("ساب‌زیرو", "Sub-Zero", "foreign"),
    "ariston": ("آریستون", "Ariston", "foreign"),
    "ogeneral": ("اوجنرال", "O'General", "foreign"),
    "immergas": ("ایمرگاز", "Immergas", "foreign"),
    "baxi": ("باکسی", "Baxi", "foreign"),
    "jura": ("جورا", "Jura", "foreign"),
    "daikin": ("دایکین", "Daikin", "foreign"),
    "rheem": ("ریم", "Rheem", "foreign"),
    "xiaomi": ("شیائومی", "Xiaomi", "foreign"),
    "ferroli": ("فرولی", "Ferroli", "foreign"),
    "fujitsu": ("فوجیتسو", "Fujitsu", "foreign"),
    "mitsubishi": ("میتسوبیشی", "Mitsubishi", "foreign"),
    "vaillant": ("وایلانت", "Vaillant", "foreign"),
    "westen": ("وستن", "Westen", "foreign"),
    "krups": ("کروپس", "Krups", "foreign"),
    "kent": ("کنت", "Kent", "foreign"),
    "kenwood": ("کنوود", "Kenwood", "foreign"),
    "cosori": ("کوزوری", "Cosori", "foreign"),
    "other": ("سایر برندها", "Other", "foreign"),
    # ایرانی
    "alzan": ("آلزان", "Alzan", "ir"),
    "aysan": ("آیسان", "Aysan", "ir"),
    "akhgar": ("اخگر", "Akhgar", "ir"),
    "elito": ("الیتو", "Elito", "ir"),
    "isatis": ("ایساتیس", "Isatis", "ir"),
    "barelli": ("بارلی", "Barelli", "ir"),
    "barfab": ("برفاب", "Barfab", "ir"),
    "best": ("بست", "Best", "ir"),
    "behi": ("بهی", "Behi", "ir"),
    "taban": ("تابان", "Taban", "ir"),
    "tachi": ("تاچی", "Tachi", "ir"),
    "tulips": ("تولیپس", "Tulips", "ir"),
    "general": ("جنرال", "General", "ir"),
    "donar": ("دونار", "Donar", "ir"),
    "depoint": ("دیپوینت", "Depoint", "ir"),
    "silvan": ("سیلوان", "Silvan", "ir"),
    "sinjer": ("سینجر", "Sinjer", "ir"),
    "sivan": ("سیوان", "Sivan", "ir"),
    "shahab": ("شهاب", "Shahab", "ir"),
    "mars": ("مارس", "Mars", "ir"),
    "magic": ("مجیک", "Magic", "ir"),
    "mercury": ("مرکوری / مگاترم", "Mercury / Megatherm", "ir"),
    "miguel": ("میگل", "Miguel", "ir"),
    "niksan": ("نیکسان", "Niksan", "ir"),
    "hardstone": ("هاردستون", "Hardstone", "ir"),
    "pars": ("پارس", "Pars", "ir"),
    "coral": ("کرال", "Coral", "ir"),
    "green": ("گرین", "Green", "ir"),
    "goldiran": ("گلدیران", "Goldiran", "ir"),
    "kavosh": ("کاوش صنعت و مونتاژی", "Kavosh", "ir"),
}

# نام برند در اکسل ← (شناسه، توضیح سری که به ستون سری اضافه می‌شود)
BRAND = {
    "AEG / Electrolux (رسمی)": ("electrolux", "AEG"),
    "Aux (آکس)": ("aux", ""),
    "BWT (bestaqua 14ROC)": ("bwt", "bestaqua 14ROC"),
    "Beko": ("beko", ""),
    "Bosch": ("bosch", ""),
    "Bosch (خانواده KGN/KGE)": ("bosch", "KGN / KGE"),
    "Bosch (خانواده KGN/KGE/KAI)": ("bosch", "KGN / KGE / KAI"),
    "Bosch (مدل‌های قدیمی‌تر WAE / WFF)": ("bosch", "مدل‌های قدیمی‌تر WAE / WFF"),
    "Bosch (مدل‌های قدیمی‌تر آنالوگ)": ("bosch", "مدل‌های قدیمی‌تر آنالوگ"),
    "Bosch / Siemens": ("bosch", "بوش و زیمنس"),
    "Bosch / Siemens (برخی سری‌ها)": ("bosch", "بوش و زیمنس، برخی سری‌ها"),
    "Bosch / Worcester Greenstar & Condens": ("bosch", "Worcester Greenstar / Condens"),
    "Bosch Climate": ("bosch", "Climate"),
    "Bosch Climate 3000 / 5000 / 6000": ("bosch", "Climate 3000 / 5000 / 6000"),
    "Bosch GAZ 6000 / 7000 / Condens 2000/3000 (بازار ایران)": ("bosch", "GAZ 6000 / 7000 / Condens 2000/3000"),
    "Bosch SMS / SMV": ("bosch", "SMS / SMV"),
    "Bosch SMS / SMV / SMI / SB (Serie 2-8)": ("bosch", "SMS / SMV / SMI / SB"),
    "Bosch Serie 4 / 6 / 8": ("bosch", "Serie 4 / 6 / 8"),
    "Bosch Serie 4 / 6 / 8 (WAW / WAT / WGB / WGG)": ("bosch", "Serie 4 / 6 / 8"),
    "Candy / Hoover": ("candy", ""),
    "Daewoo": ("daewoo", ""),
    "Electrolux / Frigidaire / AEG (مدل‌محور)": ("electrolux", "Frigidaire / AEG"),
    "Fisher & Paykel": ("fisherpaykel", ""),
    "GE / Café / Monogram (مدل‌محور)": ("ge", "Café / Monogram"),
    "Gree": ("gree", ""),
    "Haier": ("haier", ""),
    "Haier / Hisense": ("haier", "هایر و هایسنس"),
    "Hisense": ("hisense", ""),
    "Hitachi": ("hitachi", ""),
    "Hoover / Candy (خانواده‌ی Haier)": ("candy", ""),
    "Hotpoint / Indesit / Zanussi / Smeg / Gorenje": ("indesit", "Smeg / Gorenje"),
    "LG": ("lg", ""),
    "Liebherr": ("liebherr", ""),
    "Midea": ("midea", ""),
    "Miele": ("miele", ""),
    "Panasonic": ("panasonic", ""),
    "RO پمپ‌دار (عمومی؛ مدل‌های مختلف)": ("other", "دستگاه‌های RO پمپ‌دار"),
    "Samsung": ("samsung", ""),
    "Sharp": ("sharp", ""),
    "Sub-Zero": ("subzero", ""),
    "TCL": ("tcl", ""),
    "Toshiba": ("toshiba", ""),
    "Whirlpool / KitchenAid / Maytag / Amana": ("whirlpool", "KitchenAid / Maytag / Amana"),
    "Zanussi / Indesit / Hotpoint": ("indesit", ""),
    "آاگ / الکترولوکس": ("electrolux", "AEG"),
    "آریستون (Ariston)": ("ariston", ""),
    "آلزان (Alzan)": ("alzan", ""),
    "آیسان (Aysan)": ("aysan", ""),
    "ابسال (Absal)": ("absal", ""),
    "اخگر (Akhgar)": ("akhgar", ""),
    "اسنوا (Snowa)": ("snowa", ""),
    "الکترواستیل (Electrosteel)": ("electrosteel", ""),
    "الکترواستیل / پلادیوم": ("electrosteel", "پلادیوم"),
    "الکترولوکس (Electrolux)": ("electrolux", ""),
    "الیتو (Elito)": ("elito", ""),
    "ال‌جی (LG)": ("lg", ""),
    "امرسان (Emersan)": ("emersun", ""),
    "اوجنرال (OGeneral)": ("ogeneral", ""),
    "ایران رادیاتور (Iran Radiator)": ("iranradiator", ""),
    "ایساتیس (Isatis)": ("isatis", ""),
    "ایمرگاز (Immergas)": ("immergas", ""),
    "ایکس ویژن (X.Vision)": ("xvision", ""),
    "ایکس‌ویژن (X.Vision)": ("xvision", ""),
    "بارلی (Barrelli)": ("barelli", ""),
    "باکسی (Baxi)": ("baxi", ""),
    "برفاب (Barfab)": ("barfab", ""),
    "بست (Best / Bost)": ("best", ""),
    "بهی (Behi)": ("behi", ""),
    "بوتان (Butane)": ("butane", ""),
    "بوش": ("bosch", ""),
    "بوش (Bosch)": ("bosch", ""),
    "بوش (Bosch) / Worcester": ("bosch", "Worcester"),
    "بوش / زیمنس": ("bosch", "بوش و زیمنس"),
    "بکو (Beko)": ("beko", ""),
    "تابان": ("taban", ""),
    "تاچی (Tachi)": ("tachi", ""),
    "توشیبا (Toshiba)": ("toshiba", ""),
    "تولیپس (Tulips)": ("tulips", ""),
    "جنرال (General)": ("general", ""),
    "جورا (Jura)": ("jura", ""),
    "جی‌پلاس (Gplus)": ("gplus", ""),
    "دایکین (Daikin)": ("daikin", ""),
    "دلونگی (DeLonghi)": ("delonghi", ""),
    "دونار (Donar)": ("donar", ""),
    "دوو (Daewoo)": ("daewoo", ""),
    "دیپوینت (Depoint)": ("depoint", ""),
    "رِیم (Rheem)": ("rheem", ""),
    "زانتی (Zaneti)": ("zaneti", ""),
    "سامسونگ": ("samsung", ""),
    "سامسونگ (Samsung)": ("samsung", ""),
    "سیلوان (Silvan)": ("silvan", ""),
    "سیمنس (Siemens)": ("siemens", ""),
    "سینجر (Sinjer)": ("sinjer", ""),
    "سیوان (Sivan)": ("sivan", ""),
    "شارپ (Sharp)": ("sharp", ""),
    "شهاب (Shahab)": ("shahab", ""),
    "شیائومی (Mi Robot Vacuum)": ("xiaomi", "Mi Robot Vacuum"),
    "شیائومی (Xiaomi)": ("xiaomi", ""),
    "عمومی (اکثر برندها)": ("other", "اکثر برندها"),
    "فرولی (Ferroli)": ("ferroli", ""),
    "فریجیدر (Frigidaire)": ("electrolux", "Frigidaire"),
    "فوجیتسو (Fujitsu)": ("fujitsu", ""),
    "فیلیپس": ("philips", ""),
    "فیلیپس (Philips)": ("philips", ""),
    "فیلیپس / سائکو": ("philips", "Saeco"),
    "لورچ (Lorch)": ("lorch", ""),
    "مارس (Mars)": ("mars", ""),
    "مجیک (Magic)": ("magic", ""),
    "مرکوری / مگاترم": ("mercury", ""),
    "مرکوری / مگاترم (Mercury / Megatherm)": ("mercury", ""),
    "میتسوبیشی (Mitsubishi)": ("mitsubishi", ""),
    "میدیا (Midea)": ("midea", ""),
    "میگل (Miguel)": ("miguel", ""),
    "می‌تگ (Maytag)": ("whirlpool", "Maytag"),
    "نیکسان (Niksan)": ("niksan", ""),
    "هاردستون (Hardstone)": ("hardstone", ""),
    "هایر (Haier)": ("haier", ""),
    "هایسنس (Hisense)": ("hisense", ""),
    "هیمالیا (Himalia)": ("himalia", ""),
    "وایلانت (Vaillant)": ("vaillant", ""),
    "وست پوینت (Westpoint)": ("westpoint", ""),
    "وستن (Westen)": ("westen", ""),
    "وستن (Westen) / یادداشت": ("westen", ""),
    "ویرپول (Whirlpool)": ("whirlpool", ""),
    "پارس (Pars)": ("pars", ""),
    "پارس / پارس‌خزر": ("pars", "پارس و پارس‌خزر"),
    "پارس خزر (Pars Khazar)": ("parskhazar", ""),
    "پاناسونیک": ("panasonic", ""),
    "پاکشوما (Pakshoma)": ("pakshoma", ""),
    "پلار (Polar)": ("polar", ""),
    "کاوش صنعت / برندهای مونتاژی ایرانی": ("kavosh", ""),
    "کرال (Coral)": ("coral", ""),
    "کروپس (Krups)": ("krups", ""),
    "کنت (Kent)": ("kent", ""),
    "کنوود (Kenwood)": ("kenwood", ""),
    "کوزوری (Cosori)": ("cosori", ""),
    "گرین (Green)": ("green", ""),
    "گلدیران (Goldiran)": ("goldiran", ""),
}

def _k(s):
    """کلید مقایسه بدون نیم‌فاصله و فاصله"""
    return s.replace("\u200c", "").replace(" ", "")


CATEGORY_N = {_k(k): v for k, v in CATEGORY.items()}
BRAND_N = {_k(k): v for k, v in BRAND.items()}
GAS_CATEGORIES_N = {_k(k) for k in GAS_CATEGORIES}

CONFIDENCE = {"بالا": "high", "متوسط": "medium", "پایین": "low"}
SKIP_TYPES = {"یادداشت"}

FA_DIGITS = str.maketrans("۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩", "01234567890123456789")


def norm_code(c):
    return re.sub(r"[\s\-_./–]", "", c.translate(FA_DIGITS)).upper()


def split_codes(raw):
    """«E1 / E2 / E4 (برخی مدل‌ها)» ← (['E1','E2','E4'], 'برخی مدل‌ها')"""
    raw = raw.strip()
    note = ""
    m = re.search(r"\(([^()]*)\)\s*$", raw)
    if m:
        note = m.group(1).strip()
        raw = raw[: m.start()].strip()
    raw = re.sub(r"^وین‌کولر:\s*", "", raw)
    parts = [p.strip() for p in re.split(r"\s*/\s*|\s*،\s*|\s*,\s*", raw) if p.strip()]
    return parts or [raw], note


def split_steps(text):
    text = (text or "").strip()
    if not text or text in ("—", "-"):
        return []
    parts = [p.strip(" .") for p in re.split(r"[؛;]\s*", text) if p.strip(" .")]
    return [p if p.endswith(".") else p + "." for p in parts]


def source_fields(src):
    src = (src or "").strip()
    if src.startswith("http"):
        return src, ""
    if re.fullmatch(r"[a-z0-9.-]+\.[a-z]{2,}", src):
        return "https://" + src, ""
    return "", src


def main(xlsx):
    with open(KB, encoding="utf-8") as f:
        kb = json.load(f)

    brands = {b["id"]: b for b in kb["brands"]}
    for bid, (fa, en, origin) in NEW_BRANDS.items():
        if bid not in brands:
            b = dict(id=bid, fa=fa, en=en, origin=origin)
            kb["brands"].append(b)
            brands[bid] = b

    # کلید موردهای موجود: برند + دستگاه + هر کد/کد مشابه
    have = set()
    for e in kb["entries"]:
        if e["type"] != "code":
            continue
        for c in [e["code"], *e.get("aliases", [])]:
            have.add((e["brandId"], e["device"], norm_code(c)))
    seen = set()  # تکراری‌های داخل خود اکسل

    wb = openpyxl.load_workbook(xlsx, read_only=True, data_only=True)
    ws = wb["بانک یکپارچه"]
    rows = list(ws.iter_rows(values_only=True))[1:]

    added = skipped_dup = skipped_other = 0
    unknown = set()
    counters = {}
    for r in rows:
        cat, brand_raw, series, code_raw, title, cause, action, kind, conf, src = (
            [("" if v is None else str(v).strip()) for v in r] + [""] * 10)[:10]
        if not code_raw or not title or kind in SKIP_TYPES:
            skipped_other += 1
            continue
        prefix = CATEGORY_N.get(_k(cat))
        brand = BRAND_N.get(_k(brand_raw))
        if prefix is None or brand is None:
            unknown.add((cat, brand_raw))
            skipped_other += 1
            continue
        bid, hint = brand
        codes, note = split_codes(code_raw)
        primary, aliases = codes[0], codes[1:]
        key = (bid, prefix, norm_code(primary))
        if key in have or any((bid, prefix, norm_code(a)) in have for a in aliases):
            skipped_dup += 1
            continue
        # در خود اکسل، یک کد با معنی متفاوت (سری دیگر) نگه داشته می‌شود
        dedupe = (bid, prefix, norm_code(primary), re.sub(r"[\s\u200c.،:]", "", title))
        if dedupe in seen:
            skipped_dup += 1
            continue
        seen.add(dedupe)

        series_parts = [s for s in (hint, series, note) if s]
        url, label = source_fields(src)
        n = counters[(bid, prefix)] = counters.get((bid, prefix), 0) + 1
        entry = dict(
            id=f"x-{bid}-{prefix.lower()}-{n:03d}",
            type="code",
            device=prefix,
            brandId=bid,
            brand=brands[bid]["fa"],
            code=primary,
            aliases=aliases,
            title=title,
            meaning=cause,
            causes=[],
            steps=split_steps(action),
            parts=[],
            safety=GAS if _k(cat) in GAS_CATEGORIES_N else AC if prefix == "KG" else ELEC,
            verified=False,
            series=" — ".join(series_parts),
            confidence=CONFIDENCE.get(conf, ""),
        )
        if url:
            entry["source"] = url
        else:
            entry["sourceLabel"] = label or "فایل گردآوری کاربر"
        kb["entries"].append(entry)
        added += 1

    kb["version"] = kb.get("version", 1) + 1
    with open(KB, "w", encoding="utf-8") as f:
        json.dump(kb, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print(f"added {added}, duplicates skipped {skipped_dup}, other skipped {skipped_other}")
    print(f"total entries {len(kb['entries'])}, brands {len(kb['brands'])}")
    if unknown:
        print("UNKNOWN:", sorted(unknown))


if __name__ == "__main__":
    main(sys.argv[1])
