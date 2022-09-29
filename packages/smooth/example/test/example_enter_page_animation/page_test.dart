import 'package:example/example_enter_page_animation/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.window
    ..physicalSizeTestValue = const Size(100, 150)
    ..devicePixelRatioTestValue = 1);
  tearDown(() => binding.window
    ..clearPhysicalSizeTestValue()
    ..clearDevicePixelRatioTestValue());

  testWidgets('when widget build/layout is infinitely fast', (tester) async {
    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
    final timeInfo = TimeInfo();
    final capturer = WindowRenderCapturer.autoRegister();

    await tester.pumpWidget(const ExampleEnterPageAnimationPage());
    await tester.tap(find.text('smooth'));

    // 300ms animation, thus 18 frames. but we pump 20 frames to see the end
    for (var i = 1; i <= 21; ++i) {
      await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
    }

    await capturer.pack.matchesGoldenFile(
        tester, '../goldens/example_enter_page_animation/infinitely_fast');
  });

  testWidgets('when widget build/layout is slow', (tester) async {
    TODO;
  });
}
