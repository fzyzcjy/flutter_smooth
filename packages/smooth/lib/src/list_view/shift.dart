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
  late final _positionSnapshot =
      FrameAwareSnapshot<double?>(() => _currPosition);
  double? _pointerDownPosition;
  double? _currPosition;

  // double? _positionWhenPrevPrevBuild;
  // double? _positionWhenPrevBuild;

  double get _offsetFromPointerEvent {
    if (_currPosition == null) return 0;

    final mainLayerTreeModeInAuxTreeView = SmoothSchedulerBindingMixin
        .instance.mainLayerTreeModeInAuxTreeView.value;
    final basePosition =
        _positionSnapshot.snapshotOf(mainLayerTreeModeInAuxTreeView);

    final ans = _currPosition! - (basePosition ?? _pointerDownPosition!);

    final args = {
      'currPosition': _currPosition,
      'mainLayerTreeModeInAuxTreeView': mainLayerTreeModeInAuxTreeView.name,
      'positionSnapshot': _positionSnapshot.toString(),
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
      _positionSnapshot.reset();
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
    // _maybeAddCallbacks();
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
    _scrollPosition?.lastSimulationInfo
        .removeListener(_handleLastSimulationChanged);
    _ticker?.dispose();
    super.dispose();
  }

  void _handleLastSimulationChanged() {
    _ticker?.dispose();

    // re-create ticker, because the [Simulation] wants zero timestamp
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration selfTickerElapsed) {
    if (!mounted) return;

    final lastSimulationInfo = _scrollPosition!.lastSimulationInfo.value;
    if (lastSimulationInfo == null) return;

    // [selfTickerElapsed] is the time delta relative to [_ticker.startTime]
    // thus [tickTimeStamp] is absolute [AdjustedFrameTimeStamp]
    final tickTimeStamp = _ticker!.startTime! + selfTickerElapsed;
    // [simulationRelativeTime] is the time delta relative to
    // [ballisticScrollActivityTicker]. In other words, it is the time that the
    // real [ListView]'s [BallisticScrollActivity] has.
    final simulationRelativeTime = tickTimeStamp -
        lastSimulationInfo.ballisticScrollActivityTicker.startTime!;

    final smoothOffset = lastSimulationInfo.clonedSimulation
        .x(simulationRelativeTime.inMicroseconds / 1000000);

    final plainOffset = _plainOffsetSnapshot.snapshotOf(
        SmoothSchedulerBindingMixin
            .instance.mainLayerTreeModeInAuxTreeView.value);

    setState(() {
      _offsetFromBallistic =
          plainOffset == null ? 0.0 : -(smoothOffset - plainOffset);
    });

    // old
    // final plainValue = lastSimulationInfo.realSimulation.lastX;
    // if (plainValue == null) return;
    //
    // // ref: [AnimationController._tick]
    // final elapsedInSeconds =
    //     elapsed.inMicroseconds.toDouble() / Duration.microsecondsPerSecond;
    // final smoothValue = lastSimulationInfo.clonedSimulation.x(elapsedInSeconds);
    //
    // setState(() {
    //   _offsetFromBallistic = -(smoothValue - plainValue);
    // });
    //
    // print('hi ${describeIdentity(this)}._tick '
    //     'set _offsetFromBallistic=$_offsetFromBallistic '
    //     'since smoothValue=$smoothValue plainValue=$plainValue elapsed=$elapsed');
  }
}

// TODO move?
class FrameAwareSnapshot<T> extends ChangeNotifier {
  final ValueGetter<T> source;

  T? get snapshotWhenCurrStartDrawFrame => _snapshotWhenCurrStartDrawFrame;
  T? _snapshotWhenCurrStartDrawFrame;

  T? get snapshotWhenPrevStartDrawFrame => _snapshotWhenPrevStartDrawFrame;
  T? _snapshotWhenPrevStartDrawFrame;

  T? snapshotOf(
          MainLayerTreeModeInAuxTreeView mainLayerTreeModeInAuxTreeView) =>
      mainLayerTreeModeInAuxTreeView.choose(
        currentPlainFrame: snapshotWhenCurrStartDrawFrame,
        previousPlainFrame: snapshotWhenPrevStartDrawFrame,
      );

  FrameAwareSnapshot(this.source) {
    _maybeAddCallback();
  }

  void reset() {
    _snapshotWhenCurrStartDrawFrame = null;
    _snapshotWhenPrevStartDrawFrame = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  var _disposed = false;
  var _hasPendingCallback = false;

  void _maybeAddCallback() {
    if (_hasPendingCallback) return;

    _hasPendingCallback = true;
    SmoothSchedulerBindingMixin.instance.addBeginFrameEarlyCallback(() {
      _hasPendingCallback = false;

      _snapshotWhenPrevStartDrawFrame = _snapshotWhenCurrStartDrawFrame;
      _snapshotWhenCurrStartDrawFrame = source();
      notifyListeners();

      // TODO do not unconditionally schedule this...
      if (!_disposed) _maybeAddCallback();
    });
  }

  @override
  String toString() => 'FrameAwareSnapshot('
      'snapshotWhenCurrStartDrawFrame: $_snapshotWhenCurrStartDrawFrame, '
      'snapshotWhenPrevStartDrawFrame: $_snapshotWhenPrevStartDrawFrame'
      ')';
}
