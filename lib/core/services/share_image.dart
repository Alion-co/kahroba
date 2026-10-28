import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// از ویجتی که داخل RepaintBoundary با کلید [key] است، تصویر PNG می‌سازد و
/// برگه‌ی اشتراک‌گذاری گوشی را باز می‌کند (واتس‌اپ، ایتا، تلگرام، برنامه‌ی
/// چاپگر بلوتوثی مثل RawBT و...). هیچ چیزی به سروری فرستاده نمی‌شود.
Future<void> shareWidgetAsImage(
  GlobalKey key, {
  required String fileName,
  double pixelRatio = 3,
  String? text,
}) async {
  // وب فایل موقت ندارد: تصویر مستقیم از حافظه به اشتراک گذاشته می‌شود
  if (kIsWeb) {
    final bytes = await _renderPng(key, pixelRatio);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'image/png', name: '$fileName.png'),
        ],
        text: text,
      ),
    );
    return;
  }
  final file = await saveWidgetAsImage(key,
      fileName: fileName, pixelRatio: pixelRatio);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path, mimeType: 'image/png')], text: text),
  );
}

Future<Uint8List> _renderPng(GlobalKey key, double pixelRatio) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

/// فقط ساخت فایل تصویر (در پوشه‌ی موقت) و برگرداندن آن.
Future<File> saveWidgetAsImage(
  GlobalKey key, {
  required String fileName,
  double pixelRatio = 3,
}) async {
  final bytes = await _renderPng(key, pixelRatio);
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, '$fileName.png'));
  await file.writeAsBytes(bytes, flush: true);
  return file;
}
