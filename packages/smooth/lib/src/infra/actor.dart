import 'dart:developer';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:smooth/src/infra/auxiliary_tree_pack.dart';
import 'package:smooth/src/infra/service_locator.dart';
import 'package:smooth/src/infra/time/simple_date_time.dart';
import 'package:smooth/src/infra/time/typed_time.dart';

class Actor {
  void maybePreemptRenderBuildOrLayoutPhase() {
    final serviceLocator = ServiceLocator.instance;
    if (serviceLocator.auxiliaryTreeRegistry.trees.isEmpty) return;

    final timeManager = serviceLocator.timeManager;
    final now = clock.nowSimple();
    final nowTimestamp =
        serviceLocator.timeConverter.dateTimeToAdjustedFrameTimeStamp(now);

    if (timeManager.thresholdActOnBuildOrLayoutPhaseTimeStamp! >=
        nowTimestamp) {
      // _debugLogMaybePreemptRender(haltReason: 'TimeTooEarly');
      return;
    }

    // this should be called *after* time check, since this may be a bit more
    // expensive
    if (!_preludeBeforePreemptRender()) {
      // _debugLogMaybePreemptRender(haltReason: 'PreludeDisagree');
      return;
    }

    _preemptRenderRaw(
        debugReason: RunPipelineReason.preemptRenderBuildOrLayoutPhase);

    timeManager.afterBuildOrLayoutPhasePreemptRender(now: nowTimestamp);
  }

  void maybePreemptRenderPostDrawFramePhase() {
    final serviceLocator = ServiceLocator.instance;
    if (serviceLocator.auxiliaryTreeRegistry.trees.isEmpty) return;

    Timeline.timeSync('MaybePreemptRender', () {
      final timeManager = serviceLocator.timeManager;
      final now = clock.nowSimple();
      final nowTimestamp =
          serviceLocator.timeConverter.dateTimeToAdjustedFrameTimeStamp(now);

      // TODO refactor - maybe extract such duplicated code
      // similar reason as the same code in [maybePreemptRenderBuildOrLayoutPhase]
      // #6210
      serviceLocator.extraEventDispatcher.fetchFromEngine();

      if (timeManager.thresholdActOnPostDrawFramePhaseTimeStamp! >=
          nowTimestamp) {
        // _debugLogMaybePreemptRender(haltReason: 'TimeTooEarly');
        return;
      }

      if (!_preludeBeforePreemptRender()) {
        // _debugLogMaybePreemptRender(haltReason: 'PreludeDisagree');
        return;
      }

      // NOTE this is "before" not "after"
      timeManager.beforePostDrawFramePhasePreemptRender(now: nowTimestamp);

      _preemptRenderRaw(
          debugReason: RunPipelineReason.preemptRenderPostDrawFramePhase);
    });
  }

  bool _preludeBeforePreemptRender() {
    final serviceLocator = ServiceLocator.instance;

    // this must be done *BEFORE* preemptRender. By doing so, when a callback
    // sees some "difficult" point event and decide to activate brakeMode,
    // we will skip the preemptRender below to save time.
    // #6210
    serviceLocator.extraEventDispatcher.fetchFromEngine();

    // when in brake mode, do not do any preemptRender #6210
    return !serviceLocator.brakeController.brakeModeActive;
  }

  // void _debugLogMaybePreemptRender({required String haltReason}) =>
  //     Timeline.timeSync(
  //         'MaybePreemptRenderHalt',
  //         arguments: <String, Object?>{'haltReason': haltReason},
  //         () {});

  void _preemptRenderRaw({required RunPipelineReason debugReason}) {
    final serviceLocator = ServiceLocator.instance;
    final smoothFrameTimeStamp =
        serviceLocator.timeManager.currentSmoothFrameTimeStamp;
    final binding = WidgetsFlutterBinding.ensureInitialized();
    final arguments = {
      'reason': debugReason.toString(),
      'smoothFrameTimeStamp': smoothFrameTimeStamp.inMicroseconds.toString(),
      // TODO
    };

    // final start = clock.now();
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

      final smoothFrameSystemTimeStamp = serviceLocator.timeConverter
          .adjustedToSystemFrameTimeStamp(smoothFrameTimeStamp);

      final builder = SceneBuilder();
      // why this layer - from RenderView.compositeFrame
      // ignore: invalid_use_of_protected_member
      final scene = binding.renderView.layer!.buildScene(builder);

      // print(
      //     'call window.render (now=${DateTime.now()}, stopwatch=${stopwatch.elapsed})');
      WidgetsBinding.instance.window.render(
        scene,
        fallbackVsyncTargetTime:
            smoothFrameSystemTimeStamp.innerSystemFrameTimeStamp,
      );

      scene.dispose();

      // #6235
      const kNotifyIdleExtraTime = Duration(microseconds: 16667 - 3000);
      binding.platformDispatcher.notifyIdle(
          smoothFrameSystemTimeStamp.innerSystemFrameTimeStamp +
              kNotifyIdleExtraTime);

      // #5831
      // // #5822
      // binding.platformDispatcher.preemptRequestVsync();
    });

    // print('$runtimeType _preemptRender end');
  }

  void _preemptModifyLayerTree(AdjustedFrameTimeStamp timeStamp,
      {required RunPipelineReason debugReason}) {
    for (final pack in ServiceLocator.instance.auxiliaryTreeRegistry.trees) {
      pack.runPipeline(
        timeStamp,
        skipIfTimeStampUnchanged: false,
        debugReason: debugReason,
      );
    }
  }
}
