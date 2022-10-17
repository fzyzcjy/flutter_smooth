import 'package:flutter/material.dart';
import 'package:smooth/src/infra/service_locator.dart';

class SmoothParent extends StatefulWidget {
  final Widget child;

  const SmoothParent({super.key, required this.child});

  @override
  State<SmoothParent> createState() => _SmoothParentState();

  static bool get active {
    assert(_activeCount >= 0);
    return _activeCount > 0;
  }

  static var _activeCount = 0;
}

class _SmoothParentState extends State<SmoothParent> {
  @override
  void initState() {
    super.initState();
    SmoothParent._activeCount++;
  }

  @override
  void dispose() {
    SmoothParent._activeCount--;
    super.dispose();
  }

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
      child: widget.child,
    );
  }

  void _handlePointer(PointerEvent e) =>
      ServiceLocator.instance.extraEventDispatcher
          .handleMainTreePointerEvent(e);
}
