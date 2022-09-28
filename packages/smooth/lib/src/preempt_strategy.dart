import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/scheduler_binding.dart';
import 'package:smooth/src/simple_date_time.dart';

abstract class PreemptStrategy {
  factory PreemptStrategy.normal() = PreemptStrategyNormal;

  const factory PreemptStrategy.never() = _PreemptStrategyNever;

  bool get shouldAct;

  Duration get currentVsyncTargetTime;

  void onPreemptRender();
}

@visibleForTesting
class PreemptStrategyNormal implements PreemptStrategy {
  var _currentPreemptRenderVsyncTargetTime = SimpleDateTime.zero;
  var _nextActVsyncTimeByPreemptRender = SimpleDateTime.zero;

  PreemptStrategyNormal();

  @override
  bool get shouldAct {
    final binding = SmoothSchedulerBindingMixin.instance;

    final now = SimpleDateTime.now();
    final ans = binding.dateTimeToTimeStamp(now) > shouldActTimeStamp;

    // if (ans) {
    //   print('shouldAct=true '
    //       'now=${clock.fromMicrosecondsSinceEpoch(nowDateTimeUs)} '
    //       'interestVsyncTargetDateTimeUs=${clock.fromMicrosecondsSinceEpoch(interestVsyncTargetDateTimeUs)} '
    //       'maybePreemptRenderCallCount=$_maybePreemptRenderCallCount');
    // }

    return ans;
  }

  // this threshold is not sensitive. see design doc.
  static const _kThresh = Duration(milliseconds: 2);

  Duration get shouldActTimeStamp {
    final binding = SmoothSchedulerBindingMixin.instance;
    // TODO things below can also be cached

    final nextActVsyncTimeByJankFrame = binding.lastHandleBeginFrameTime
        .add(SmoothSchedulerBindingMixin.kOneFrame);

    final nextActVsyncTime = maxSimpleDateTime(
      nextActVsyncTimeByJankFrame,
      _nextActVsyncTimeByPreemptRender,
    );

    return binding.dateTimeToTimeStamp(nextActVsyncTime) - _kThresh;
  }

  /// Fancy version of [SmoothSchedulerBindingMixin.currentFrameVsyncTargetTimeStamp],
  /// by considering preempt frames
  @override
  Duration get currentVsyncTargetTime {
    final binding = SmoothSchedulerBindingMixin.instance;
    return binding.dateTimeToTimeStamp(maxSimpleDateTime(
      TODO_binding.currentFrameVsyncTargetTimeStamp,
      _currentPreemptRenderVsyncTargetTime,
    ));
  }

  @override
  void onPreemptRender() {
    final binding = SmoothSchedulerBindingMixin.instance;
    final now = SimpleDateTime.now();
    final nowTimeStamp = binding.dateTimeToTimeStamp(now);

    final currentPreemptRenderVsyncTargetTimeStamp = vsyncLaterThan(
      time: nowTimeStamp,
      oldVsync: _currentPreemptRenderVsyncTargetTime,
    );

    final shouldShiftOneFrameForNextActVsyncTime =
        nowTimeStamp - currentPreemptRenderVsyncTargetTimeStamp >
            const Duration(milliseconds: -4);

    _currentPreemptRenderVsyncTargetTime =
        currentPreemptRenderVsyncTargetTimeStamp;
    _nextActVsyncTimeByPreemptRender =
        currentPreemptRenderVsyncTargetTimeStamp +
            (shouldShiftOneFrameForNextActVsyncTime
                ? SmoothSchedulerBindingMixin.kOneFrame
                : Duration.zero);
  }

  @visibleForTesting
  static Duration vsyncLaterThan({
    required Duration time,
    required Duration oldVsync,
  }) {
    assert(time >= oldVsync);
    final diffMicroseconds = time.inMicroseconds - oldVsync.inMicroseconds;
    const oneFrameUs = SmoothSchedulerBindingMixin.kOneFrameUs;
    return oldVsync +
        Duration(
          microseconds: (diffMicroseconds ~/ oneFrameUs) * oneFrameUs,
        );
  }
}

