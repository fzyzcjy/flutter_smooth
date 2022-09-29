import 'dart:developer';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:smooth/src/service_locator.dart';

class Actor {
  // var _maybePreemptRenderCallCount = 0;

  final _times = <Duration>[];

  void debugPrintStat() {
    print(
        'PreemptRender times=[${_times.map((d) => d.inMicroseconds / 1000).toList().join(', ')}]');
  }

  void maybePreemptRender({Object? debugToken}) {
    if (ServiceLocator.instance.auxiliaryTreeRegistry.trees.isEmpty) {
      print('Actor.maybePreemptRender skip since tree empty');
      // No active smooth widgets
      return;
    }

    // _maybePreemptRenderCallCount++;

    final shouldAct = ServiceLocator.instance.preemptStrategy
        .shouldAct(debugToken: debugToken);
    print('Actor.maybePreemptRender shouldAct=$shouldAct');

    if (shouldAct) {
      _preemptRender();
    }
  }

  void _preemptRender() {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    final start = clock.now();
    Timeline.timeSync('PreemptRender', () {
      // print('$runtimeType preemptRender start');

      // print('preemptRender '
      //     'lastVsyncInfo=$lastVsyncInfo '
      //     'currentFrameTimeStamp=${binding.currentFrameTimeStamp} '
      //     'now=$now '
      //     'shouldShiftOneFrameForInterestVsyncTarget=$shouldShiftOneFrameForInterestVsyncTarget '
      //     'set-interestVsyncTargetTimeByLastPreemptRender=$interestVsyncTargetTimeByLastPreemptRender');

      // ref: https://github.com/fzyzcjy/yplusplus/issues/5780#issuecomment-1254562485
      // ref: RenderView.compositeFrame

      assert(ServiceLocator.instance.preemptStrategy.shouldAct());
      ServiceLocator.instance.preemptStrategy.refresh();

      final smoothFrameTimeStamp =
          ServiceLocator.instance.preemptStrategy.currentSmoothFrameTimeStamp;
      _preemptModifyLayerTree(smoothFrameTimeStamp);

      final builder = SceneBuilder();
      // why this layer - from RenderView.compositeFrame
      // ignore: invalid_use_of_protected_member
      final scene = binding.renderView.layer!.buildScene(builder);

      Timeline.timeSync('window.render', () {
        // print(
        //     'call window.render (now=${DateTime.now()}, stopwatch=${stopwatch.elapsed})');
        WidgetsBinding.instance.window.render(scene);
      });

      scene.dispose();

      // #5831
      // // #5822
      // binding.platformDispatcher.preemptRequestVsync();
    });
    _times.add(clock.now().difference(start));

    // print('$runtimeType preemptRender end');
  }

  void _preemptModifyLayerTree(Duration timeStamp) {
    for (final pack in ServiceLocator.instance.auxiliaryTreeRegistry.trees) {
      pack.runPipeline(
        timeStamp,
        skipIfTimeStampUnchanged: false,
        debugReason: 'preemptModifyLayerTree',
      );
    }
  }
}
