import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class PanoramaImageLoader {
  const PanoramaImageLoader();

  Future<ui.Image> loadFromAsset(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
