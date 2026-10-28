import 'package:flutter/material.dart';

import 'stored_image.dart';

/// نمایش تمام‌صفحه‌ی عکس با امکان بزرگ‌نمایی.
class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage({super.key, required this.path, this.title = ''});
  final String path;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(child: storedImage(path)),
      ),
    );
  }
}
