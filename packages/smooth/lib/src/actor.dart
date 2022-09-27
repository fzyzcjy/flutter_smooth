import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth/src/auxiliary_tree.dart';
import 'package:smooth/src/service_locator.dart';

class Actor {
  int? diffDateTimeTimePoint;
  var interestVsyncTargetTimeByLastPreemptRender = 0;

  // var _maybePreemptRenderCallCount = 0;

  final _times = <Duration>[];

  void debugPrintStat() {
    print(
        'PreemptRender times=[${_times.map((d) => d.inMicroseconds / 1000).toList().join(', ')}]');
  }

  void maybePreemptRender() {
    if (ServiceLocator.instance.auxiliaryTreeRegistry.trees.isEmpty) {
      // No active smooth widgets
      return;
    }

    // _maybePreemptRenderCallCount++;

    if (_shouldAct()) {
      preemptRender();
    }
  }

  bool _shouldAct() {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    // e.g. set to 1ms
    // this threshold is not sensitive. see design doc.
    const kThreshUs = 2 * 1000;

    diffDateTimeTimePoint ??= binding.lastVsyncInfo().diffDateTimeTimePoint;

    // TODO things below can also be cached

    // look at source code, that timestamp is indeed VsyncTargetTime
    final lastJankFrameVsyncTargetTime =
        binding.currentSystemFrameTimeStamp.inMicroseconds;
    // final lastPreemptFrameVsyncTargetTime =
    //     lastVsyncInfoWhenPreviousPreemptRender!
    //         .vsyncTargetTimeRaw.inMicroseconds;
    // final interestVsyncTargetTime =
    //     max(lastJankFrameVsyncTargetTime, lastPreemptFrameVsyncTargetTime);
    // final interestVsyncTargetDateTimeUs = interestVsyncTargetTime +
    //     lastVsyncInfoWhenPreviousPreemptRender!.diffDateTimeTimePoint;
    // final interestNextVsyncTargetDateTimeUs =
    //     interestVsyncTargetDateTimeUs + 1000000 ~/ 60;

    final interestVsyncTargetTime = max(lastJankFrameVsyncTargetTime,
        interestVsyncTargetTimeByLastPreemptRender);

    final interestVsyncTargetDateTimeUs =
        interestVsyncTargetTime + diffDateTimeTimePoint!;

    final nowDateTimeUs = DateTime.now().microsecondsSinceEpoch;

    final ans = nowDateTimeUs > interestVsyncTargetDateTimeUs - kThreshUs;

    // if (ans) {
    //   print('shouldAct=true '
    //       'now=${DateTime.fromMicrosecondsSinceEpoch(nowDateTimeUs)} '
    //       'interestVsyncTargetDateTimeUs=${DateTime.fromMicrosecondsSinceEpoch(interestVsyncTargetDateTimeUs)} '
    //       'maybePreemptRenderCallCount=$_maybePreemptRenderCallCount');
    // }

    return ans;
  }

  static const _kOneFrameUs = 1000000 ~/ 60;

  void preemptRender() {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    final start = DateTime.now();
    Timeline.timeSync('PreemptRender', () {
      // print('$runtimeType preemptRender start');

      // NOTE this read may take some time
      final lastVsyncInfo = binding.lastVsyncInfo();
      final now = DateTime.now();

      final shouldShiftOneFrameForInterestVsyncTarget =
          now.difference(lastVsyncInfo.vsyncTargetDateTime) >
              const Duration(milliseconds: -4);

      diffDateTimeTimePoint = lastVsyncInfo.diffDateTimeTimePoint;
      interestVsyncTargetTimeByLastPreemptRender =
          lastVsyncInfo.vsyncTargetTimeRaw.inMicroseconds +
              (shouldShiftOneFrameForInterestVsyncTarget ? _kOneFrameUs : 0);

      // print('preemptRender '
      //     'lastVsyncInfo=$lastVsyncInfo '
      //     'currentFrameTimeStamp=${binding.currentFrameTimeStamp} '
      //     'now=$now '
      //     'shouldShiftOneFrameForInterestVsyncTarget=$shouldShiftOneFrameForInterestVsyncTarget '
      //     'set-interestVsyncTargetTimeByLastPreemptRender=$interestVsyncTargetTimeByLastPreemptRender');

      // ref: https://github.com/fzyzcjy/yplusplus/issues/5780#issuecomment-1254562485
      // ref: RenderView.compositeFrame

      final builder = SceneBuilder();

      preemptModifyLayerTree(lastVsyncInfo.vsyncTargetTimeAdjusted);

      // why this layer - from RenderView.compositeFrame
      // ignore: invalid_use_of_protected_member
      final scene = binding.renderView.layer!.buildScene(builder);

      Timeline.timeSync('window.render', () {
        // print(
        //     'call window.render (now=${DateTime.now()}, stopwatch=${stopwatch.elapsed})');
        window.render(scene);
      });

      scene.dispose();

      // #5831
      // // #5822
      // binding.platformDispatcher.preemptRequestVsync();
    });
    _times.add(DateTime.now().difference(start));

    // print('$runtimeType preemptRender end');
  }

  void preemptModifyLayerTree(Duration timeStamp) {
    for (final pack in ServiceLocator.instance.auxiliaryTreeRegistry.trees) {
      pack.runPipeline(timeStamp, debugReason: 'preemptModifyLayerTree');
    }
  }
}
