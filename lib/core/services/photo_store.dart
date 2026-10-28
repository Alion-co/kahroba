import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// گرفتن عکس و نگهداری آن داخل پوشه‌ی خصوصی برنامه.
/// عکس‌ها فشرده می‌شوند تا حافظه‌ی گوشی پر نشود.
abstract final class PhotoStore {
  static final _picker = ImagePicker();

  /// عکس می‌گیرد (یا از گالری انتخاب می‌کند) و مسیر نسخه‌ی ذخیره‌شده را
  /// برمی‌گرداند. اگر کاربر منصرف شود null برمی‌گرداند.
  static Future<String?> capture({bool fromGallery = false}) async {
    final picked = await _picker.pickImage(
      source: fromGallery ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 70,
    );
    if (picked == null) return null;

    // وب پوشه‌ی فایل ندارد: عکس به‌صورت data URI در پایگاه داده می‌ماند
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    }

    final dir = await photosDir();
    final ext = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final target =
        p.join(dir.path, '${DateTime.now().microsecondsSinceEpoch}$ext');
    await File(picked.path).copy(target);
    return target;
  }

  /// ذخیره‌ی تصویری که خود برنامه ساخته (مثل امضا). مسیر یا data URI.
  static Future<String> saveBytes(Uint8List bytes, {String ext = '.png'}) async {
    if (kIsWeb) {
      return 'data:image/png;base64,${base64Encode(bytes)}';
    }
    final dir = await photosDir();
    final target =
        p.join(dir.path, '${DateTime.now().microsecondsSinceEpoch}$ext');
    await File(target).writeAsBytes(bytes, flush: true);
    return target;
  }

  static Future<void> delete(String path) async {
    if (kIsWeb || path.startsWith('data:')) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // پاک نشدن یک عکس نباید برنامه را متوقف کند.
    }
  }

  /// پوشه‌ی عکس‌های برنامه (همگام‌سازی هم عکس‌ها را همین‌جا می‌گذارد)
  static Future<Directory> photosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'photos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
