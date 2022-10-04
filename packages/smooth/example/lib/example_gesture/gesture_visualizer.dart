import 'package:flutter/material.dart';

// TODO test more: by GestureDetector, etc
class GestureVisualizerByListener extends StatefulWidget {
  final Widget child;

  const GestureVisualizerByListener({super.key, required this.child});

  @override
  State<GestureVisualizerByListener> createState() =>
      _GestureVisualizerByListenerState();
}

class _GestureVisualizerByListenerState
    extends State<GestureVisualizerByListener> {
  Offset? position;

  void _updatePosition(Offset? value) {
    // print('_GestureVisualizerByListenerState position=$value');
    setState(() => position = value);
  }

  static const size = 48.0;

  @override
  Widget build(BuildContext context) {
    final position = this.position;

    return Listener(
      onPointerDown: (d) => _updatePosition(d.localPosition),
      onPointerMove: (d) => _updatePosition(d.localPosition),
      onPointerUp: (d) => _updatePosition(null),
      onPointerCancel: (d) => _updatePosition(null),
      child: Stack(
        children: [
          widget.child,
          if (position != null)
            Positioned(
              left: position.dx - size / 2,
              top: position.dy - size / 2,
              child: IgnorePointer(
                child: Container(
                  width: size,
                  height: size,
                  color: Colors.orange.withAlpha(150),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
