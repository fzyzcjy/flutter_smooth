import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/infra/auxiliary_tree_pack.dart';
import 'package:smooth/src/infra/proxy.dart';
import 'package:smooth/src/infra/service_locator.dart';
import 'package:smooth/src/infra/time_manager.dart';

mixin SmoothSchedulerBindingMixin on SchedulerBinding {
  @override
  void initInstances() {
    super.initInstances();

    assert(window is SmoothSingletonFlutterWindowMixin,
        'must use SmoothSingletonFlutterWindowMixin for smooth to run correctly (window=$window)');
  }

  ServiceLocator get serviceLocator;

  // NOTE It is *completely wrong* to use clock.now at handleBeginFrame
  // because there can be large vsync overhead! #6120
  //
  // DateTime get beginFrameDateTime => _beginFrameDateTime!;
  // DateTime? _beginFrameDateTime;
  //
  // @override
  // void handleBeginFrame(Duration? rawTimeStamp) {
  //   _beginFrameDateTime = clock.now();
  //
  //   // SimpleLog.instance.log('$runtimeType.handleBeginFrame.start '
  //   //     'rawTimeStamp=$rawTimeStamp clock.now=$_beginFrameDateTime');
  //
  //   super.handleBeginFrame(rawTimeStamp);
  // }

  ValueListenable<MainLayerTreeModeInAuxTreeView>
      get mainLayerTreeModeInAuxTreeView => _mainLayerTreeModeInAuxTreeView;
  final _mainLayerTreeModeInAuxTreeView =
      ValueNotifier(MainLayerTreeModeInAuxTreeView.previousPlainFrame);

  /// "early" := it is called before Flutter things such as animations
  void addBeginFrameEarlyCallback(VoidCallback callback) =>
      _beginFrameEarlyCallbacks.addCallback(callback);
  final _beginFrameEarlyCallbacks = _Callbacks();

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    // we are in a new frame, so last frame's "now" means this frame's "previous"
    _mainLayerTreeModeInAuxTreeView.value =
        MainLayerTreeModeInAuxTreeView.previousPlainFrame;

    // mimic how [handleBeginFrame] computes the real [currentFrameTimeStamp]
    final eagerCurrentFrameTimeStamp = AdjustedFrameTimeStamp.uncheckedFrom(
        adjustForEpoch(rawTimeStamp ?? currentSystemFrameTimeStamp));

    ServiceLocator.instance.timeManager
        .onBeginFrame(currentFrameTimeStamp: eagerCurrentFrameTimeStamp);

    _beginFrameEarlyCallbacks.invokeCallbacks();

    super.handleBeginFrame(rawTimeStamp);

    assert(eagerCurrentFrameTimeStamp.inMicroseconds ==
        currentFrameTimeStamp.inMicroseconds);
  }

  @override
  void handleDrawFrame() {
    super.handleDrawFrame();
    // SimpleLog.instance.log('$runtimeType.handleDrawFrame.end');
  }

  static SmoothSchedulerBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothSchedulerBindingMixin,
        'Please use a WidgetsBinding with SmoothSchedulerBindingMixin');
    return raw as SmoothSchedulerBindingMixin;
  }
}

class _Callbacks {
  // ref: [SchedulerBinding._postFrameCallbacks]
  final _callbacks = <VoidCallback>[];

  void addCallback(VoidCallback callback) => _callbacks.add(callback);

  // ref: [SchedulerBinding._invokeFrameCallbackS]
  void invokeCallbacks() {
    final localCallbacks = List.of(_callbacks);
    _callbacks.clear();
    for (final callback in localCallbacks) {
      try {
        callback();
      } catch (e, s) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: s));
      }
    }
  }
}

/// When aux tree is computing, should it imagine the main layer tree
/// be the content of current ([currentPlainFrame]) or previous
/// ([previousPlainFrame]) plain frame?
enum MainLayerTreeModeInAuxTreeView {
  currentPlainFrame,
  previousPlainFrame;

