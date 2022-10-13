import 'package:smooth/src/service_locator.dart'; // ignore: implementation_imports
import 'package:smooth/src/time/time_converter.dart'; // ignore: implementation_imports

class TimeConverterTest extends TimeConverter {
  TimeConverterTest() : super.raw();

  @override
  int get diffDateTimeToAdjustedFrameTimeStamp => TODO;

  @override
  int? get diffDateTimeToPointerEventTimeStamp => 123456789;
}

// TODO move
ServiceLocator createTestServiceLocator() => ServiceLocator(
      timeConverter: TimeConverterTest(),
    );
