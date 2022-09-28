import 'package:flutter/scheduler.dart';
import 'package:smooth/src/scheduler_binding.dart';
import 'package:smooth/src/simple_date_time.dart';

// TODO not proper to name as "VsyncSource"?
abstract class VsyncSource {
  const factory VsyncSource.real() = _VsyncSourceReal;

  /// The adjusted VsyncTargetTime for current plain-old frame
  /// "adjust" means [SchedulerBinding._adjustForEpoch]
  Duration get currentFrameAdjustedVsyncTargetTimeStamp;

  /// Converting between a [DateTime] (representing real-world time)
  /// and an "adjusted TimeStamp" such as [SchedulerBinding.currentFrameTimeStamp]
  int get diffDateTimeToTimeStamp;
}

extension ExtVsyncSource on VsyncSource {
  // SimpleDateTime timeStampToDateTime(Duration timeStamp) =>
  //     SimpleDateTime.fromMicrosecondsSinceEpoch(
  //         timeStamp.inMicroseconds + diffDateTimeToTimeStamp);

  Duration dateTimeToTimeStamp(SimpleDateTime dateTime) => Duration(
      microseconds: dateTime.microsecondsSinceEpoch - diffDateTimeToTimeStamp);
}

/// *Only* work on real devices, *not* on Flutter widget test environments
/// because the "widget test" environment has fake `currentFrameTimeStamp`
class _VsyncSourceReal implements VsyncSource {
  const _VsyncSourceReal();

  @override
  int get diffDateTimeToTimeStamp =>
      _currentFrameVsyncTargetDateTime.microsecondsSinceEpoch -
      currentFrameAdjustedVsyncTargetTimeStamp.inMicroseconds;

  // we can obtain current plain-old frame's VsyncTargetTime
  // easily because it is exposed as follows by looking at source code:
  // 1. [currentSystemFrameTimeStamp] is VsyncTargetTime
  // 2. [currentFrameTimeStamp] is the adjusted [currentSystemFrameTimeStamp]
  // 3. [currentFrameTimeStamp] is provided to animation callbacks
  @override
  Duration get currentFrameAdjustedVsyncTargetTimeStamp =>
      _binding.currentFrameTimeStamp;

  // we need to *add one frame*, because [(adjusted) VsyncTargetTime] means
  // the end of current plain-old frame, while [beginFrameDateTime] means
  // the clock when plain-old frame starts.
  DateTime get _currentFrameVsyncTargetDateTime =>
      _binding.beginFrameDateTime.add(SmoothSchedulerBindingMixin.kOneFrame);

  SmoothSchedulerBindingMixin get _binding =>
      SmoothSchedulerBindingMixin.instance;
}
