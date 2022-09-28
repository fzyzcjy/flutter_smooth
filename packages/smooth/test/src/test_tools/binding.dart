import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'proxy.dart';

void main() {
  // test the test-tool code
  testWidgets('SmoothSchedulerBindingMixin.onWindowRender', (tester) async {
    TODO;
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

