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
