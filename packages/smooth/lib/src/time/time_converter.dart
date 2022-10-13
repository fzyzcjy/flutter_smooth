import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/host_api/messages.dart';
import 'package:smooth/src/time/simple_date_time.dart';
import 'package:smooth/src/time/typed_time.dart';

abstract class TimeConverter {
  static const _systemToAdjustedFrameTimeStampConverter =
      _SystemToAdjustedFrameTimeStampConverter();

  factory TimeConverter.normal() = _TimeConverterNormal;

  factory TimeConverter.test() = _TimeConverterTest;

  const TimeConverter._();

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
    final diff = _diffDateTimeToPointerEventTimeStamp;
    if (diff == null) return null;
    return PointerEventTimeStamp.unchecked(
        microseconds: d.microsecondsSinceEpoch - diff);
  }

  SimpleDateTime? pointerEventTimeStampToDateTime(PointerEventTimeStamp d) {
    final diff = _diffDateTimeToPointerEventTimeStamp;
    if (diff == null) return null;
    return SimpleDateTime.fromMicrosecondsSinceEpoch(d.inMicroseconds + diff);
  }

  int get _diffSystemToAdjustedFrameTimeStamp =>
      _systemToAdjustedFrameTimeStampConverter
          .diffSystemToAdjustedFrameTimeStamp;

  int get _diffDateTimeToAdjustedFrameTimeStamp;

  int? get _diffDateTimeToPointerEventTimeStamp;
}

class _TimeConverterNormal extends TimeConverter {
  final _systemFrameTimeStampConverter = _SystemFrameTimeStampConverter();
  final _pointerEventTimeStampConverter = _PointerEventTimeStampConverter();

  _TimeConverterNormal() : super._();

  void dispose() {
    _systemFrameTimeStampConverter.dispose();
  }

  @override
  int get _diffDateTimeToAdjustedFrameTimeStamp =>
      _systemFrameTimeStampConverter.diffDateTimeToSystemFrameTimeStamp +
      _diffSystemToAdjustedFrameTimeStamp;

  @override
  int? get _diffDateTimeToPointerEventTimeStamp =>
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
  const _SystemToAdjustedFrameTimeStampConverter();

  int get diffSystemToAdjustedFrameTimeStamp =>
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

class _TimeConverterTest extends TimeConverter {
  _TimeConverterTest() : super._();

  @override
  int get _diffDateTimeToAdjustedFrameTimeStamp => TODO;

  @override
  int? get _diffDateTimeToPointerEventTimeStamp => 123456789;
}
