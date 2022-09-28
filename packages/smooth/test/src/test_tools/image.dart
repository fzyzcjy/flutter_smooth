import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

import 'binding.dart';
import 'window.dart';

// test the test tool
void main() {
  testWidgets('createScreenImage', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(100, 50),
        devicePixelRatioTestValue: 1);

    final im = await tester.createScreenImage(
      (im) => im
        ..fillRect(const Rectangle(0, 0, 50, 50), Colors.red)
        ..fillRect(const Rectangle(50, 0, 50, 50), Colors.green),
    );

    expect(im, matchesGoldenFile('../goldens/image/simple.png'));
  });
}

extension ExtWigetTesterScreenImage on WidgetTester {
  Future<ui.Image> createScreenImage(void Function(image.Image) draw) async {
    return (await runAsync(() => _createScreenImage(draw)))!;
  }
}

Future<ui.Image> _createScreenImage(void Function(image.Image) draw) {
  final window = SchedulerBinding.instance.window;
  final im = image.Image(window.logicalWidth, window.logicalHeight);

  draw(im);

  final bytes = Uint8List.fromList(image.encodeBmp(im));

  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}

extension ExtImage on image.Image {
  void fillAll(Color color) => fill(color.toImageColor());

  void fillRect(Rectangle<int> bounds, Color color) {
    image.fillRect(this, bounds.left, bounds.top, bounds.right, bounds.bottom,
        color.toImageColor());
  }

  void fillLeftRight(Color left, Color right) {
    assert(width.isEven);
    final halfWidth = width ~/ 2;
    fillRect(Rectangle(0, 0, halfWidth, height), left);
    fillRect(Rectangle(halfWidth, 0, halfWidth, height), right);
  }
}

extension ExtColor on Color {
  int toImageColor() => image.getColor(red, green, blue, alpha);
}
