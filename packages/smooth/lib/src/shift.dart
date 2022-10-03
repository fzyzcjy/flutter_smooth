import 'package:flutter/material.dart';
import 'package:smooth/src/binding.dart';

class SmoothShift extends StatefulWidget {
  final Widget child;

  const SmoothShift({super.key, required this.child});

  @override
  State<SmoothShift> createState() => _SmoothShiftState();
}

class _SmoothShiftState extends State<SmoothShift> {
  var _offset = 0.0;

  var _hasPendingCallback = false;

  void _maybeSchedulePostMainTreeFlushLayoutCallback() {
    if (_hasPendingCallback) return;
    _hasPendingCallback = true;

    SmoothSchedulerBindingMixin.instance.addStartDrawFrameCallback(() {
      print('hi $runtimeType addStartDrawFrameCallback.callback');

      _hasPendingCallback = false;

      if (_offset == 0) return;
      setState(() => _offset = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('hi $runtimeType build offset=$_offset');

    _maybeSchedulePostMainTreeFlushLayoutCallback();

    return Listener(
      onPointerMove: _handlePointerMove,
      behavior: HitTestBehavior.translucent,
      child: Transform.translate(
        offset: Offset(0, _offset),
        child: widget.child,
      ),
    );
  }

  void _handlePointerMove(PointerMoveEvent e) {
    print('hi $runtimeType _handlePointerMove e=$e');
    setState(() {
      // very naive, and is WRONG!
      // just to confirm, we can (1) receive (2) display events
      _offset += e.localDelta.dy;
    });
  }
}
