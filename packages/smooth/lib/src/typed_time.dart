import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth/src/duration.dart';

abstract class _AdjustedFrameTimeStampCoord {}

/// Such as the [SchedulerBinding.currentFrameTimeStamp]
typedef AdjustedFrameTimeStamp = DurationT<_AdjustedFrameTimeStampCoord>;

abstract class _SystemFrameTimeStampCoord {}

/// Such as the [SchedulerBinding.currentSystemFrameTimeStamp]
typedef SystemFrameTimeStamp = DurationT<_SystemFrameTimeStampCoord>;

abstract class _PointerEventTimeStampCoord {}

/// Such as the [PointerEvent.timeStamp]
typedef PointerEventTimeStamp = DurationT<_PointerEventTimeStampCoord>;

extension ExtSchedulerBindingTimeConverter on SchedulerBinding {
  AdjustedFrameTimeStamp get currentFrameTimeStampTyped =>
      AdjustedFrameTimeStamp.uncheckedFrom(currentFrameTimeStamp);

  SystemFrameTimeStamp get currentSystemFrameTimeStampTyped =>
      SystemFrameTimeStamp.uncheckedFrom(currentSystemFrameTimeStamp);
}
