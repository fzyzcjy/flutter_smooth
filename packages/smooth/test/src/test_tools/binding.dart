import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'proxy.dart';

// test the test-tool code
void main() {
  SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SmoothSchedulerBindingMixin.onWindowRender', (tester) async {
    final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;
    binding.window
      ..devicePixelRatioTestValue = 1
      ..physicalSizeTestValue = const Size(100, 50);
    addTearDown(() => binding.window
      ..clearDevicePixelRatioTestValue()
      ..clearPhysicalSizeTestValue());

    final capturer = WindowRenderCapturer();
    binding.onWindowRender = capturer.onWindowRender;

    // just a simple scene
    await tester.pumpWidget(DecoratedBox(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.green, width: 1)),
      child: Center(
        child: Container(width: 10, height: 10, color: Colors.green.shade200),
      ),
    ));

    expect(capturer.images.single,
        matchesGoldenFile('../goldens/binding/simple.png'));
  });
}

class SmoothAutomatedTestWidgetsFlutterBinding
    extends AutomatedTestWidgetsFlutterBinding
    with SmoothSchedulerBindingMixin {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SmoothAutomatedTestWidgetsFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);
  static SmoothAutomatedTestWidgetsFlutterBinding? _instance;

  // ignore: prefer_constructors_over_static_methods
  static SmoothAutomatedTestWidgetsFlutterBinding ensureInitialized() {
    if (SmoothAutomatedTestWidgetsFlutterBinding._instance == null) {
      SmoothAutomatedTestWidgetsFlutterBinding();
    }
    return SmoothAutomatedTestWidgetsFlutterBinding.instance;
  }
}

mixin SmoothSchedulerBindingMixin on AutomatedTestWidgetsFlutterBinding {
  OnWindowRender? onWindowRender;

  @override
  TestWindow get window =>
      SmoothTestWindow(super.window, onRender: (s) => onWindowRender?.call(s));
}

typedef OnWindowRender = void Function(ui.Scene scene);

class SmoothTestWindow extends ProxyTestWindow implements TestWindow {
  final OnWindowRender onRender;

  const SmoothTestWindow(
    super._inner, {
    required this.onRender,
  });

  @override
  void render(ui.Scene scene) {
    onRender(scene);
    super.render(scene);
  }
}

class WindowRenderCapturer {
  final images = <ui.Image>[];

  WindowRenderCapturer();

  void onWindowRender(ui.Scene scene) {
    final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;

    final image = scene.toImageSync(
        binding.window.logicalWidth, binding.window.logicalHeight);
    images.add(image);
  }

// `matchesGoldenFile` is already enough
// Future<List<Uint8List>> toImages(WidgetTester tester) async {
//   return (await tester.runAsync(() async {
//     final futures = images.map((image) async {
//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       return byteData!.buffer.asUint8List();
//     });
//     return Future.wait(futures);
//   }))!;
// }
}

extension ExtWindow on ui.SingletonFlutterWindow {
  Size get _logicalSize => physicalSize / devicePixelRatio;

  int get logicalWidth => _logicalSize.width.round();

  int get logicalHeight => _logicalSize.height.round();
}
