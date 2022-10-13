import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/service_locator.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('$TimeConverterTest', () {
    // have *multi* testWidgets, b/c a test can affect later tests
    for (var i = 0; i < 3; ++i) {
      testWidgets('sequential test $i', (tester) async {
        final timeConverter = ServiceLocator.instance.timeConverter;

        expect(binding.clock.now(), DateTime.utc(2015));
        expect(clock.now(), isNot(DateTime.utc(2015)));

        expect(timeConverter.diffDateTimeToSystemFrameTimeStamp, TODO);

        final clockAtStart = clock.now();

        await tester.pumpWidget(Container());
        await tester.pump(const Duration(seconds: 1));

        expect(binding.clock.now(),
            DateTime.utc(2015).add(const Duration(seconds: 1)));
        expect(clock.now(), clockAtStart.add(const Duration(seconds: 1)));

        // TODO;
      });
    }
  });
}
