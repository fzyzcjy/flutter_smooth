import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/infra/service_locator.dart'; // ignore: implementation_imports
import 'package:smooth/src/infra/time/time_converter.dart'; // ignore: implementation_imports

class TimeConverterTest extends TimeConverter {
  TimeConverterTest() : super.raw();

  @override
  int get diffDateTimeToSystemFrameTimeStamp {
    final clockNow = clock.now();
    final bindingClockNow =
        AutomatedTestWidgetsFlutterBinding.instance.clock.now();

    // look at [AutomatedTestWidgetsFlutterBinding.pump], it uses [binding.clock]
    // as arg to `handleBeginFrame`.
    //
    // Since [clock] and [binding.clock] changes time synchronously, just
    // consider the point when `handleBeginFrame` is called. At that time,
    // [bindingClockNow] is the vsync-target-time (i.e. now+16.67ms), while
    // [now] is the current-time.
    //
    // NOTE: *only* reasonable with [AutomatedTestWidgetsFlutterBinding], not
    // for other bindings
    return clockNow.microsecondsSinceEpoch -
        (bindingClockNow.microsecondsSinceEpoch - kOneFrameUs);
  }

  @override
  int? get diffDateTimeToPointerEventTimeStamp => 123456789;
}

// TODO move
ServiceLocator createTestServiceLocator() => ServiceLocator(
      timeConverter: TimeConverterTest(),
    );
