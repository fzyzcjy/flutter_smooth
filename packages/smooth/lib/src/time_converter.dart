import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';

// TODO maybe improve
class TimeConverter {
  static final instance = TimeConverter._();

  TimeConverter._() {
    Timer.periodic(const Duration(seconds: 1), (_) {
      _diffDateTimeToTimeStamp = _readDiffDateTimeToTimeStamp();
    });
  }

  int get diffDateTimeToTimeStamp =>
      _diffDateTimeToTimeStamp ??= _readDiffDateTimeToTimeStamp();
  int? _diffDateTimeToTimeStamp;

  static int _readDiffDateTimeToTimeStamp() {
    // why this is correct: #6120
    final dateTime = clock.now().microsecondsSinceEpoch;
    final timeStamp = Timeline.now;
    return dateTime - timeStamp;
  }
}
