import 'dart:developer';

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

// try to use mixin to maximize performance
class _SmoothShiftState extends _SmoothShiftBase
    with _SmoothShiftFromPointerEvent, _SmoothShiftFromBallistic {
  @override
  Widget build(BuildContext context) {
    print('hi $runtimeType build '
        'offset=$offset '
        '_offsetFromPointerEvent=$_offsetFromPointerEvent '
        '_offsetFromBallistic=$_offsetFromBallistic');
    // SimpleLog.instance.log(
    //     'SmoothShift.build offset=$offset currentSmoothFrameTimeStamp=${ServiceLocator.maybeInstance?.preemptStrategy.currentSmoothFrameTimeStamp}');

    return super.build(context);
  }
}

abstract class _SmoothShiftBase extends State<SmoothShift>
    with TickerProviderStateMixin {
  double get offset => 0;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return Timeline.timeSync('SmoothShift',
        arguments: <String, Object?>{'offset': offset}, () {
      return Transform.translate(
        offset: Offset(0, offset),
        transformHitTests: false,
        child: widget.child,
      );
    });
  }
}

// NOTE about this weird timing, see
// * https://github.com/fzyzcjy/yplusplus/issues/5961#issuecomment-1266944825
// * https://github.com/fzyzcjy/yplusplus/issues/5961#issuecomment-1266978644
// for detailed reasons
// (to do: copy it here)
mixin _SmoothShiftFromPointerEvent on _SmoothShiftBase {
  double? _pointerDownPosition;
  double? _positionWhenCurrStartDrawFrame;
  double? _positionWhenPrevStartDrawFrame;
  double? _currPosition;

  // double? _positionWhenPrevPrevBuild;
  // double? _positionWhenPrevBuild;

  double get _offsetFromPointerEvent {
    if (_currPosition == null) return 0;

    final mainLayerTreeModeInAuxTreeView = SmoothSchedulerBindingMixin
        .instance.mainLayerTreeModeInAuxTreeView.value;
    // https://github.com/fzyzcjy/yplusplus/issues/5961#issuecomment-1266978644
    final basePosition = mainLayerTreeModeInAuxTreeView.choose(
      currentPlainFrame: _positionWhenCurrStartDrawFrame,
      previousPlainFrame: _positionWhenPrevStartDrawFrame,
    );

    final ans = _currPosition! - (basePosition ?? _pointerDownPosition!);

    final args = {
      'currPosition': _currPosition,
      'mainLayerTreeModeInAuxTreeView': mainLayerTreeModeInAuxTreeView.name,
      'positionWhenCurrStartDrawFrame': _positionWhenCurrStartDrawFrame,
      'positionWhenPrevStartDrawFrame': _positionWhenPrevStartDrawFrame,
      'pointerDownPosition': _pointerDownPosition,
      'basePosition': basePosition,
      'ans': ans,
    };
    Timeline.timeSync(
        'SmoothShift.offsetFromPointerEvent', arguments: args, () {});
    print('hi $runtimeType get _offsetFromPointerEvent $args');

    return ans;
  }

  @override
  double get offset => super.offset + _offsetFromPointerEvent;

  var _hasPendingStartDrawFrameCallback = false;

  void _maybeAddCallbacks() {
    if (!_hasPendingStartDrawFrameCallback) {
      _hasPendingStartDrawFrameCallback = true;
      SmoothSchedulerBindingMixin.instance.addBeginFrameEarlyCallback(() {
        if (!mounted) return;
        _hasPendingStartDrawFrameCallback = false;

        setState(() {
          _positionWhenPrevStartDrawFrame = _positionWhenCurrStartDrawFrame;
          _positionWhenCurrStartDrawFrame = _currPosition;
        });

        Timeline.timeSync(
          'SmoothShift.StartDrawFrameCallback.after',
          arguments: <String, Object?>{
            'currPosition': _currPosition,
            'positionWhenCurrStartDrawFrame': _positionWhenCurrStartDrawFrame,
            'positionWhenPrevStartDrawFrame': _positionWhenPrevStartDrawFrame,
            'pointerDownPosition': _pointerDownPosition,
          },
          () {},
        );

        // print('hi $runtimeType addStartDrawFrameCallback.callback (after) '
        //     '_positionWhenPrevStartDrawFrame=$_positionWhenPrevStartDrawFrame _currPosition=$_currPosition');
      });
    }
  }

  void _handlePointerDown(PointerDownEvent e) {
    setState(() {
      _pointerDownPosition = e.localPosition.dy;
    });
  }

  void _handlePointerMove(PointerMoveEvent e) {
    // SimpleLog.instance
    //     .log('SmoothShift.handlePointerMove position=${e.localPosition.dy}');
    // print(
    //     'hi $runtimeType _handlePointerMove e.localPosition=${e.localPosition.dy} e=$e');

    Timeline.timeSync(
      'SmoothShift.handlePointerMove',
      arguments: <String, Object?>{
        'eventPosition': e.localPosition.dy,
      },
      () {},
    );

    setState(() {
      _currPosition = e.localPosition.dy;
    });
  }

  void _handlePointerUpOrCancel(PointerEvent e) {
    setState(() {
      _pointerDownPosition = null;
      _positionWhenCurrStartDrawFrame = null;
      _positionWhenPrevStartDrawFrame = null;
      // _positionWhenPrevPrevBuild = null;
      // _positionWhenPrevBuild = null;
      _currPosition = null;
    });
  }

  void _handleRefresh() => setState(() {});

  // remove in #6071
  // // #6052
  // void _maybePseudoMoveOnBuild() {
  //   if (_currPosition == null) return;
  //
  //   // no pointer events
  //   if (_positionWhenPrevBuild == _currPosition) {
  //     // very naive interpolation...
  //     final double interpolatedShift;
  //
  //     if (_positionWhenPrevBuild != null &&
  //         _positionWhenPrevPrevBuild != null) {
  //       interpolatedShift =
  //           _positionWhenPrevBuild! - _positionWhenPrevPrevBuild!;
  //     } else {
  //       interpolatedShift = 0.0;
  //     }
  //
  //     _currPosition = _currPosition! + interpolatedShift;
  //   }
  //
  //   _positionWhenPrevPrevBuild = _positionWhenPrevBuild;
  //   _positionWhenPrevBuild = _currPosition;
  // }

  @override
  void initState() {
    super.initState();
    SmoothSchedulerBindingMixin.instance.mainLayerTreeModeInAuxTreeView
        .addListener(_handleRefresh);
  }

  @override
  void dispose() {
    SmoothSchedulerBindingMixin.instance.mainLayerTreeModeInAuxTreeView
        .removeListener(_handleRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _maybeAddCallbacks();
    // _maybePseudoMoveOnBuild();

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
  SmoothScrollPositionWithSingleContext? _scrollPosition;
  late final _plainOffsetSnapshot = FrameAwareSnapshot<double?>(
      () => _scrollPosition?.lastSimulationInfo.value?.realSimulation.lastX);

  @override
  double get offset => super.offset + _offsetFromBallistic;

  @override
  void initState() {
    super.initState();

    _plainOffsetSnapshot.addListener(_handleRefresh);

    // https://github.com/fzyzcjy/yplusplus/issues/5918#issuecomment-1266553640
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollPosition =
          SmoothScrollPositionWithSingleContext.of(widget.scrollController);
      _scrollPosition!.lastSimulationInfo
          .addListener(_handleLastSimulationChanged);
    });
  }

  @override
  void didUpdateWidget(covariant SmoothShift oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.scrollController == widget.scrollController,
        'for simplicity, not yet implemented change of `scrollController`');
    assert(
        SmoothScrollPositionWithSingleContext.of(widget.scrollController) ==
            _scrollPosition,
        'for simplicity, SmoothScrollPositionWithSingleContext cannot yet be changed');
  }

  @override
  void dispose() {
    _plainOffsetSnapshot.removeListener(_handleRefresh);
    _scrollPosition?.lastSimulationInfo
        .removeListener(_handleLastSimulationChanged);
    _ticker?.dispose();
    super.dispose();
  }

  void _handleRefresh() => setState(() {});

  void _handleLastSimulationChanged() {
    _ticker?.dispose();

    // re-create ticker, because the [Simulation] wants zero timestamp
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration selfTickerElapsed) {
    if (!mounted) return;

    setState(() {
      _offsetFromBallistic =
          _computeOffsetFromBallisticOnTick(selfTickerElapsed);
    });
  }

  double _computeOffsetFromBallisticOnTick(Duration selfTickerElapsed) {
    final lastSimulationInfo = _scrollPosition!.lastSimulationInfo.value;
    if (lastSimulationInfo == null) return 0;

    // [selfTickerElapsed] is the time delta relative to [_ticker.startTime]
    // thus [tickTimeStamp] is absolute [AdjustedFrameTimeStamp]
    final tickTimeStamp = _ticker!.startTime! + selfTickerElapsed;
    // [simulationRelativeTime] is the time delta relative to
    // [ballisticScrollActivityTicker]. In other words, it is the time that the
    // real [ListView]'s [BallisticScrollActivity] has.
    final ballisticTickerStartTime =
        lastSimulationInfo.ballisticScrollActivityTicker.startTime;
    if (ballisticTickerStartTime == null) return 0;
    final simulationRelativeTime = tickTimeStamp - ballisticTickerStartTime;

    final smoothOffset = lastSimulationInfo.clonedSimulation
        .x(simulationRelativeTime.inMicroseconds / 1000000);

    final plainOffset = _plainOffsetSnapshot.snapshotOf(
        SmoothSchedulerBindingMixin
            .instance.mainLayerTreeModeInAuxTreeView.value);
    if (plainOffset == null) return 0;

    final ans = -(smoothOffset - plainOffset);

    print('hi $runtimeType._computeOffsetFromBallisticOnTick '
        'ans=$ans '
        'smoothOffset=$smoothOffset '
        'plainOffset=$plainOffset '
        'plainOffsetSnapshot=$_plainOffsetSnapshot '
        'mainLayerTreeModeInAuxTreeView=${SmoothSchedulerBindingMixin.instance.mainLayerTreeModeInAuxTreeView.value} '
        'selfTickerElapsed=$selfTickerElapsed '
        'tickTimeStamp=$tickTimeStamp '
        'ballisticTickerStartTime=$ballisticTickerStartTime '
        'simulationRelativeTime=$simulationRelativeTime ');

    return ans;
  }
}
