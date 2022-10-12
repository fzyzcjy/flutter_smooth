import 'package:clock/clock.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth/src/phase.dart';
import 'package:smooth/src/simple_date_time.dart';
import 'package:smooth/src/time_converter.dart';

class TimeManager {
  final TimeManagerDependency dependency;

  TimeManager([this.dependency = const TimeManagerDependency()]);

  SmoothFramePhase get phase => TODO;

  /// Fancy version of [SchedulerBinding.currentFrameTimeStamp],
  /// by considering both plain-old frames and *also extra frames*
  Duration get currentSmoothFrameTimeStamp => TODO;

  /// If return non-null, means should preempt render
  Duration? onBuildOrLayoutPhaseMaybePreemptRender() => TODO;

  Duration? onAfterDrawFramePhaseMaybePreemptRender() => TODO;
}

class TimeManagerDependency {
  const TimeManagerDependency();

  Duration get nowTimeStamp => TimeConverter.instance
      .dateTimeToAdjustedFrameTimeStamp(clock.nowSimple());

  Duration get currentFrameTimeStamp =>
      SmoothSchedulerBindingMixin.instance.currentFrameTimeStamp;
}
