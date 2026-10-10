import 'package:flutter/material.dart';

import 'giroscope_controller.dart';
import 'panorama_painter.dart';

class Giroscope extends StatefulWidget {
  const Giroscope({super.key});

  @override
  State<Giroscope> createState() => _GiroscopeState();
}

class _GiroscopeState extends State<Giroscope> {
  late final GiroscopeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GiroscopeController();
    _controller.loadImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        if (state.error != null) {
          return _buildErrorScreen(state.error!);
        }

        final image = _controller.image;
        return Scaffold(
          backgroundColor: Colors.black,
          body: image == null
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onPanUpdate: state.isGyroscopeEnabled
                      ? null
                      : (details) => _controller.handlePanUpdate(details.delta),
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: PanoramaPainter(
                        image: image,
                        yaw: state.yaw,
                        pitch: state.pitch,
                        vfov: state.vfov,
                      ),
                    ),
                  ),
                ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'reset',
                onPressed: _controller.resetView,
                child: const Icon(Icons.center_focus_strong),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                heroTag: 'giro',
                onPressed: _controller.toggleGyroscope,
                child: Icon(
                  state.isGyroscopeEnabled
                      ? Icons.touch_app
                      : Icons.screen_rotation,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No se pudo cargar la imagen:\n$message',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
