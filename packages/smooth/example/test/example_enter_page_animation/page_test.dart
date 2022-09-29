import 'package:example/example_enter_page_animation/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.window
    ..physicalSizeTestValue = const Size(100, 150)
    ..devicePixelRatioTestValue = 1);
  tearDown(() => binding.window
    ..clearPhysicalSizeTestValue()
    ..clearDevicePixelRatioTestValue());

  testWidgets('when widget build/layout is infinitely fast', (tester) async {
    await tester.pumpWidget(const ExampleEnterPageAnimationPage());

    TODO;
  });

  testWidgets('when widget build/layout is slow', (tester) async {
    await tester.pumpWidget(const ExampleEnterPageAnimationPage());

    TODO;
  });
}
