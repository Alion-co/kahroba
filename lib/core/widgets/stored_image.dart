import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// نمایش عکس ذخیره‌شده‌ی برنامه.
/// - روی گوشی: [path] مسیر فایل در پوشه‌ی خصوصی برنامه است.
/// - روی وب: فایل نداریم، پس عکس به‌صورت `data:image/...;base64,...`
///   داخل پایگاه داده نگه داشته می‌شود (ر.ک. PhotoStore).
Widget storedImage(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  if (path.startsWith('data:')) {
    return Image.memory(
      _decode(path),
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: errorBuilder,
    );
  }
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}

// حافظه‌ی کوچک تا هر بار ساخت صفحه، عکس دوباره رمزگشایی نشود.
final _cache = <String, Uint8List>{};

Uint8List _decode(String dataUri) {
  final hit = _cache.remove(dataUri);
  if (hit != null) return _cache[dataUri] = hit;
  final bytes = base64Decode(dataUri.substring(dataUri.indexOf(',') + 1));
  _cache[dataUri] = bytes;
  if (_cache.length > 24) _cache.remove(_cache.keys.first);
  return bytes;
}
