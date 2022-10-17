import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/infra/service_locator.dart';
import 'package:smooth_dev/smooth_dev.dart';

import 'test_tools/mock_source.mocks.dart';

void main() {
  late MockActor actor;
  setUp(() => actor = MockActor());

  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
  binding.debugServiceLocatorFactory =
      () => ServiceLocator(actor: actor, timeConverter: TimeConverterTest());

  group('$SmoothBuildPreemptPointWidget', () {
    testWidgets('when build, should call maybePreemptRender', (tester) async {
      verifyNever(actor.maybePreemptRenderBuildOrLayoutPhase());
      await tester.pumpWidget(SmoothParent(
        child: SmoothBuildPreemptPointWidget(child: Container()),
      ));
      verify(actor.maybePreemptRenderBuildOrLayoutPhase()).called(1);
    });
  });

  group('$SmoothLayoutPreemptPointWidget', () {
    testWidgets('when layout, should call maybePreemptRender', (tester) async {
      verifyNever(actor.maybePreemptRenderBuildOrLayoutPhase());
      await tester.pumpWidget(SmoothParent(
        child: SmoothLayoutPreemptPointWidget(child: Container()),
      ));
      verify(actor.maybePreemptRenderBuildOrLayoutPhase()).called(1);
    });
  });
}
