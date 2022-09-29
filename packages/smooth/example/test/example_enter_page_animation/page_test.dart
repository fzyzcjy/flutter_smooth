import 'package:example/example_enter_page_animation/page.dart';
import 'package:example/utils/complex_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.window
    ..physicalSizeTestValue = const Size(100, 150)
    ..devicePixelRatioTestValue = 1);
  tearDown(() => binding.window
    ..clearPhysicalSizeTestValue()
    ..clearDevicePixelRatioTestValue());

  group('golden for animation', () {
    Future<void> _body(
      WidgetTester tester, {
      required Duration listTileBuildTime,
    }) async {
      ComplexListTile.onBuild = (index) => binding.elapseBlocking(
          listTileBuildTime,
          reason: 'slowly build index=$index ListTile');
      TODO_on_layout;

      addTearDown(() => ComplexListTile.onBuild = null);
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
    }

    TODO_various_cases;
    TODO_usually_build_fast_layout_slow;
  });
}
