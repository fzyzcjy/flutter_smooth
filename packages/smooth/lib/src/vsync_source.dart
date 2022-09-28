import 'package:flutter/scheduler.dart';
import 'package:smooth/src/scheduler_binding.dart';
import 'package:smooth/src/simple_date_time.dart';

// TODO not proper to name as "VsyncSource"?
abstract class VsyncSource {
  const factory VsyncSource.real() = _VsyncSourceReal;

  /// Just [SchedulerBinding.currentFrameTimeStamp], but mockable
  Duration get currentFrameTimeStamp;

  /// Converting between a [DateTime] (representing real-world time)
  /// and a "TimeStamp" like [SchedulerBinding.currentFrameTimeStamp]
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
      _currentFrameVsyncTargetTimeStamp.inMicroseconds;

  /// The current VsyncTargetTime
  // TODO explain things below
  // p.s. Look at source code, we see:
  // 1. [currentSystemFrameTimeStamp] is VsyncTargetTime
  // 2. [currentFrameTimeStamp] is the adjusted [currentSystemFrameTimeStamp]
  // 3. [currentFrameTimeStamp] is provided to animation callbacks
  Duration get _currentFrameVsyncTargetTimeStamp =>
      _binding.currentFrameTimeStamp;

  DateTime get _currentFrameVsyncTargetDateTime =>
      // TODO explain why one frame
      _binding.beginFrameDateTime.add(SmoothSchedulerBindingMixin.kOneFrame);

  SmoothSchedulerBindingMixin get _binding =>
      SmoothSchedulerBindingMixin.instance;

  @override
  Duration get currentFrameTimeStamp => _binding.currentFrameTimeStamp;
}
