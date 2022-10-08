import 'package:flutter/material.dart';
import 'package:smooth/src/messages.dart';

class SmoothHostApiWrapped {
  static final instance = SmoothHostApiWrapped._();

  SmoothHostApiWrapped._();

  final _api = SmoothHostApi();

  Future<void> init() async {
    _pointerEventDateTimeDiffTimeStamp =
        await _api.pointerEventDateTimeDiffTimeStamp();
  }

  int? get pointerEventDateTimeDiffTimeStamp =>
      _pointerEventDateTimeDiffTimeStamp;
  int? _pointerEventDateTimeDiffTimeStamp;
}

extension ExtPointerEvent on PointerEvent {
  DateTime? get dateTime {
    final pointerEventDateTimeDiffTimeStamp =
        SmoothHostApiWrapped.instance.pointerEventDateTimeDiffTimeStamp;
    if (pointerEventDateTimeDiffTimeStamp == null) return null;
    return DateTime.fromMicrosecondsSinceEpoch(
        timeStamp.inMicroseconds + pointerEventDateTimeDiffTimeStamp);
  }
}
