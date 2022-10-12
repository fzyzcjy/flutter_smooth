import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/messages_wrapped.dart';
import 'package:smooth/src/proxy.dart';
import 'package:smooth/src/service_locator.dart';
import 'package:smooth/src/time_converter.dart';
import 'package:smooth/src/time_manager.dart';

mixin SmoothSchedulerBindingMixin on SchedulerBinding {
  @override
  void initInstances() {
    super.initInstances();
    SmoothHostApiWrapped.instance.init();

    assert(window is SmoothSingletonFlutterWindowMixin,
        'must use SmoothSingletonFlutterWindowMixin for smooth to run correctly (window=$window)');
  }

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

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    // mimic how [handleBeginFrame] computes the real [currentFrameTimeStamp]
    final eagerCurrentFrameTimeStamp =
        adjustForEpoch(rawTimeStamp ?? currentSystemFrameTimeStamp);

    ServiceLocator.instance.timeManager.onBeginFrame(
        currentFrameTimeStamp: eagerCurrentFrameTimeStamp,
        now: TimeManager.normalNow);

    super.handleBeginFrame(rawTimeStamp);

    assert(eagerCurrentFrameTimeStamp == currentFrameTimeStamp);
  }

  @override
  void handleDrawFrame() {
    _invokeStartDrawFrameCallbacks();
    super.handleDrawFrame();
    // SimpleLog.instance.log('$runtimeType.handleDrawFrame.end');
  }

  // ref: [SchedulerBinding._postFrameCallbacks]
  final _startDrawFrameCallbacks = <VoidCallback>[];

  void addStartDrawFrameCallback(VoidCallback callback) =>
      _startDrawFrameCallbacks.add(callback);

  // ref: [SchedulerBinding._invokeFrameCallbackS]
  void _invokeStartDrawFrameCallbacks() {
    final localCallbacks = List.of(_startDrawFrameCallbacks);
    _startDrawFrameCallbacks.clear();
    for (final callback in localCallbacks) {
      try {
        callback();
      } catch (e, s) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: s));
      }
    }
  }

  static SmoothSchedulerBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothSchedulerBindingMixin,
        'Please use a WidgetsBinding with SmoothSchedulerBindingMixin');
    return raw as SmoothSchedulerBindingMixin;
  }
}

mixin SmoothGestureBindingMixin on GestureBinding {
  @override
  void dispatchEvent(PointerEvent event, HitTestResult? hitTestResult,
      {required HitTestEntryFilter? filter}) {
    // #6159
    Timeline.timeSync('dispatchEvent', arguments: <String, Object?>{
      'eventTimeStamp': event.timeStamp.inMicroseconds.toString(),
      'eventDateTime': (event.timeStamp.inMicroseconds +
              (SmoothHostApiWrapped
                      .instance.pointerEventDateTimeDiffTimeStamp ??
                  0))
          .toString(),
      'eventPositionDy': event.position.dy,
    }, () {
      super.dispatchEvent(event, hitTestResult, filter: filter);
    });
  }
}

mixin SmoothSingletonFlutterWindowMixin on ui.SingletonFlutterWindow {
  @override
  void render(ui.Scene scene, {Duration? fallbackVsyncTargetTime}) {
    final effectiveFallbackVsyncTargetTime = fallbackVsyncTargetTime ??
        // NOTE *need* this when [fallbackVsyncTargetTime] is null, because
        // the plain-old pipeline will call `window.render` and we cannot
        // control that
        ServiceLocator.instance.timeManager.currentSmoothFrameTimeStamp +
            Duration(
                microseconds:
                    TimeConverter.instance.diffSystemToAdjustedFrameTimeStamp);

    Timeline.timeSync('window.render', arguments: <String, String>{
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

  ValueListenable<bool> get executingRunPipelineBecauseOfAfterDrawFrame =>
      _executingRunPipelineBecauseOfAfterDrawFrame;
  final _executingRunPipelineBecauseOfAfterDrawFrame = ValueNotifier(false);

  // indeed, roughly after the `finalizeTree`
  void _handleAfterDrawFrame() {
    // print('_handleAfterFinalizeTree');

    final serviceLocator = ServiceLocator.maybeInstance;
    if (serviceLocator == null) return;

    _executingRunPipelineBecauseOfAfterDrawFrame.value = true;
    try {
      serviceLocator.actor.maybePreemptRenderPostDrawFramePhase();
    } finally {
      _executingRunPipelineBecauseOfAfterDrawFrame.value = false;
    }
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

  ValueListenable<bool> get executingRunPipelineBecauseOfAfterFlushLayout =>
      _smoothPipelineOwner.executingRunPipelineBecauseOfAfterFlushLayout;

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

  ValueListenable<bool> get executingRunPipelineBecauseOfAfterFlushLayout =>
      _executingRunPipelineBecauseOfAfterFlushLayout;
  final _executingRunPipelineBecauseOfAfterFlushLayout = ValueNotifier(false);

  void _handleAfterFlushLayout() {
    // print('handleAfterFlushLayout');

    final serviceLocator = ServiceLocator.maybeInstance;
    if (serviceLocator == null) return;

    final currentSmoothFrameTimeStamp =
        serviceLocator.timeManager.currentSmoothFrameTimeStamp;

    // #6033
    serviceLocator.extraEventDispatcher
        .dispatch(smoothFrameTimeStamp: currentSmoothFrameTimeStamp);

    _executingRunPipelineBecauseOfAfterFlushLayout.value = true;
    try {
      for (final pack in serviceLocator.auxiliaryTreeRegistry.trees) {
        pack.runPipeline(
          currentSmoothFrameTimeStamp,
          // NOTE originally, this is skip-able
          // https://github.com/fzyzcjy/flutter_smooth/issues/23#issuecomment-1261691891
          // but, because of logic like:
          // https://github.com/fzyzcjy/yplusplus/issues/5961#issuecomment-1266978644
          // we cannot skip it anymore.
          skipIfTimeStampUnchanged: false,
          debugReason: 'SmoothPipelineOwner.handleAfterFlushLayout',
        );
      }
    } finally {
      _executingRunPipelineBecauseOfAfterFlushLayout.value = false;
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
