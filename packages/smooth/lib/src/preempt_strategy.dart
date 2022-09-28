import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/scheduler_binding.dart';

abstract class PreemptStrategy {
  factory PreemptStrategy.normal() = PreemptStrategyNormal;

  const factory PreemptStrategy.never() = _PreemptStrategyNever;

  bool shouldAct();

  Duration get currentVsyncTargetTime;

  void onPreemptRender();
}

@visibleForTesting
class PreemptStrategyNormal implements PreemptStrategy {
  /// the VsyncTargetTime used by last preempt render
  var _currentPreemptRenderVsyncTargetTimeStamp = Duration.zero;
  var _nextActVsyncTimeStampByPreemptRender = Duration.zero;

  PreemptStrategyNormal();

  @override
  bool shouldAct() {
    final binding = SmoothSchedulerBindingMixin.instance;

    final now = _SimpleDateTime.now();
    final ans = binding.dateTimeToTimeStamp(now) > _shouldActTimeStamp;

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

  Duration get _shouldActTimeStamp {
    final binding = SmoothSchedulerBindingMixin.instance;
    // TODO things below can also be cached

    final nextActVsyncTimeStampByJankFrame =
        binding.currentFrameVsyncTargetTimeStamp;

    final nextActVsyncTimeStamp = _maxDuration(
      nextActVsyncTimeStampByJankFrame,
      _nextActVsyncTimeStampByPreemptRender,
    );

    return nextActVsyncTimeStamp - _kThresh;
  }

  /// Fancy version of [SmoothSchedulerBindingMixin.currentFrameVsyncTargetTimeStamp],
  /// by considering preempt frames
  @override
  Duration get currentVsyncTargetTime {
    final binding = SmoothSchedulerBindingMixin.instance;
    return _maxDuration(
      binding.currentFrameVsyncTargetTimeStamp,
      _currentPreemptRenderVsyncTargetTimeStamp,
    );
  }

  @override
  void onPreemptRender() {
    final binding = SmoothSchedulerBindingMixin.instance;
    final now = _SimpleDateTime.now();
    final nowTimeStamp = binding.dateTimeToTimeStamp(now);

    final currentPreemptRenderVsyncTargetTimeStamp = vsyncLaterThan(
      time: nowTimeStamp,
      oldVsync: _currentPreemptRenderVsyncTargetTimeStamp,
    );

    final shouldShiftOneFrameForNextActVsyncTime =
        nowTimeStamp - currentPreemptRenderVsyncTargetTimeStamp >
            const Duration(milliseconds: -4);

    _currentPreemptRenderVsyncTargetTimeStamp =
        currentPreemptRenderVsyncTargetTimeStamp;
    _nextActVsyncTimeStampByPreemptRender =
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

Duration _maxDuration(Duration a, Duration b) => a > b ? a : b;

extension on SmoothSchedulerBindingMixin {
  // _SimpleDateTime timeStampToDateTime(Duration timeStamp) =>
  //     _SimpleDateTime.fromMicrosecondsSinceEpoch(
  //         timeStamp.inMicroseconds + diffDateTimeToTimeStamp);

  Duration dateTimeToTimeStamp(_SimpleDateTime dateTime) => Duration(
      microseconds: dateTime.microsecondsSinceEpoch - diffDateTimeToTimeStamp);
}

/// [DateTime], but simpler (just a `int`)
class _SimpleDateTime {
  final int microsecondsSinceEpoch;

  _SimpleDateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch);

  _SimpleDateTime.now()
      : microsecondsSinceEpoch = clock.now().microsecondsSinceEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SimpleDateTime &&
          runtimeType == other.runtimeType &&
          microsecondsSinceEpoch == other.microsecondsSinceEpoch;

  @override
  int get hashCode => microsecondsSinceEpoch.hashCode;

  @override
  String toString() =>
      'SimpleDateTime{microsecondsSinceEpoch: $microsecondsSinceEpoch}';
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
  bool shouldAct() => false;

  @override
  void onPreemptRender() {}

  @override
  Duration get currentVsyncTargetTime =>
      SchedulerBinding.instance.currentFrameTimeStamp;
}
