import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth/src/preempt_point.dart';
import 'package:smooth/src/service_locator.dart';

import 'test_tools/mock_source.mocks.dart';

void main() {
  late MockActor actor;
  setUp(() => actor = MockActor());

  group('$BuildPreemptPointWidget', () {
    testWidgets('when build, should call maybePreemptRender', (tester) async {
      verifyNever(actor.maybePreemptRenderBuildOrLayoutPhase());
      await tester.pumpWidget(SmoothScope(
        serviceLocator: ServiceLocator.normal().copyWith(actor: actor),
        child: BuildPreemptPointWidget(child: Container()),
      ));
      verify(actor.maybePreemptRenderBuildOrLayoutPhase()).called(1);
    });
  });

  group('$LayoutPreemptPointWidget', () {
    testWidgets('when layout, should call maybePreemptRender', (tester) async {
      verifyNever(actor.maybePreemptRenderBuildOrLayoutPhase());
      await tester.pumpWidget(SmoothScope(
        serviceLocator: ServiceLocator.normal().copyWith(actor: actor),
        child: LayoutPreemptPointWidget(child: Container()),
      ));
      verify(actor.maybePreemptRenderBuildOrLayoutPhase()).called(1);
    });
  });
}
