import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth/src/infra/time/duration.dart';

abstract class _AdjustedFrameTimeStampCoord {}

/// Such as the [SchedulerBinding.currentFrameTimeStamp]
typedef AdjustedFrameTimeStamp = DurationT<_AdjustedFrameTimeStampCoord>;

extension ExtAdjustedFrameTimeStamp on AdjustedFrameTimeStamp {
  Duration get innerAdjustedFrameTimeStamp =>
      Duration(microseconds: inMicroseconds);
}

abstract class _SystemFrameTimeStampCoord {}

/// Such as the [SchedulerBinding.currentSystemFrameTimeStamp]
typedef SystemFrameTimeStamp = DurationT<_SystemFrameTimeStampCoord>;

extension ExtSystemFrameTimeStamp on SystemFrameTimeStamp {
  Duration get innerSystemFrameTimeStamp =>
      Duration(microseconds: inMicroseconds);
}

abstract class _PointerEventTimeStampCoord {}

/// Such as the [PointerEvent.timeStamp]
typedef PointerEventTimeStamp = DurationT<_PointerEventTimeStampCoord>;

extension ExtPointerEventTimeStamp on PointerEventTimeStamp {
  Duration get innerPointerEventTimeStamp =>
      Duration(microseconds: inMicroseconds);
}

extension ExtSchedulerBindingTime on SchedulerBinding {
  AdjustedFrameTimeStamp get currentFrameTimeStampTyped =>
      AdjustedFrameTimeStamp.uncheckedFrom(currentFrameTimeStamp);

  SystemFrameTimeStamp get currentSystemFrameTimeStampTyped =>
      SystemFrameTimeStamp.uncheckedFrom(currentSystemFrameTimeStamp);
}

extension ExtPointerEventTime on PointerEvent {
  PointerEventTimeStamp get timeStampTyped =>
      PointerEventTimeStamp.uncheckedFrom(timeStamp);
}