  T choose<T>({
    required T currentPlainFrame,
    required T previousPlainFrame,
  }) {
    switch (this) {
      case MainLayerTreeModeInAuxTreeView.currentPlainFrame:
        return currentPlainFrame;
      case MainLayerTreeModeInAuxTreeView.previousPlainFrame:
        return previousPlainFrame;
    }
  }
}

mixin SmoothGestureBindingMixin on GestureBinding {
  @override
  void dispatchEvent(PointerEvent event, HitTestResult? hitTestResult,
      {required HitTestEntryFilter? filter}) {
    // #6159
    Timeline.timeSync('dispatchEvent', arguments: <String, Object?>{
      'eventTimeStamp': event.timeStamp.inMicroseconds.toString(),
      'eventDateTime': ServiceLocator.instance.timeConverter
          .pointerEventTimeStampToDateTime(event.timeStampTyped)
          ?.microsecondsSinceEpoch
          .toString(),
      'eventPositionDy': event.position.dy,
    }, () {
      super.dispatchEvent(event, hitTestResult, filter: filter);
    });
  }
}

mixin SmoothSingletonFlutterWindowMixin on ui.SingletonFlutterWindow {
  // static SmoothSingletonFlutterWindowMixin get instance =>
  //     SchedulerBinding.instance.window as SmoothSingletonFlutterWindowMixin;

  @override
  void render(ui.Scene scene, {Duration? fallbackVsyncTargetTime}) {
    final serviceLocator = ServiceLocator.instance;

    final effectiveFallbackVsyncTargetTime = fallbackVsyncTargetTime ??
        // NOTE *need* this when [fallbackVsyncTargetTime] is null, because
        // the plain-old pipeline will call `window.render` and we cannot
        // control that
        serviceLocator.timeConverter
            .adjustedToSystemFrameTimeStamp(
                serviceLocator.timeManager.currentSmoothFrameTimeStamp)
            .innerSystemFrameTimeStamp;

    Timeline.timeSync('window.render', arguments: <String, String?>{
      'effectiveFallbackVsyncTargetTime':
          effectiveFallbackVsyncTargetTime.inMicroseconds.toString()
    }, () {
      super.render(
        scene,
        // NOTE use the "effective" version
        fallbackVsyncTargetTime: effectiveFallbackVsyncTargetTime,
      );
    });
  }
}

class SmoothSingletonFlutterWindow extends ProxySingletonFlutterWindow
    with SmoothSingletonFlutterWindowMixin {
  SmoothSingletonFlutterWindow(super.inner);
}

mixin SmoothWidgetsBindingMixin on WidgetsBinding {
  @override
  void drawFrame() {
    super.drawFrame();
    _handleAfterDrawFrame();
  }

  // indeed, roughly after the `finalizeTree`
  void _handleAfterDrawFrame() {
    // print('_handleAfterFinalizeTree');

    ServiceLocator.instance.actor.maybePreemptRenderPostDrawFramePhase();

    if (ServiceLocator.instance.brakeController.brakeModeActive) {
      _forceScheduleFrameForBrakeModeActive();
    }
  }

  // for details see #6218
  void _forceScheduleFrameForBrakeModeActive() {
    Timeline.timeSync('forceScheduleFrameForBrakeModeActive', () {
      final serviceLocator = ServiceLocator.instance;
      final currentSmoothFrameTimeStamp =
          serviceLocator.timeManager.currentSmoothFrameTimeStamp;
      final currentSmoothSystemFrameTimeStamp = serviceLocator.timeConverter
          .adjustedToSystemFrameTimeStamp(currentSmoothFrameTimeStamp);
      final forceDirectlyCallNextVsyncTargetTime =
          currentSmoothSystemFrameTimeStamp.innerSystemFrameTimeStamp +
              kOneFrame;
      // print(
      //     'hi forceScheduleFrameForBrakeModeActive forceDirectlyCallNextVsyncTargetTime=$forceDirectlyCallNextVsyncTargetTime');

      // ref [SchedulerBinding.scheduleFrame], except for the
      // "if _hasScheduledFrame then skip" logic, since we want to *force*
      // schedule it
      ensureFrameCallbacksRegistered();
      platformDispatcher.scheduleFrame(
          forceDirectlyCallNextVsyncTargetTime:
              forceDirectlyCallNextVsyncTargetTime);
    });
  }

  static SmoothWidgetsBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothWidgetsBindingMixin,
        'Please use a WidgetsBinding with SmoothWidgetsBindingMixin');
    return raw as SmoothWidgetsBindingMixin;
  }
}

