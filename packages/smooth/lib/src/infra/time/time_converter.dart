import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/infra/host_api/messages.dart';
import 'package:smooth/src/infra/time/simple_date_time.dart';
import 'package:smooth/src/infra/time/typed_time.dart';

/// See docs time.md for detailed descriptions
abstract class TimeConverter {
  factory TimeConverter() = _TimeConverterNormal;

  const TimeConverter.raw();

  SystemFrameTimeStamp adjustedToSystemFrameTimeStamp(
          AdjustedFrameTimeStamp t) =>
      SystemFrameTimeStamp.unchecked(
          microseconds: t.inMicroseconds + _diffSystemToAdjustedFrameTimeStamp);

  AdjustedFrameTimeStamp dateTimeToAdjustedFrameTimeStamp(SimpleDateTime t) =>
      AdjustedFrameTimeStamp.unchecked(
          microseconds:
              t.microsecondsSinceEpoch - _diffDateTimeToAdjustedFrameTimeStamp);

  SimpleDateTime adjustedFrameTimeStampToDateTime(AdjustedFrameTimeStamp d) =>
      SimpleDateTime.fromMicrosecondsSinceEpoch(
          d.inMicroseconds + _diffDateTimeToAdjustedFrameTimeStamp);

  PointerEventTimeStamp? dateTimeToPointerEventTimeStamp(SimpleDateTime d) {
    final diff = diffDateTimeToPointerEventTimeStamp;
    if (diff == null) return null;
    return PointerEventTimeStamp.unchecked(
        microseconds: d.microsecondsSinceEpoch - diff);
  }

  SimpleDateTime? pointerEventTimeStampToDateTime(PointerEventTimeStamp d) {
    final diff = diffDateTimeToPointerEventTimeStamp;
    if (diff == null) return null;
    return SimpleDateTime.fromMicrosecondsSinceEpoch(d.inMicroseconds + diff);
  }

  int get _diffSystemToAdjustedFrameTimeStamp =>
      _SystemToAdjustedFrameTimeStampConverter
          .diffSystemToAdjustedFrameTimeStamp;

  int get _diffDateTimeToAdjustedFrameTimeStamp =>
      diffDateTimeToSystemFrameTimeStamp + _diffSystemToAdjustedFrameTimeStamp;

  @protected
  int get diffDateTimeToSystemFrameTimeStamp;

  @protected
  int? get diffDateTimeToPointerEventTimeStamp;
}

class _TimeConverterNormal extends TimeConverter {
  final _systemFrameTimeStampConverter = _SystemFrameTimeStampConverter();
  final _pointerEventTimeStampConverter = _PointerEventTimeStampConverter();

  _TimeConverterNormal() : super.raw();

  void dispose() {
    _systemFrameTimeStampConverter.dispose();
  }

  @override
  int get diffDateTimeToSystemFrameTimeStamp =>
      _systemFrameTimeStampConverter.diffDateTimeToSystemFrameTimeStamp;

  @override
  int? get diffDateTimeToPointerEventTimeStamp =>
      _pointerEventTimeStampConverter.diffDateTimeToPointerEventTimeStamp;
}

class _SystemFrameTimeStampConverter {
  late final Timer _timer;

  _SystemFrameTimeStampConverter()
      : _diffDateTimeToSystemFrameTimeStamp = _readDiffDateTimeToTimeStamp() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _diffDateTimeToSystemFrameTimeStamp = _readDiffDateTimeToTimeStamp();
    });
  }

  void dispose() {
    _timer.cancel();
  }

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

class _SystemToAdjustedFrameTimeStampConverter {
  static int get diffSystemToAdjustedFrameTimeStamp =>
      SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds -
      SchedulerBinding.instance.currentFrameTimeStamp.inMicroseconds;
}

class _PointerEventTimeStampConverter {
  _PointerEventTimeStampConverter() {
    _init();
  }

  Future<void> _init() async {
    _diffDateTimeToPointerEventTimeStamp =
        await SmoothHostApi().pointerEventDateTimeDiffTimeStamp();
  }

  int? get diffDateTimeToPointerEventTimeStamp =>
      _diffDateTimeToPointerEventTimeStamp;
  int? _diffDateTimeToPointerEventTimeStamp;
}
