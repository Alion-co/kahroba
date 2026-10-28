"""فشرده کردن assets/kb/kb.json برای نسخه‌ی انتشار.

بعد از هر اسکریپت افزودن مورد به بانک فنی اجرا شود:
    python tools/kb_compact.py

- بدون فاصله و تورفتگی، و حروف فارسی بدون \\u (حجم کمتر، خواندن سریع‌تر)
- فیلدهای خالی و پیش‌فرض (verified=false، فهرست خالی، متن خالی) حذف می‌شوند؛
  برنامه برای فیلد نبوده همان مقدار پیش‌فرض را می‌گذارد.
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
PATH = os.path.join(HERE, "..", "assets", "kb", "kb.json")
KEEP = {"id", "type", "device"}

with open(PATH, encoding="utf-8") as f:
    data = json.load(f)
before = os.path.getsize(PATH)
data["entries"] = [
    {k: v for k, v in e.items() if k in KEEP or v not in ("", [], None, False)}
    for e in data["entries"]
]
with open(PATH, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
print(f"{before:,} -> {os.path.getsize(PATH):,} bytes")
