import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:smooth/src/binding.dart';

import 'proxy.dart';
import 'window.dart';

// test the test-tool code
void main() {
  SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SmoothSchedulerBindingMixin.onWindowRender', (tester) async {
    final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;
    binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(100, 50),
        devicePixelRatioTestValue: 1);

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
    with
        SmoothSchedulerBindingMixin,
        SmoothRendererBindingMixin,
        SmoothSchedulerBindingTestMixin {
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

mixin SmoothSchedulerBindingTestMixin on AutomatedTestWidgetsFlutterBinding {
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
  List<ui.Image> get images => UnmodifiableListView(_images);
  final _images = <ui.Image>[];

  WindowRenderCapturer();

  void reset() => _images.clear();

  void onWindowRender(ui.Scene scene) {
    final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;

    final image = scene.toImageSync(
        binding.window.logicalWidth, binding.window.logicalHeight);
    _images.add(image);
  }

  Future<void> expect(WidgetTester tester, List<ui.Image> expectImages) async {
    try {
      flutter_test.expect(_images.length, expectImages.length);
      for (var i = 0; i < _images.length; ++i) {
        await flutter_test.expectLater(
            _images[i], matchesReferenceImage(expectImages[i]));
      }
    } on TestFailure catch (_) {
      await tester.runAsync(() async {
        debugPrint('WindowRenderCapturer.expect save failed images to disk');
        for (var i = 0; i < _images.length; ++i) {
          await _images[i].save('failure_${i}_actual.png');
        }
        for (var i = 0; i < expectImages.length; ++i) {
          await expectImages[i].save('failure_${i}_expect.png');
        }
      });

      rethrow;
    }
  }
}

extension ExtUiImage on ui.Image {
  Future<void> save(String path) async {
    final byteData = await toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    debugPrint('Save image to $path');
    File(path).writeAsBytesSync(bytes);
  }
}

extension ExtWindow on ui.SingletonFlutterWindow {
  Size get _logicalSize => physicalSize / devicePixelRatio;

  int get logicalWidth => _logicalSize.width.round();

  int get logicalHeight => _logicalSize.height.round();
}