mixin SmoothRendererBindingMixin on RendererBinding {
  @override
  PipelineOwner get pipelineOwner => _smoothPipelineOwner;
  late final _smoothPipelineOwner = _SmoothPipelineOwner(super.pipelineOwner);

  // ValueListenable<bool> get executingRunPipelineBecauseOfAfterFlushLayout =>
  //     _smoothPipelineOwner.executingRunPipelineBecauseOfAfterFlushLayout;

  static SmoothRendererBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothRendererBindingMixin,
        'Please use a WidgetsBinding with SmoothRendererBindingMixin');
    return raw as SmoothRendererBindingMixin;
  }
}

class _SmoothPipelineOwner extends ProxyPipelineOwner {
  _SmoothPipelineOwner(super.inner);

  @override
  void flushLayout() {
    super.flushLayout();
    _handleAfterFlushLayout();
  }

  void _handleAfterFlushLayout() {
    // print('handleAfterFlushLayout');

    final serviceLocator = ServiceLocator.instance;

    // NOTE before really doing "AfterFlushLayout" things, call preempt point
    // once more, pretending we are still at the (near-end) of build/layout
    // phase. This is needed because of #6232
    serviceLocator.actor.maybePreemptRenderBuildOrLayoutPhase();

    // NOTE: Set this *BEFORE* runPipeline and main tree's paint phase.
    //
    // even though we have *not* started main tree's paint phase,
    // we have to consider current frame (not previous frame)'s main layer tree
    // when runPipeline in aux tree. This is because, the output of this
    // runPipeline in aux tree will be combined with *current* frame's main
    // layer tree soon.
    SmoothSchedulerBindingMixin.instance._mainLayerTreeModeInAuxTreeView.value =
        MainLayerTreeModeInAuxTreeView.currentPlainFrame;

    final currentSmoothFrameTimeStamp =
        serviceLocator.timeManager.currentSmoothFrameTimeStamp;

    // #6033
    serviceLocator.extraEventDispatcher
        .dispatch(smoothFrameTimeStamp: currentSmoothFrameTimeStamp);

    for (final pack in serviceLocator.auxiliaryTreeRegistry.trees) {
      pack.runPipeline(
        currentSmoothFrameTimeStamp,
        // NOTE originally, this is skip-able
        // https://github.com/fzyzcjy/flutter_smooth/issues/23#issuecomment-1261691891
        // but, because of logic like:
        // https://github.com/fzyzcjy/yplusplus/issues/5961#issuecomment-1266978644
        // we cannot skip it anymore.
        skipIfTimeStampUnchanged: false,
        debugReason: RunPipelineReason.plainAfterFlushLayout,
      );
    }

    serviceLocator.timeManager
        .afterRunAuxPipelineForPlainOld(now: TimeManager.normalNow);
  }
}

// ref [AutomatedTestWidgetsFlutterBinding]
class SmoothWidgetsFlutterBinding extends WidgetsFlutterBinding
    with
        SmoothSchedulerBindingMixin,
        SmoothGestureBindingMixin,
        SmoothRendererBindingMixin,
        SmoothWidgetsBindingMixin {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  // in non-test scenario, this is just a normal final variable
  @override
  late final serviceLocator = ServiceLocator();

  @override
  SmoothSingletonFlutterWindow get window =>
      SmoothSingletonFlutterWindow(super.window);

  static SmoothWidgetsFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);
  static SmoothWidgetsFlutterBinding? _instance;

  // ignore: prefer_constructors_over_static_methods
  static SmoothWidgetsFlutterBinding ensureInitialized() {
    if (SmoothWidgetsFlutterBinding._instance == null) {
      SmoothWidgetsFlutterBinding();
    }
    return SmoothWidgetsFlutterBinding.instance;
  }
}
