import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PanoramaPainter extends CustomPainter {
  const PanoramaPainter({
    required this.image,
    required this.yaw,
    required this.pitch,
    required this.vfov,
  });

  final ui.Image image;
  final double yaw;
  final double pitch;
  final double vfov;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final aspect = size.width / size.height;
    final horizontalFov = vfov * aspect;

    final srcW = math.min(imageWidth * horizontalFov / 360, imageWidth);
    final srcH = math.min(imageHeight * vfov / 180, imageHeight);

    final minCy = srcH / 2;
    final maxCy = imageHeight - srcH / 2;
    final cy = math.min(
      math.max(imageHeight / 2 - pitch / 180 * imageHeight, minCy),
      maxCy,
    );
    final top = cy - srcH / 2;

    final left = ((yaw / 360) * imageWidth - srcW / 2) % imageWidth;

    final paint = Paint()..filterQuality = FilterQuality.medium;

    if (left + srcW <= imageWidth) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(left, top, srcW, srcH),
        Offset.zero & size,
        paint,
      );
      return;
    }

    final widthBeforeWrap = imageWidth - left;
    final wrappedWidth = srcW - widthBeforeWrap;
    final firstPartWidth = size.width * widthBeforeWrap / srcW;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(left, top, widthBeforeWrap, srcH),
      Rect.fromLTWH(0, 0, firstPartWidth, size.height),
      paint,
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, top, wrappedWidth, srcH),
      Rect.fromLTWH(
        firstPartWidth,
        0,
        size.width - firstPartWidth,
        size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(PanoramaPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.vfov != vfov ||
        oldDelegate.image != image;
  }
}
