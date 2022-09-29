import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth/src/simple_date_time.dart';

abstract class PreemptStrategy {
  factory PreemptStrategy.normal() = PreemptStrategyNormal;

  const factory PreemptStrategy.never() = _PreemptStrategyNever;

  /// Should we run `preemptRender` now
  bool shouldAct({Object? debugToken});

  /// Fancy version of [SchedulerBinding.currentFrameTimeStamp],
  /// by considering both plain-old frames and *also extra frames*
  Duration get currentSmoothFrameTimeStamp;

  /// Be called when `preemptRender` is run
  void refresh();
}

class PreemptStrategyDependency {
  const PreemptStrategyDependency();

  SimpleDateTime now() => clock.nowSimple();

  Duration get currentFrameTimeStamp =>
      SmoothSchedulerBindingMixin.instance.currentFrameTimeStamp;

  DateTime get beginFrameDateTime =>
      SmoothSchedulerBindingMixin.instance.beginFrameDateTime;
}

@visibleForTesting
class PreemptStrategyNormal implements PreemptStrategy {
  final PreemptStrategyDependency dependency;
  final _TimeInfoCalculator _timeInfoCalculator;

  /// the VsyncTargetTime used by last preempt render
  var _currentPreemptRenderVsyncTargetTimeStamp =
      const Duration(seconds: -10000);

  PreemptStrategyNormal({
    this.dependency = const PreemptStrategyDependency(),
  }) : _timeInfoCalculator = _TimeInfoCalculator(dependency);

  @override
  bool shouldAct({Object? debugToken}) {
    final now = dependency.now();
    final nowTimeStamp = _timeInfoCalculator.dateTimeToTimeStamp(now);
    final ans = nowTimeStamp > shouldActTimeStamp;

    if (ans) {
      print(
        'shouldAct=true '
        'now=$now nowTimeStamp=$nowTimeStamp '
        'shouldActTimeStamp=$shouldActTimeStamp '
        'currentSmoothFrameTimeStamp=$currentSmoothFrameTimeStamp '
        'currentFrameAdjustedVsyncTargetTimeStamp=${_timeInfoCalculator.currentFrameAdjustedVsyncTargetTimeStamp} '
        'currentPreemptRenderVsyncTargetTimeStamp=$_currentPreemptRenderVsyncTargetTimeStamp',
      );
    }

    return ans;
  }

  // this threshold is not sensitive. see design doc.
  static const kActThresh = Duration(milliseconds: 2);

  Duration get shouldActTimeStamp {
    final nextActVsyncTimeStamp = _maxDuration(
      _timeInfoCalculator.currentFrameAdjustedVsyncTargetTimeStamp,
      _currentPreemptRenderVsyncTargetTimeStamp + kOneFrame,
    );
    return nextActVsyncTimeStamp - kActThresh;
  }

  @override
  Duration get currentSmoothFrameTimeStamp {
    return _maxDuration(
      _timeInfoCalculator.currentFrameAdjustedVsyncTargetTimeStamp,
      _currentPreemptRenderVsyncTargetTimeStamp,
    );
  }

  @override
  void refresh() {
    assert(
        shouldAct(),
        'When call `refresh`, should have `shouldAct`=true, '
        'otherwise the preemptRender should not happen');

    final now = dependency.now();
    final nowTimeStamp = _timeInfoCalculator.dateTimeToTimeStamp(now);

    final nextVsync = vsyncLaterThan(
      time: nowTimeStamp,
      baseVsync: _timeInfoCalculator.currentFrameAdjustedVsyncTargetTimeStamp,
    );

    final shouldShiftOneFrame =
        nextVsync - nowTimeStamp > const Duration(milliseconds: 12);

    _currentPreemptRenderVsyncTargetTimeStamp =
        nextVsync - (shouldShiftOneFrame ? kOneFrame : Duration.zero);
  }

  @visibleForTesting
  static Duration vsyncLaterThan({
    required Duration time,
    required Duration baseVsync,
  }) {
    final diffMicroseconds = time.inMicroseconds - baseVsync.inMicroseconds;
    return baseVsync +
        Duration(
          microseconds: (diffMicroseconds / kOneFrameUs).ceil() * kOneFrameUs,
        );
  }
}

Duration _maxDuration(Duration a, Duration b) => a > b ? a : b;

class _TimeInfoCalculator {
  final PreemptStrategyDependency dependency;

  const _TimeInfoCalculator(this.dependency);

  /// The adjusted VsyncTargetTime for current plain-old frame
  /// "adjust" means [SchedulerBinding._adjustForEpoch]
  Duration get currentFrameAdjustedVsyncTargetTimeStamp {
    // we can obtain current plain-old frame's VsyncTargetTime
    // easily because it is exposed as follows by looking at source code:
    // 1. [currentSystemFrameTimeStamp] is VsyncTargetTime
    // 2. [currentFrameTimeStamp] is the adjusted [currentSystemFrameTimeStamp]
    // 3. [currentFrameTimeStamp] is provided to animation callbacks
    return dependency.currentFrameTimeStamp;
  }

  /// Converting between a [DateTime] (representing real-world time)
  /// and an "adjusted TimeStamp" such as [SchedulerBinding.currentFrameTimeStamp]
  int get diffDateTimeToTimeStamp =>
      _currentFrameVsyncTargetDateTime.microsecondsSinceEpoch -
      currentFrameAdjustedVsyncTargetTimeStamp.inMicroseconds;

  // we need to *add one frame*, because [(adjusted) VsyncTargetTime] means
  // the end of current plain-old frame, while [beginFrameDateTime] means
  // the clock when plain-old frame starts.
  DateTime get _currentFrameVsyncTargetDateTime =>
      // NOTE this add one frame
      dependency.beginFrameDateTime.add(kOneFrame);

  // SimpleDateTime timeStampToDateTime(Duration timeStamp) =>
  //     SimpleDateTime.fromMicrosecondsSinceEpoch(
  //         timeStamp.inMicroseconds + diffDateTimeToTimeStamp);

  Duration dateTimeToTimeStamp(SimpleDateTime dateTime) => Duration(
      microseconds: dateTime.microsecondsSinceEpoch - diffDateTimeToTimeStamp);
}

class _PreemptStrategyNever implements PreemptStrategy {
  const _PreemptStrategyNever();

  @override
  bool shouldAct({Object? debugToken}) => false;

  @override
  void refresh() {}

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
//   void refresh() {
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
