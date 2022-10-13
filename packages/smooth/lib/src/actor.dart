import 'dart:developer';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:smooth/src/service_locator.dart';
import 'package:smooth/src/time/simple_date_time.dart';
import 'package:smooth/src/time/typed_time.dart';

class Actor {
  // var _maybePreemptRenderCallCount = 0;

  final _times = <Duration>[];

  void debugPrintStat() {
    // ignore: avoid_print
    print(
        'PreemptRender times=[${_times.map((d) => d.inMicroseconds / 1000).toList().join(', ')}]');
  }

  void maybePreemptRenderBuildOrLayoutPhase() {
    final serviceLocator = ServiceLocator.maybeInstance;
    if (serviceLocator == null ||
        serviceLocator.auxiliaryTreeRegistry.trees.isEmpty) {
      return;
    }

    final timeManager = serviceLocator.timeManager;
    final now = clock.nowSimple();
    final nowTimestamp =
        serviceLocator.timeConverter.dateTimeToAdjustedFrameTimeStamp(now);

    if (timeManager.thresholdActOnBuildOrLayoutPhaseTimeStamp! < nowTimestamp) {
      _preemptRenderRaw(debugReason: 'maybePreemptRenderBuildOrLayoutPhase');
      timeManager.afterBuildOrLayoutPhasePreemptRender(now: nowTimestamp);
    }
  }

  void maybePreemptRenderPostDrawFramePhase() {
    final serviceLocator = ServiceLocator.maybeInstance;
    if (serviceLocator == null ||
        serviceLocator.auxiliaryTreeRegistry.trees.isEmpty) {
      return;
    }

    final timeManager = serviceLocator.timeManager;
    final now = clock.nowSimple();
    final nowTimestamp =
        serviceLocator.timeConverter.dateTimeToAdjustedFrameTimeStamp(now);

    if (timeManager.thresholdActOnPostDrawFramePhaseTimeStamp! < nowTimestamp) {
      // NOTE this is "before" not "after"
      timeManager.beforePostDrawFramePhasePreemptRender(now: nowTimestamp);
      _preemptRenderRaw(debugReason: 'maybePreemptRenderPostDrawFramePhase');
    }
  }

  void _preemptRenderRaw({required String debugReason}) {
    final serviceLocator = ServiceLocator.instance;
    final smoothFrameTimeStamp =
        serviceLocator.timeManager.currentSmoothFrameTimeStamp;
    final binding = WidgetsFlutterBinding.ensureInitialized();
    final arguments = {
      'reason': debugReason,
      'smoothFrameTimeStamp': smoothFrameTimeStamp.inMicroseconds.toString(),
      // TODO
    };

    final start = clock.now();
    Timeline.timeSync('PreemptRender', arguments: arguments, () {
      // print('$runtimeType _preemptRender start');

      // print('_preemptRender '
      //     'lastVsyncInfo=$lastVsyncInfo '
      //     'currentFrameTimeStamp=${binding.currentFrameTimeStamp} '
      //     'now=$now '
      //     'shouldShiftOneFrameForInterestVsyncTarget=$shouldShiftOneFrameForInterestVsyncTarget '
      //     'set-interestVsyncTargetTimeByLastPreemptRender=$interestVsyncTargetTimeByLastPreemptRender');

      serviceLocator.extraEventDispatcher
          .dispatch(smoothFrameTimeStamp: smoothFrameTimeStamp);

      // ref: https://github.com/fzyzcjy/yplusplus/issues/5780#issuecomment-1254562485
      // ref: RenderView.compositeFrame

      _preemptModifyLayerTree(smoothFrameTimeStamp, debugReason: debugReason);

      final builder = SceneBuilder();
      // why this layer - from RenderView.compositeFrame
      // ignore: invalid_use_of_protected_member
      final scene = binding.renderView.layer!.buildScene(builder);

      // print(
      //     'call window.render (now=${DateTime.now()}, stopwatch=${stopwatch.elapsed})');
      WidgetsBinding.instance.window.render(
        scene,
        fallbackVsyncTargetTime: serviceLocator.timeConverter
            .adjustedToSystemFrameTimeStamp(smoothFrameTimeStamp)
            .innerSystemFrameTimeStamp,
      );

      scene.dispose();

      // #5831
      // // #5822
      // binding.platformDispatcher.preemptRequestVsync();
    });
    _times.add(clock.now().difference(start));

    // print('$runtimeType _preemptRender end');
  }

  void _preemptModifyLayerTree(AdjustedFrameTimeStamp timeStamp,
      {required String debugReason}) {
    for (final pack in ServiceLocator.instance.auxiliaryTreeRegistry.trees) {
      pack.runPipeline(
        timeStamp,
        skipIfTimeStampUnchanged: false,
        debugReason: 'preemptModifyLayerTree $debugReason',
      );
    }
  }

// static var _nextDummyPosition = 0.0;
}
