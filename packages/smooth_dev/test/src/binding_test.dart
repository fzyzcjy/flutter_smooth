import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SmoothSchedulerBindingMixin.onWindowRender', (tester) async {
    final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;
    binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(100, 50),
        devicePixelRatioTestValue: 1);

    final capturer = WindowRenderCapturer.autoDispose();

    // just a simple scene
    await tester.pumpWidget(DecoratedBox(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.green, width: 1)),
      child: Center(
        child: Container(width: 10, height: 10, color: Colors.green.shade200),
      ),
    ));

    expect(capturer.pack.flatEntries.single.image,
        matchesGoldenFile('../goldens/binding/simple.png'));
  });
}
