import 'package:flutter/material.dart';
import 'package:smooth/src/service_locator.dart';

class SmoothParent extends StatelessWidget {
  final Widget child;

  const SmoothParent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointer,
      onPointerMove: _handlePointer,
      onPointerUp: _handlePointer,
      onPointerHover: _handlePointer,
      onPointerCancel: _handlePointer,
      onPointerPanZoomStart: _handlePointer,
      onPointerPanZoomUpdate: _handlePointer,
      onPointerPanZoomEnd: _handlePointer,
      onPointerSignal: _handlePointer,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }

  void _handlePointer(PointerEvent e) =>
      ServiceLocator.instance.extraEventDispatcher
          .handleMainTreePointerEvent(e);
}
