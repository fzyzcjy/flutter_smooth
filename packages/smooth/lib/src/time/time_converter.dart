import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/host_api/messages.dart';
import 'package:smooth/src/time/simple_date_time.dart';
import 'package:smooth/src/time/typed_time.dart';

// TODO maybe improve
class TimeConverter {
  final _systemFrameTimeStampConverter = _SystemFrameTimeStampConverter();
  final _systemToAdjustedFrameTimeStampConverter =
      const _SystemToAdjustedFrameTimeStampConverter();
  final _PointerEventTimeStampConverter _pointerEventTimeStampConverter;

  TimeConverter()
      : _pointerEventTimeStampConverter =
            _PointerEventTimeStampConverter.normal();

  TimeConverter.test({
    required ValueGetter<int> diffDateTimeToPointerEventTimeStamp,
  }) : _pointerEventTimeStampConverter = _PointerEventTimeStampConverter.fake(
            diffDateTimeToPointerEventTimeStamp);

  void dispose() {
    _systemFrameTimeStampConverter.dispose();
  }

  int get _diffDateTimeToAdjustedFrameTimeStamp =>
      _systemFrameTimeStampConverter.diffDateTimeToSystemFrameTimeStamp +
      _systemToAdjustedFrameTimeStampConverter
          .diffSystemToAdjustedFrameTimeStamp;

  SystemFrameTimeStamp adjustedToSystemFrameTimeStamp(
          AdjustedFrameTimeStamp t) =>
      SystemFrameTimeStamp.unchecked(
        microseconds: t.inMicroseconds +
            _systemToAdjustedFrameTimeStampConverter
                .diffSystemToAdjustedFrameTimeStamp,
      );

  AdjustedFrameTimeStamp dateTimeToAdjustedFrameTimeStamp(SimpleDateTime t) =>
      AdjustedFrameTimeStamp.unchecked(
          microseconds:
              t.microsecondsSinceEpoch - _diffDateTimeToAdjustedFrameTimeStamp);

  SimpleDateTime adjustedFrameTimeStampToDateTime(AdjustedFrameTimeStamp d) =>
      SimpleDateTime.fromMicrosecondsSinceEpoch(
          d.inMicroseconds + _diffDateTimeToAdjustedFrameTimeStamp);

  PointerEventTimeStamp? dateTimeToPointerEventTimeStamp(SimpleDateTime d) {
    final diffDateTimeToPointerEventTimeStamp =
        _pointerEventTimeStampConverter.diffDateTimeToPointerEventTimeStamp;
    if (diffDateTimeToPointerEventTimeStamp == null) return null;

    return PointerEventTimeStamp.unchecked(
      microseconds:
          d.microsecondsSinceEpoch - diffDateTimeToPointerEventTimeStamp,
    );
  }

  SimpleDateTime? pointerEventTimeStampToDateTime(PointerEventTimeStamp d) {
    final diffDateTimeToPointerEventTimeStamp =
        _pointerEventTimeStampConverter.diffDateTimeToPointerEventTimeStamp;
    if (diffDateTimeToPointerEventTimeStamp == null) return null;

    return SimpleDateTime.fromMicrosecondsSinceEpoch(
        d.inMicroseconds + diffDateTimeToPointerEventTimeStamp);
  }
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

abstract class _PointerEventTimeStampConverter {
  factory _PointerEventTimeStampConverter.normal() =
      _PointerEventTimeStampConverterNormal;

  factory _PointerEventTimeStampConverter.fake(ValueGetter<int> getter) =
      _PointerEventTimeStampConverterFake;

  int? get diffDateTimeToPointerEventTimeStamp;
}

class _PointerEventTimeStampConverterNormal
    implements _PointerEventTimeStampConverter {
  _PointerEventTimeStampConverterNormal() {
    _init();
  }

  Future<void> _init() async {
    _diffDateTimeToPointerEventTimeStamp =
        await SmoothHostApi().pointerEventDateTimeDiffTimeStamp();
  }

  @override
  int? get diffDateTimeToPointerEventTimeStamp =>
      _diffDateTimeToPointerEventTimeStamp;
  int? _diffDateTimeToPointerEventTimeStamp;
}

class _PointerEventTimeStampConverterFake
    implements _PointerEventTimeStampConverter {
  final ValueGetter<int> getter;

  _PointerEventTimeStampConverterFake(this.getter);

  @override
  int get diffDateTimeToPointerEventTimeStamp => getter();
}
