import 'dart:io';
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
    binding.window.physicalSizeTestValue = const Size(100, 50);
    addTearDown(() => binding.window.clearPhysicalSizeTestValue());

    final images = <ui.Image>[];
    binding.onWindowRender = (scene) {
      final size = binding.window.physicalSize;
      final image = scene.toImageSync(size.width.round(), size.height.round());
      images.add(image);
    };

    // just a simple scene
    await tester.pumpWidget(DecoratedBox(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.green, width: 1)),
      child: Center(
        child: Container(width: 10, height: 10, color: Colors.green.shade200),
      ),
    ));

    await tester.runAsync(() async {
      final image = images.single;
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
      File('a.png').writeAsBytesSync(bytes);
    });

    fail('TODO');
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
