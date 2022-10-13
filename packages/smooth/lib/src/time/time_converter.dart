import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/time/simple_date_time.dart';

// TODO maybe improve
class TimeConverter {
  late final Timer _timer;

  TimeConverter()
      : _diffDateTimeToSystemFrameTimeStamp = _readDiffDateTimeToTimeStamp() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _diffDateTimeToSystemFrameTimeStamp = _readDiffDateTimeToTimeStamp();
    });
  }

  void dispose() {
    _timer.cancel();
  }

  int get diffDateTimeToAdjustedFrameTimeStamp =>
      diffDateTimeToSystemFrameTimeStamp + diffSystemToAdjustedFrameTimeStamp;

  Duration dateTimeToAdjustedFrameTimeStamp(SimpleDateTime t) => Duration(
      microseconds:
          t.microsecondsSinceEpoch - diffDateTimeToAdjustedFrameTimeStamp);

  SimpleDateTime adjustedFrameTimeStampToDateTime(Duration d) =>
      SimpleDateTime.fromMicrosecondsSinceEpoch(
          d.inMicroseconds + diffDateTimeToAdjustedFrameTimeStamp);

  int get diffSystemToAdjustedFrameTimeStamp =>
      SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds -
      SchedulerBinding.instance.currentFrameTimeStamp.inMicroseconds;

  int get diffDateTimeToSystemFrameTimeStamp =>
      _diffDateTimeToSystemFrameTimeStamp;
  int _diffDateTimeToSystemFrameTimeStamp;

  static int _readDiffDateTimeToTimeStamp() {
    // why this is correct:
    // * #6120
    // * https://github.com/fzyzcjy/yplusplus/issues/6117#issuecomment-1272817402
    final dateTime = clock.now().microsecondsSinceEpoch;
    final timeStamp = Timeline.now;
    return dateTime - timeStamp;
  }
}
