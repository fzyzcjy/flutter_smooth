import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/infra/brake/brake_controller.dart';
import 'package:smooth/src/infra/brake/build_after_previous_build_or_layout.dart';
import 'package:smooth/src/infra/service_locator.dart';
import 'package:smooth_dev/smooth_dev.dart';

import '../test_tools/widgets.dart';
import 'brake_point_test.mocks.dart';

@GenerateMocks([BrakeController])
void main() {
  late BrakeController controller;
  setUp(() {
    controller = MockBrakeController();
    when(controller.brakeModeActive).thenReturn(false);
  });

  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
  binding.debugServiceLocatorFactory = () => ServiceLocator(
      brakeController: controller, timeConverter: TimeConverterTest());

  testWidgets('when brake, next build/layout/initState should fallback',
      (tester) async {
    var countFormerInitState = 0;
    var countFormerBuild = 0;
    var countFormerLayout = 0;
    var countLatterInitState = 0;
    var countLatterBuild = 0;
    var countLatterLayout = 0;

    debugPrint('action: pumpWidget');
    await tester.pumpWidget(Column(
      children: [
        SmoothBrakePoint(
          child: SpyStatefulWidget(onInitState: () => countFormerInitState++),
        ),
        SmoothBrakePoint(
          child: SpyStatefulWidget(onBuild: () => countFormerBuild++),
        ),
        SmoothBrakePoint(
          child:
              SpyRenderObjectWidget(onPerformLayout: () => countFormerLayout++),
        ),
        BuildAfterPreviousBuildOrLayout(
          builder: (_) => SpyRenderObjectWidget(onPerformLayout: () {
            debugPrint('action: brakeModeActive := true');
            when(controller.brakeModeActive).thenReturn(true);
          }),
        ),
        SmoothBrakePoint(
          child: SpyStatefulWidget(onInitState: () => countLatterInitState++),
        ),
        SmoothBrakePoint(
          child: SpyStatefulWidget(onBuild: () => countLatterBuild++),
        ),
        SmoothBrakePoint(
          child:
              SpyRenderObjectWidget(onPerformLayout: () => countLatterLayout++),
        ),
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
