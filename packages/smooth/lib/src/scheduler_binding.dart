import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/simple_date_time.dart';

mixin SmoothSchedulerBindingMixin on SchedulerBinding {
  SimpleDateTime get lastHandleBeginFrameTime => _lastHandleBeginFrameTime!;
  SimpleDateTime? _lastHandleBeginFrameTime;

  int get _diffDateTimeToTimeStampUs =>
      _lastHandleBeginFrameTime!.microsecondsSinceEpoch -
      currentFrameTimeStamp.inMicroseconds;

  SimpleDateTime timeStampToDateTime(Duration timeStamp) =>
      SimpleDateTime.fromMicrosecondsSinceEpoch(
          timeStamp.inMicroseconds + _diffDateTimeToTimeStampUs);

  Duration dateTimeToTimeStamp(SimpleDateTime dateTime) => Duration(
      microseconds:
          dateTime.microsecondsSinceEpoch - _diffDateTimeToTimeStampUs);

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    _lastHandleBeginFrameTime = SimpleDateTime.now();

    super.handleBeginFrame(rawTimeStamp);
  }

  static SmoothSchedulerBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothSchedulerBindingMixin,
        'Please use a WidgetsBinding with SmoothSchedulerBindingMixin');
    return raw as SmoothSchedulerBindingMixin;
  }

  // TODO make it non-const
  static const kFps = 60;
  static const kOneFrameUs = 1000000 ~/ SmoothSchedulerBindingMixin.kFps;
  static const kOneFrame = Duration(microseconds: kOneFrameUs);
}

// ref [AutomatedTestWidgetsFlutterBinding]
class SmoothWidgetsFlutterBinding extends WidgetsFlutterBinding
    with SmoothSchedulerBindingMixin {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SmoothWidgetsFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);
  static SmoothWidgetsFlutterBinding? _instance;

  // ignore: prefer_constructors_over_static_methods
  static SmoothWidgetsFlutterBinding ensureInitialized() {
    if (SmoothWidgetsFlutterBinding._instance == null) {
      SmoothWidgetsFlutterBinding();
    }
    return SmoothWidgetsFlutterBinding.instance;
  }
}
