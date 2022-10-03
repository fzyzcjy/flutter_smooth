import 'package:flutter/material.dart';
import 'package:smooth/src/binding.dart';

class SmoothShift extends StatefulWidget {
  final Widget child;

  const SmoothShift({super.key, required this.child});

  @override
  State<SmoothShift> createState() => _SmoothShiftState();
}

class _SmoothShiftState extends State<SmoothShift> {
  var offset = 0.0;

  @override
  Widget build(BuildContext context) {
    print('hi $runtimeType build offset=$offset');

    // TODO should we put it in `build`?
    SmoothSchedulerBindingMixin.instance.addPostMainTreeFlushLayoutCallback(() {
      print('hi $runtimeType addPostMainTreeFlushLayoutCallback.callback');
      if (offset == 0) return;
      setState(() => offset = 0);
    });

    return Listener(
      onPointerMove: _handlePointerMove,
      behavior: HitTestBehavior.translucent,
      child: Transform.translate(
        offset: Offset(0, offset),
        child: widget.child,
      ),
    );
  }

  void _handlePointerMove(PointerMoveEvent e) {
    print('hi $runtimeType _handlePointerMove e=$e');
    setState(() {
      // very naive, and is WRONG!
      // just to confirm, we can (1) receive (2) display events
      offset += e.localDelta.dy;
    });
  }
}
