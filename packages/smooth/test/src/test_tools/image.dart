import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

import 'binding.dart';

// test the test tool
void main() {
  testWidgets('createScreenImage', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window
      ..devicePixelRatioTestValue = 1
      ..physicalSizeTestValue = const Size(100, 50);
    addTearDown(() => binding.window
      ..clearDevicePixelRatioTestValue()
      ..clearPhysicalSizeTestValue());

    final im = await createScreenImage(
      tester,
      (im) => im
        ..fillRect(const Rectangle(0, 0, 50, 50), Colors.red)
        ..fillRect(const Rectangle(50, 0, 50, 50), Colors.green),
    );

    expect(im, matchesGoldenFile('../goldens/image/simple.png'));
  });
}

Future<ui.Image> createScreenImage(
    WidgetTester tester, void Function(image.Image) draw) async {
  return (await tester.runAsync(() => _createScreenImage(draw)))!;
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
  void fillRect(Rectangle<int> bounds, Color color) {
    image.fillRect(
      this,
      bounds.left,
      bounds.top,
      bounds.right,
      bounds.bottom,
      image.getColor(color.red, color.green, color.blue, color.alpha),
    );
  }
}
