import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/scheduler_binding.dart';

import 'test_tools/binding.dart';
import 'test_tools/widgets.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothSchedulerBindingMixin', () {
    testWidgets('currentFrameVsyncTargetTime and diffDateTimeToTimeStamp',
        (tester) async {
      TODO_the_values_are_wrong;

      final startTime = clock.now();

      final onBuild = OnceCallback();

      final expectDiffDateTimeToTimeStamp = startTime.microsecondsSinceEpoch +
          1000000 +
          SmoothSchedulerBindingMixin.kOneFrameUs;

      onBuild.value = () {
        expect(
          binding.currentFrameVsyncTargetTime,
          startTime
              .add(const Duration(milliseconds: 1000, microseconds: 16666)),
        );
        expect(binding.diffDateTimeToTimeStamp, expectDiffDateTimeToTimeStamp);
      };

      await tester.pumpWidget(
        AlwaysBuildBuilder(onBuild: onBuild),
        const Duration(milliseconds: 1000),
      );

      onBuild.value = () {
        expect(
          binding.currentFrameVsyncTargetTime,
          startTime
              .add(const Duration(milliseconds: 1100, microseconds: 16666)),
        );
        expect(binding.diffDateTimeToTimeStamp, expectDiffDateTimeToTimeStamp);
      };

      await tester.pump(const Duration(milliseconds: 100));

      expect(onBuild.isEmpty, true);
    });
  });
}
