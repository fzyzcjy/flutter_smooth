import 'package:clock/clock.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/infra/service_locator.dart';

// ref [TestGesture]
class TestSmoothGesture {
  // ref [WidgetController]
  static int _getNextPointer() => _nextPointer++;
  static int _nextPointer = 100;

  TestSmoothGesture() : _pointer = TestPointer(_getNextPointer());

  final TestPointer _pointer;
  final _eventsToPlainDispatch = <PointerEvent>[];

  void addEvent(PointerEvent event) {
    assert(event.timeStamp != Duration.zero,
        'Should provide a reasonable `timeStamp`');

    _eventsToPlainDispatch.add(event);
    TestWidgetsFlutterBinding.instance.debugOverrideEnginePendingEvents
        .add(event);
  }

  void addEventDown(Offset newLocation, {DateTime? time}) =>
      addEvent(_pointer.down(newLocation, timeStamp: _convertTimeStamp(time)));

  void addEventMove(Offset newLocation, {DateTime? time}) =>
      addEvent(_pointer.move(newLocation, timeStamp: _convertTimeStamp(time)));

  void addEventUp({DateTime? time}) =>
      addEvent(_pointer.up(timeStamp: _convertTimeStamp(time)));

  Duration _convertTimeStamp(DateTime? time) => ServiceLocator
      .instance.timeConverter
      .dateTimeToPointerEventTimeStamp(time?.toSimple() ?? clock.nowSimple())!
      .innerPointerEventTimeStamp;

  Future<void> plainDispatchAll() async {
    // this [TestAsyncUtils.guard] ref [TestGesture]
    return TestAsyncUtils.guard<void>(() async {
      _eventsToPlainDispatch.forEach(_dispatcher);
      _eventsToPlainDispatch.clear();
    });
  }

  void _dispatcher(PointerEvent event) {
    // * `TestGesture.down` or `TestGesture.moveBy` etc, all are implemented
    //   like `TestGesture._dispatcher(PointerDownEvent(...))`.
    // * The `_dispatcher` is `WidgetController.sendEventToBinding`.
    // * That is indeed `GestureBinding.handlePointerEvent`
    // So we just do the following.
    GestureBinding.instance.handlePointerEvent(event);
  }
}
