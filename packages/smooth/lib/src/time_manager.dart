import 'package:clock/clock.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth/src/simple_date_time.dart';
import 'package:smooth/src/time_converter.dart';

class TimeManager {
  final TimeManagerDependency dependency;

  TimeManager([this.dependency = const TimeManagerDependency()]);
}

class TimeManagerDependency {
  const TimeManagerDependency();

  Duration get nowTimeStamp => TimeConverter.instance
      .dateTimeToAdjustedFrameTimeStamp(clock.nowSimple());

  Duration get currentFrameTimeStamp =>
      SmoothSchedulerBindingMixin.instance.currentFrameTimeStamp;
}
