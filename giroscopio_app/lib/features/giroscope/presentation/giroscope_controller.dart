import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/panorama_image_loader.dart';
import '../domain/giroscope_view_state.dart';

class GiroscopeController {
  GiroscopeController({PanoramaImageLoader? imageLoader})
    : _imageLoader = imageLoader ?? const PanoramaImageLoader();

  final PanoramaImageLoader _imageLoader;
  final ValueNotifier<GiroscopeViewState> state = ValueNotifier(
    const GiroscopeViewState(),
  );

  ui.Image? image;
  StreamSubscription<GyroscopeEvent>? _subscription;
  final Stopwatch _clock = Stopwatch();
  int _lastTimestampMicroseconds = 0;

  Future<void> loadImage() async {
    try {
      final imageLoaded = await _imageLoader.loadFromAsset('assets/image.jpg');
      image = imageLoaded;
      state.value = state.value.copyWith(error: null);
    } catch (error) {
      state.value = state.value.copyWith(error: error.toString());
      debugPrint('Error cargando imagen: $error');
    }
  }

  void toggleGyroscope() {
    final nextEnabled = !state.value.isGyroscopeEnabled;

    if (nextEnabled) {
      _clock
        ..reset()
        ..start();
      _lastTimestampMicroseconds = 0;
      _subscription = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(_handleGyroscopeEvent);
    } else {
      _subscription?.cancel();
      _subscription = null;
      _clock.stop();
    }

    state.value = state.value.copyWith(isGyroscopeEnabled: nextEnabled);
  }

  void handlePanUpdate(Offset delta) {
    if (state.value.isGyroscopeEnabled) {
      return;
    }

    final nextYaw = (state.value.yaw - delta.dx * 0.2) % 360;
    final nextPitch = (state.value.pitch + delta.dy * 0.2)
        .clamp(-85.0, 85.0)
        .toDouble();

    state.value = state.value.copyWith(yaw: nextYaw, pitch: nextPitch);
  }

  void resetView() {
    state.value = state.value.copyWith(yaw: 0, pitch: 0);
  }

  void dispose() {
    _subscription?.cancel();
    _clock.stop();
    state.dispose();
  }

  void _handleGyroscopeEvent(GyroscopeEvent event) {
    final nowMicros = _clock.elapsedMicroseconds;
    final dt = (nowMicros - _lastTimestampMicroseconds) / 1e6;
    _lastTimestampMicroseconds = nowMicros;

    if (dt <= 0 || dt > 0.2) {
      return;
    }

    const deadZone = 0.02;
    final gyroscopeY = event.y.abs() < deadZone ? 0.0 : event.y;
    final gyroscopeX = event.x.abs() < deadZone ? 0.0 : event.x;
    final degreesPerRadian = 180 / math.pi;

    final nextYaw =
        (state.value.yaw - gyroscopeY * dt * degreesPerRadian) % 360;
    final nextPitch = (state.value.pitch + gyroscopeX * dt * degreesPerRadian)
        .clamp(-85.0, 85.0)
        .toDouble();

    state.value = state.value.copyWith(yaw: nextYaw, pitch: nextPitch);
  }
}
