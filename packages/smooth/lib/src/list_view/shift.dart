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
  double? _pointerDownPosition;
  double? _positionWhenCurrStartDrawFrame;
  double? _positionWhenPrevStartDrawFrame;
  double? _currPosition;

  var _hasPendingCallback = false;

  // NOTE about this weird timing, see
  // https://github.com/fzyzcjy/yplusplus/issues/5961#issuecomment-1266944825
  // for detailed reasons
  // (to do: copy it here)
  double get _offsetFromPointerEvent {
    if (_currPosition == null) return 0;
    return _currPosition! -
        (_positionWhenPrevStartDrawFrame ?? _pointerDownPosition!);
  }

  @override
  double get offset => super.offset + _offsetFromPointerEvent;

  void _maybeScheduleStartDrawFrameCallback() {
    if (_hasPendingCallback) return;
    _hasPendingCallback = true;

    SmoothSchedulerBindingMixin.instance.addStartDrawFrameCallback(() {
      setState(() {
        _hasPendingCallback = false;
        _positionWhenPrevStartDrawFrame = _positionWhenCurrStartDrawFrame;
        _positionWhenCurrStartDrawFrame = _currPosition;
      });

      print('hi $runtimeType addStartDrawFrameCallback.callback (after) '
          '_positionWhenPrevStartDrawFrame=$_positionWhenPrevStartDrawFrame _currPosition=$_currPosition');
    });
  }

  void _handlePointerDown(PointerDownEvent e) {
    setState(() {
      _pointerDownPosition = e.localPosition.dy;
    });
  }

  void _handlePointerMove(PointerMoveEvent e) {
    print(
        'hi $runtimeType _handlePointerMove e.localPosition=${e.localPosition.dy} e=$e');

    setState(() {
      _currPosition = e.localPosition.dy;
    });
  }

  void _handlePointerUpOrCancel(PointerEvent e) {
    setState(() {
      _pointerDownPosition = null;
      _positionWhenCurrStartDrawFrame = null;
      _positionWhenPrevStartDrawFrame = null;
      _currPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeScheduleStartDrawFrameCallback();

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUpOrCancel,
      onPointerCancel: _handlePointerUpOrCancel,
      behavior: HitTestBehavior.translucent,
      child: super.build(context),
    );
  }
}

mixin _SmoothShiftFromBallistic on _SmoothShiftBase {
  double _offsetFromBallistic = 0;
  Ticker? _ticker;
  SmoothScrollPositionWithSingleContext? _position;

  @override
  double get offset => super.offset + _offsetFromBallistic;

  @override
  void initState() {
    super.initState();

    // https://github.com/fzyzcjy/yplusplus/issues/5918#issuecomment-1266553640
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _position =
          SmoothScrollPositionWithSingleContext.of(widget.scrollController);
      _position!.lastSimulationInfo.addListener(_handleLastSimulationChanged);
    });
  }

  @override
  void didUpdateWidget(covariant SmoothShift oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.scrollController == widget.scrollController,
        'for simplicity, not yet implemented change of `scrollController`');
    assert(
        SmoothScrollPositionWithSingleContext.of(widget.scrollController) ==
            _position,
        'for simplicity, SmoothScrollPositionWithSingleContext cannot yet be changed');
  }

  @override
  void dispose() {
    _position?.lastSimulationInfo.removeListener(_handleLastSimulationChanged);
    _ticker?.dispose();
    super.dispose();
  }

  void _handleLastSimulationChanged() {
    _ticker?.dispose();

    // re-create ticker, because the [Simulation] wants zero timestamp
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    if (!mounted) return;

    final lastSimulationInfo = _position!.lastSimulationInfo.value;
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

    print('hi ${describeIdentity(this)}._tick '
        'set _offsetFromBallistic=$_offsetFromBallistic '
        'since smoothValue=$smoothValue plainValue=$plainValue elapsed=$elapsed');
  }
}
