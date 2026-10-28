"""ساخت همه‌ی آیکن‌های کهربا از tools/icon/icon_source.png

منبع: تصویر مربعی آیکن (کاشی تیره با قاب و نشان K کهربایی درخشان).
قاب درخشان و فضای سیاه دور کاشی در اندازه‌های کوچک حاشیه‌ی شلوغ و نامرتب
می‌سازند؛ پس فقط درون کاشی (حلقه و K) برداشته می‌شود، لبه‌اش نرم در زمینه‌ی
تیره‌ی یکدست محو می‌شود و یک کاشی تمیز با گوشه‌های گرد ساخته می‌شود.
طرح خود نشان دستکاری نمی‌شود.

خروجی‌ها:
- آیکن تطبیقی اندروید ۸+ (لایه‌ی جلو + رنگ زمینه)
- آیکن قدیمی اندروید، آیکن ۵۱۲ فروشگاه، آیکن‌های وب و favicon
- assets/brand/logo_dark.png برای داخل برنامه
"""
import os
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")

# رنگ درون کاشی (زمینه‌ی همه‌ی آیکن‌ها)
FILL = (20, 19, 21)
# مرکز و نیم‌عرض درون کاشی در تصویر منبع ۱۲۵۴ پیکسلی
CX, CY, HALF = 628, 603, 440
PAD = 0.08        # فاصله‌ی دور نشان
RADIUS = 0.23     # گردی گوشه‌ی کاشی

src = Image.open(os.path.join(HERE, "icon_source.png")).convert("RGBA")
k = src.width / 1254
inner = src.crop((int((CX - HALF) * k), int((CY - HALF) * k),
                  int((CX + HALF) * k), int((CY + HALF) * k)))
n = inner.width
f = int(n * 0.07)
fade = Image.new("L", (n, n), 0)
ImageDraw.Draw(fade).rounded_rectangle((f, f, n - f, n - f), radius=int(n * 0.3), fill=255)
inner.putalpha(fade.filter(ImageFilter.GaussianBlur(f / 2)))

S = int(n * (1 + 2 * PAD))
square = Image.new("RGBA", (S, S), FILL + (255,))   # کاشی مربعی مات
square.alpha_composite(inner, ((S - n) // 2, (S - n) // 2))


def sq(px, scale=1.0):
    """مربع مات؛ با scale<1 دور نشان فضای بیشتری می‌ماند"""
    canvas = Image.new("RGBA", (px, px), FILL + (255,))
    t = int(px * scale)
    canvas.alpha_composite(square.resize((t, t), Image.LANCZOS),
                           ((px - t) // 2, (px - t) // 2))
    return canvas


def tile(px):
    """کاشی با گوشه‌های گرد و بیرون شفاف"""
    big = square.resize((px * 4, px * 4), Image.LANCZOS)
    m = Image.new("L", big.size, 0)
    ImageDraw.Draw(m).rounded_rectangle(
        (0, 0, big.width - 1, big.height - 1), radius=int(big.width * RADIUS), fill=255)
    big.putalpha(m)
    return big.resize((px, px), Image.LANCZOS)


densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
for name, d in densities.items():
    out = os.path.join(RES, f"mipmap-{name}")
    os.makedirs(out, exist_ok=True)
    # تطبیقی: ناحیه‌ی دید ۷۲ از ۱۰۸dp؛ نشان با ۰٫۷۲ کامل و با فاصله دیده می‌شود
    sq(int(108 * d), 0.72).save(os.path.join(out, "ic_launcher_foreground.png"))
    tile(int(48 * d)).save(os.path.join(out, "ic_launcher.png"))

os.makedirs(os.path.join(RES, "mipmap-anydpi-v26"), exist_ok=True)
with open(os.path.join(RES, "mipmap-anydpi-v26", "ic_launcher.xml"), "w") as fh:
    fh.write('<?xml version="1.0" encoding="utf-8"?>\n'
             '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
             '    <background android:drawable="@color/ic_launcher_background"/>\n'
             '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
             '</adaptive-icon>\n')
os.makedirs(os.path.join(RES, "values"), exist_ok=True)
with open(os.path.join(RES, "values", "ic_launcher_background.xml"), "w") as fh:
    fh.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
             '    <color name="ic_launcher_background">#%02X%02X%02X</color>\n</resources>\n' % FILL)

store = os.path.join(ROOT, "assets", "store")
os.makedirs(store, exist_ok=True)
sq(512).convert("RGB").save(os.path.join(store, "icon_512.png"))

web = os.path.join(ROOT, "web")
os.makedirs(os.path.join(web, "icons"), exist_ok=True)
tile(32).save(os.path.join(web, "favicon.png"))
tile(192).save(os.path.join(web, "icons", "Icon-192.png"))
tile(512).save(os.path.join(web, "icons", "Icon-512.png"))
# maskable: ناحیه‌ی امن دایره‌ای ۸۰٪
sq(192, 0.9).convert("RGB").save(os.path.join(web, "icons", "Icon-maskable-192.png"))
sq(512, 0.9).convert("RGB").save(os.path.join(web, "icons", "Icon-maskable-512.png"))
sq(180).convert("RGB").save(os.path.join(web, "icons", "apple-touch-icon.png"))

brand = os.path.join(ROOT, "assets", "brand")
os.makedirs(brand, exist_ok=True)
tile(432).save(os.path.join(brand, "logo_dark.png"))  # اسپلش تا ۱۴۴dp در ۳x
print("done")