// #31 changes it
// class _PreemptStrategyNormal implements PreemptStrategy {
//   int? diffDateTimeTimePoint;
//   var interestVsyncTargetTimeByLastPreemptRender = 0;
//
//   _PreemptStrategyNormal();
//
//   @override
//   bool shouldAct() {
//     final binding = WidgetsFlutterBinding.ensureInitialized();
//
//     // e.g. set to 1ms
//     // this threshold is not sensitive. see design doc.
//     const kThreshUs = 2 * 1000;
//
//     diffDateTimeTimePoint ??= binding.lastVsyncInfo().diffDateTimeTimePoint;
//
//     // TODO things below can also be cached
//
//     // look at source code, that timestamp is indeed VsyncTargetTime
//     final lastJankFrameVsyncTargetTime =
//         binding.currentSystemFrameTimeStamp.inMicroseconds;
//     // final lastPreemptFrameVsyncTargetTime =
//     //     lastVsyncInfoWhenPreviousPreemptRender!
//     //         .vsyncTargetTimeRaw.inMicroseconds;
//     // final interestVsyncTargetTime =
//     //     max(lastJankFrameVsyncTargetTime, lastPreemptFrameVsyncTargetTime);
//     // final interestVsyncTargetDateTimeUs = interestVsyncTargetTime +
//     //     lastVsyncInfoWhenPreviousPreemptRender!.diffDateTimeTimePoint;
//     // final interestNextVsyncTargetDateTimeUs =
//     //     interestVsyncTargetDateTimeUs + 1000000 ~/ 60;
//
//     final interestVsyncTargetTime = max(lastJankFrameVsyncTargetTime,
//         interestVsyncTargetTimeByLastPreemptRender);
//
//     final interestVsyncTargetDateTimeUs =
//         interestVsyncTargetTime + diffDateTimeTimePoint!;
//
//     final nowDateTimeUs = DateTime.now().microsecondsSinceEpoch;
//
//     final ans = nowDateTimeUs > interestVsyncTargetDateTimeUs - kThreshUs;
//
//     // if (ans) {
//     //   print('shouldAct=true '
//     //       'now=${DateTime.fromMicrosecondsSinceEpoch(nowDateTimeUs)} '
//     //       'interestVsyncTargetDateTimeUs=${DateTime.fromMicrosecondsSinceEpoch(interestVsyncTargetDateTimeUs)} '
//     //       'maybePreemptRenderCallCount=$_maybePreemptRenderCallCount');
//     // }
//
//     return ans;
//   }
//
//   @override
//   Duration get currentVsyncTargetTime =>
//       // TODO dup call to `lastVsyncInfo` here
//       SchedulerBinding.instance.lastVsyncInfo().vsyncTargetTimeAdjusted;
//
//   @override
//   void onPreemptRender() {
//     // NOTE this may be slow; and has duplicate call here
//     final lastVsyncInfo = SchedulerBinding.instance.lastVsyncInfo();
//
//     final now = DateTime.now();
//
//     final shouldShiftOneFrameForInterestVsyncTarget =
//         now.difference(lastVsyncInfo.vsyncTargetDateTime) >
//             const Duration(milliseconds: -4);
//
//     diffDateTimeTimePoint = lastVsyncInfo.diffDateTimeTimePoint;
//     interestVsyncTargetTimeByLastPreemptRender =
//         lastVsyncInfo.vsyncTargetTimeRaw.inMicroseconds +
//             (shouldShiftOneFrameForInterestVsyncTarget ? _kOneFrameUs : 0);
//   }
//
//   static const _kOneFrameUs = 1000000 ~/ 60;
// }

class _PreemptStrategyNever implements PreemptStrategy {
  const _PreemptStrategyNever();

  @override
  bool get shouldAct => false;

  @override
  void onPreemptRender() {}

  @override
  Duration get currentVsyncTargetTime =>
      SchedulerBinding.instance.currentFrameTimeStamp;
}
