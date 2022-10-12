import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:smooth/src/phase.dart';
import 'package:smooth/src/simple_date_time.dart';
import 'package:smooth/src/time_converter.dart';

class TimeManager {
  static const kActThresh = Duration(milliseconds: 2);

  final ValueGetter<Duration> nowTimeStamp;

  TimeManager({this.nowTimeStamp = _defaultNowTimeStamp});

  SmoothFramePhase get phase => TODO;

  /// Fancy version of [SchedulerBinding.currentFrameTimeStamp],
  /// by considering both plain-old frames and *also extra frames*
  Duration get currentSmoothFrameTimeStamp => TODO;

  @visibleForTesting
  Duration get shouldActOnBuildOrLayoutPhaseTimeStamp => TODO;

  void onBeginFrame(Duration currentFrameTimeStamp) => TODO;

  /// If return non-null, means should preempt render
  Duration? onBuildOrLayoutPhaseMaybePreemptRender() => TODO;

  Duration? onAfterDrawFramePhaseMaybePreemptRender() => TODO;
}

Duration _defaultNowTimeStamp() =>
    TimeConverter.instance.dateTimeToAdjustedFrameTimeStamp(clock.nowSimple());
