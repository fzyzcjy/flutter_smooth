import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;

import 'binding.dart';

class WindowRenderCapturer {
  List<ui.Image> get images => UnmodifiableListView(_images);
  final _images = <ui.Image>[];

  late final _binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;

  WindowRenderCapturer.autoRegister() {
    assert(_binding.onWindowRender == null);
    _binding.onWindowRender = onWindowRender;
    addTearDown(() {
      assert(_binding.onWindowRender == onWindowRender);
      return _binding.onWindowRender = null;
    });
  }

  void reset() => _images.clear();

  void onWindowRender(ui.Scene scene) {
    final image = scene.toImageSync(
        _binding.window.logicalWidth, _binding.window.logicalHeight);
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

  Future<void> expectAndReset(
      WidgetTester tester, List<ui.Image> expectImages) async {
    await expect(tester, expectImages);
    reset();
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
