import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/scheduler_binding.dart';
import 'package:smooth/src/simple_date_time.dart';
import 'package:smooth/src/vsync_source.dart';

abstract class PreemptStrategy {
  factory PreemptStrategy.normal({required VsyncSource vsyncSource}) =
      PreemptStrategyNormal;

  const factory PreemptStrategy.never() = _PreemptStrategyNever;

  /// Should we run `preemptRender` now
  bool get shouldAct;

  /// Fancy version of [SchedulerBinding.currentFrameTimeStamp],
  /// by considering both plain-old frames and *also extra frames*
  Duration get currentSmoothFrameTimeStamp;

  /// Be called when `preemptRender` is run
  void onPreemptRender();
}

@visibleForTesting
class PreemptStrategyNormal implements PreemptStrategy {
  final VsyncSource vsyncSource;

  /// the VsyncTargetTime used by last preempt render
  var _currentPreemptRenderVsyncTargetTimeStamp = Duration.zero;
  var _nextActAdjustedVsyncTimeStampByPreemptRender = Duration.zero;

  PreemptStrategyNormal({required this.vsyncSource});

  @override
  bool get shouldAct {
    final now = SimpleDateTime.now();
    final ans = vsyncSource.dateTimeToTimeStamp(now) > shouldActTimeStamp;

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
    // TODO things below can also be cached

    final nextActVsyncTimeStampByJankFrame =
        vsyncSource.currentFrameAdjustedVsyncTargetTimeStamp;

    final nextActVsyncTimeStamp = _maxDuration(
      nextActVsyncTimeStampByJankFrame,
      _nextActAdjustedVsyncTimeStampByPreemptRender,
    );

    return nextActVsyncTimeStamp - _kThresh;
  }

  @override
  Duration get currentSmoothFrameTimeStamp {
    return _maxDuration(
      vsyncSource.currentFrameAdjustedVsyncTargetTimeStamp,
      _currentPreemptRenderVsyncTargetTimeStamp,
    );
  }

  @override
  void onPreemptRender() {
    final now = SimpleDateTime.now();
    final nowTimeStamp = vsyncSource.dateTimeToTimeStamp(now);

    final currentPreemptRenderVsyncTargetTimeStamp = vsyncLaterThan(
      time: nowTimeStamp,
      baseVsync: _currentPreemptRenderVsyncTargetTimeStamp,
    );

    final shouldShiftOneFrameForNextActVsyncTime =
        nowTimeStamp - currentPreemptRenderVsyncTargetTimeStamp >
            const Duration(milliseconds: -4);

    _currentPreemptRenderVsyncTargetTimeStamp =
        currentPreemptRenderVsyncTargetTimeStamp;
    _nextActAdjustedVsyncTimeStampByPreemptRender =
        currentPreemptRenderVsyncTargetTimeStamp +
            (shouldShiftOneFrameForNextActVsyncTime
                ? SmoothSchedulerBindingMixin.kOneFrame
                : Duration.zero);
  }

  @visibleForTesting
  static Duration vsyncLaterThan({
    required Duration time,
    required Duration baseVsync,
  }) {
    final diffMicroseconds = time.inMicroseconds - baseVsync.inMicroseconds;
    const oneFrameUs = SmoothSchedulerBindingMixin.kOneFrameUs;
    return baseVsync +
        Duration(
          microseconds: (diffMicroseconds ~/ oneFrameUs) * oneFrameUs,
        );
  }
}

Duration _maxDuration(Duration a, Duration b) => a > b ? a : b;

class _PreemptStrategyNever implements PreemptStrategy {
  const _PreemptStrategyNever();

  @override
  bool get shouldAct => false;

  @override
  void onPreemptRender() {}

  @override
  Duration get currentSmoothFrameTimeStamp =>
      SchedulerBinding.instance.currentFrameTimeStamp;
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
