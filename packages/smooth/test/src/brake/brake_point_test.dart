import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth/src/brake/brake_controller.dart';
import 'package:smooth/src/service_locator.dart';
import 'package:smooth_dev/smooth_dev.dart';

import '../test_tools/widgets.dart';
import 'brake_point_test.mocks.dart';

@GenerateMocks([BrakeController])
void main() {
  late BrakeController controller;
  setUp(() => controller = MockBrakeController());

  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
  binding.debugServiceLocatorFactory = () => ServiceLocator(
      brakeController: controller, timeConverter: TimeConverterTest());

  testWidgets('when brake, next build/layout/initState should fallback',
      (tester) async {
    when(controller.brakeModeActive).thenReturn(false);

    var countFormerInitState = 0;
    var countFormerBuild = 0;
    var countFormerLayout = 0;
    var countLatterInitState = 0;
    var countLatterBuild = 0;
    var countLatterLayout = 0;

    debugPrint('action: pumpWidget');
    await tester.pumpWidget(Column(
      children: [
        SpyStatefulWidget(onInitState: () => countFormerInitState++),
        SpyStatefulWidget(onBuild: () => countFormerBuild++),
        SpyRenderObjectWidget(onPerformLayout: () => countFormerLayout++),
        SpyRenderObjectWidget(onPerformLayout: () {
          debugPrint('action: brakeModeActive := true');
          when(controller.brakeModeActive).thenReturn(true);
        }),
        SpyStatefulWidget(onInitState: () => countLatterInitState++),
        SpyStatefulWidget(onBuild: () => countLatterBuild++),
        SpyRenderObjectWidget(onPerformLayout: () => countLatterLayout++),
      ],
    ));

    expect(countFormerInitState, 1);
    expect(countFormerBuild, 1);
    expect(countFormerLayout, 1);
    expect(countLatterInitState, 0);
    expect(countLatterBuild, 0);
    expect(countLatterLayout, 0);

    when(controller.brakeModeActive).thenReturn(false);

    debugPrint('action: pump');
    await tester.pump();

    expect(countFormerInitState, 1);
    expect(countFormerBuild, 1);
    expect(countFormerLayout, 1);
    expect(countLatterInitState, 1);
    expect(countLatterBuild, 1);
    expect(countLatterLayout, 1);
  });
}
