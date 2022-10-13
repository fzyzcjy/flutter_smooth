import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/service_locator.dart'; // ignore: implementation_imports
import 'package:smooth/src/time/time_converter.dart'; // ignore: implementation_imports

class TimeConverterTest extends TimeConverter {
  TimeConverterTest() : super.raw();

  @override
  int get diffDateTimeToSystemFrameTimeStamp {
    final nowDateTime = clock.now();

    // look at [AutomatedTestWidgetsFlutterBinding.pump], it uses *this* clock
    // as arg to `handleBeginFrame`
    // NOTE: *only* reasonable with [AutomatedTestWidgetsFlutterBinding], not
    // for other bindings
    final nowSystemFrameTimeStamp =
        AutomatedTestWidgetsFlutterBinding.instance.clock.now();

    return nowDateTime.microsecondsSinceEpoch -
        nowSystemFrameTimeStamp.microsecondsSinceEpoch;
  }

  @override
  int? get diffDateTimeToPointerEventTimeStamp => 123456789;
}

// TODO move
ServiceLocator createTestServiceLocator() => ServiceLocator(
      timeConverter: TimeConverterTest(),
    );
