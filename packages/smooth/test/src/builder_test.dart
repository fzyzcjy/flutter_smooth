import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/service_locator.dart';

void main() {
  group('SmoothBuilder', () {
    testWidgets('when pump widgets unrelated to smooth, should build',
        (tester) async {
      ServiceLocator.debugOverrideInstance = ServiceLocator.normal()
          .copyWith(preemptStrategy: const PreemptStrategy.never());

      await tester.pumpWidget(Container());

      // should have no error
    });

    testWidgets('when use SmoothBuilder with simplest case, should build',
        (tester) async {
      ServiceLocator.debugOverrideInstance = ServiceLocator.normal()
          .copyWith(preemptStrategy: const PreemptStrategy.never());

      await tester.pumpWidget(SmoothBuilder(
        builder: (context, child) => child,
        child: Container(),
      ));

      // should have no error
    });
  });
}
