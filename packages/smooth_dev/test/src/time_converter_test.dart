import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
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

        final clockAtStart = clock.now();

        final onBuild = OnceCallable();

        onBuild.once = () {
          expect(
            timeConverter.dateTimeToAdjustedFrameTimeStamp(clock.nowSimple()),
            binding.currentFrameTimeStampTyped - kOneFrameAFTS,
          );
        };
        await tester.pumpWidget(AlwaysBuildBuilder(onBuild: onBuild));

        onBuild.once = () {
          expect(
            timeConverter.dateTimeToAdjustedFrameTimeStamp(clock.nowSimple()),
            binding.currentFrameTimeStampTyped - kOneFrameAFTS,
          );
        };
        await tester.pump(const Duration(seconds: 1));

        expect(binding.clock.now(),
            DateTime.utc(2015).add(const Duration(seconds: 1)));
        expect(clock.now(), clockAtStart.add(const Duration(seconds: 1)));

        expect(onBuild.hasPending, false);
      });
    }
  });
}
