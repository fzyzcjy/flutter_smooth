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

    await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));
    TODO;
  });

  testWidgets('when widget build/layout is slow', (tester) async {
    TODO;
  });
}
