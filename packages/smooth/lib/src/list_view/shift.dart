import 'package:flutter/material.dart';
import 'package:smooth/src/binding.dart';

class SmoothShift extends StatefulWidget {
  final Widget child;

  const SmoothShift({super.key, required this.child});

  @override
  State<SmoothShift> createState() => _SmoothShiftState();
}

class _SmoothShiftState extends _SmoothShiftBase
    with _SmoothShiftFromPointerEvent {}

abstract class _SmoothShiftBase extends State<SmoothShift> {
  var offset = 0.0;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    // print('hi $runtimeType build offset=$offset');
    return Transform.translate(
      offset: Offset(0, offset),
      child: widget.child,
    );
  }
}

// try to use mixin to maximize performance
mixin _SmoothShiftFromPointerEvent on _SmoothShiftBase {
  var _hasPendingCallback = false;

  void _maybeSchedulePostMainTreeFlushLayoutCallback() {
    if (_hasPendingCallback) return;
    _hasPendingCallback = true;

    SmoothSchedulerBindingMixin.instance.addStartDrawFrameCallback(() {
      // print('hi $runtimeType addStartDrawFrameCallback.callback');

      _hasPendingCallback = false;

      if (offset == 0) return;
      setState(() => offset = 0);
    });
  }

  void _handlePointerMove(PointerMoveEvent e) {
    // print('hi $runtimeType _handlePointerMove embedderId=${e.embedderId} e=$e');
    setState(() {
      // very naive, and is WRONG!
      // just to confirm, we can (1) receive (2) display events
      offset += e.localDelta.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeSchedulePostMainTreeFlushLayoutCallback();

    return Listener(
      onPointerMove: _handlePointerMove,
      behavior: HitTestBehavior.translucent,
      child: super.build(context),
    );
  }
}
