import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

extension ExtWidgetTesterGesture on WidgetTester {
  // ref [startGesture]
  Future<TestSmoothGesture> startSmoothGesture(Offset downLocation) async {
    final result = await createGesture();
    await result.down(downLocation);
    return result;
  }
}

// ref [TestGesture]
class TestSmoothGesture {
  TestSmoothGesture() : _pointer = TestPointer();

  // ref [TestGesture]
  final TestPointer _pointer;

  // ref [TestGesture]
  void down(Offset downLocation, {Duration timeStamp = Duration.zero}) {
    _dispatcher(_pointer.down(downLocation, timeStamp: timeStamp));
  }

  // ref [TestGesture]
  void moveTo(Offset location, {Duration timeStamp = Duration.zero}) {
    assert(_pointer.isDown);
    _dispatcher(_pointer.move(location, timeStamp: timeStamp));
  }

  // ref [TestGesture]
  void up({Duration timeStamp = Duration.zero}) {
    assert(_pointer.isDown);
    _dispatcher(_pointer.up(timeStamp: timeStamp));
    assert(!_pointer.isDown);
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
