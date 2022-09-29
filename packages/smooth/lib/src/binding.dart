import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

mixin SmoothSchedulerBindingMixin on SchedulerBinding {
  DateTime get beginFrameDateTime => _beginFrameDateTime!;
  DateTime? _beginFrameDateTime;

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    _beginFrameDateTime = clock.now();
    super.handleBeginFrame(rawTimeStamp);
  }

  static SmoothSchedulerBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothSchedulerBindingMixin,
        'Please use a WidgetsBinding with SmoothSchedulerBindingMixin');
    return raw as SmoothSchedulerBindingMixin;
  }
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

// TODO make FPS non-const (i.e. changeable according to different devices)
const kFps = 60;
const kOneFrameUs = 1000000 ~/ kFps;
const kOneFrame = Duration(microseconds: kOneFrameUs);
