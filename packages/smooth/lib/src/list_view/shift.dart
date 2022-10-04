import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth/src/list_view/controller.dart';

class SmoothShift extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  const SmoothShift({
    super.key,
    required this.scrollController,
    required this.child,
  });

  @override
  State<SmoothShift> createState() => _SmoothShiftState();
}

class _SmoothShiftState = _SmoothShiftBase
    with _SmoothShiftFromPointerEvent, _SmoothShiftFromBallistic;

abstract class _SmoothShiftBase extends State<SmoothShift>
    with TickerProviderStateMixin {
  double get offset => 0;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    print('hi $runtimeType build offset=$offset');

    return Transform.translate(
      offset: Offset(0, offset),
      transformHitTests: false,
      child: widget.child,
    );
  }
}

// try to use mixin to maximize performance
mixin _SmoothShiftFromPointerEvent on _SmoothShiftBase {
  var _offsetFromPointerEvent = 0.0;
  var _hasPendingCallback = false;

  @override
  double get offset => super.offset + _offsetFromPointerEvent;

  void _maybeSchedulePostMainTreeFlushLayoutCallback() {
    if (_hasPendingCallback) return;
    _hasPendingCallback = true;

    SmoothSchedulerBindingMixin.instance.addStartDrawFrameCallback(() {
      // print('hi $runtimeType addStartDrawFrameCallback.callback');

      _hasPendingCallback = false;

      if (offset == 0) return;
      setState(() => _offsetFromPointerEvent = 0);
    });
  }

  void _handlePointerMove(PointerMoveEvent e) {
    // print('hi $runtimeType _handlePointerMove embedderId=${e.embedderId} e=$e');
    setState(() {
      // very naive, and is WRONG!
      // just to confirm, we can (1) receive (2) display events
      _offsetFromPointerEvent += e.localDelta.dy;
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

mixin _SmoothShiftFromBallistic on _SmoothShiftBase {
  double _offsetFromBallistic = 0;
  Ticker? _ticker;

  @override
  double get offset => super.offset + _offsetFromBallistic;

  @override
  void initState() {
    super.initState();

    // https://github.com/fzyzcjy/yplusplus/issues/5918#issuecomment-1266553640
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _position.lastSimulationInfo.addListener(_handleLastSimulationChanged);
    });
  }

  @override
  void didUpdateWidget(covariant SmoothShift oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.scrollController == widget.scrollController,
        'for simplicity, not yet implemented change of `scrollController`');
  }

  @override
  void dispose() {
    _position.lastSimulationInfo.removeListener(_handleLastSimulationChanged);
    _ticker?.dispose();
    super.dispose();
  }

  SmoothScrollPositionWithSingleContext get _position =>
      SmoothScrollPositionWithSingleContext.of(widget.scrollController);

  void _handleLastSimulationChanged() {
    _ticker?.dispose();

    // re-create ticker, because the [Simulation] wants zero timestamp
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    if (!mounted) return;

    final lastSimulationInfo = _position.lastSimulationInfo.value;
    if (lastSimulationInfo == null) return;

    final plainValue = lastSimulationInfo.realSimulation.lastX;
    if (plainValue == null) return;

    // ref: [AnimationController._tick]
    final elapsedInSeconds =
        elapsed.inMicroseconds.toDouble() / Duration.microsecondsPerSecond;
    final smoothValue = lastSimulationInfo.clonedSimulation.x(elapsedInSeconds);

    setState(() {
      _offsetFromBallistic = -(smoothValue - plainValue);
    });

    print(
        'hi ${describeIdentity(this)}._tick offset=$offset smoothValue=$smoothValue plainValue=$plainValue elapsed=$elapsed');
  }
}
