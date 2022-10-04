import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

// ref [TestGesture]
class TestSmoothGesture {
  final _eventsToPlainDispatch = <PointerEvent>[];

  void addEvent(PointerEvent event) {
    _eventsToPlainDispatch.add(event);
    TestWidgetsFlutterBinding.instance.debugOverrideEnginePendingEvents
        .add(event);
  }

  void plainDispatchAll() {
    _eventsToPlainDispatch.forEach(_dispatcher);
    _eventsToPlainDispatch.clear();
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
