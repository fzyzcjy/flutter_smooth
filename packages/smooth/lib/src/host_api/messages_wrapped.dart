import 'package:flutter/gestures.dart';
import 'package:smooth/src/host_api/messages.dart';

class SmoothHostApiWrapped {
  static final instance = SmoothHostApiWrapped._();

  SmoothHostApiWrapped._();

  final _api = SmoothHostApi();

  Future<void> init() async {
    _diffDateTimeToPointerEventTimeStamp =
        await _api.pointerEventDateTimeDiffTimeStamp();
  }

  int? get diffDateTimeToPointerEventTimeStamp =>
      _diffDateTimeToPointerEventTimeStamp;
  int? _diffDateTimeToPointerEventTimeStamp;
}

extension ExtPointerEvent on PointerEvent {
  DateTime? get dateTime {
    final diffDateTimeToPointerEventTimeStamp =
        SmoothHostApiWrapped.instance.diffDateTimeToPointerEventTimeStamp;
    if (diffDateTimeToPointerEventTimeStamp == null) return null;
    return DateTime.fromMicrosecondsSinceEpoch(
        timeStamp.inMicroseconds + diffDateTimeToPointerEventTimeStamp);
  }
}
