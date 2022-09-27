import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

abstract class PreemptStrategy {
  factory PreemptStrategy.normal() = _PreemptStrategyNormal;

  const factory PreemptStrategy.never() = _PreemptStrategyNever;

  bool shouldAct();

  void onPreemptRender(AdjustedLastVsyncInfo lastVsyncInfo);
}

class _PreemptStrategyNormal implements PreemptStrategy {
  int? diffDateTimeTimePoint;
  var interestVsyncTargetTimeByLastPreemptRender = 0;

  _PreemptStrategyNormal();

  @override
  bool shouldAct() {
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

  @override
  void onPreemptRender(AdjustedLastVsyncInfo lastVsyncInfo) {
    final now = DateTime.now();

    final shouldShiftOneFrameForInterestVsyncTarget =
        now.difference(lastVsyncInfo.vsyncTargetDateTime) >
            const Duration(milliseconds: -4);

    diffDateTimeTimePoint = lastVsyncInfo.diffDateTimeTimePoint;
    interestVsyncTargetTimeByLastPreemptRender =
        lastVsyncInfo.vsyncTargetTimeRaw.inMicroseconds +
            (shouldShiftOneFrameForInterestVsyncTarget ? _kOneFrameUs : 0);
  }

  static const _kOneFrameUs = 1000000 ~/ 60;
}

class _PreemptStrategyNever implements PreemptStrategy {
  const _PreemptStrategyNever();

  @override
  bool shouldAct() => false;

  @override
  void onPreemptRender(AdjustedLastVsyncInfo lastVsyncInfo) {}
}
