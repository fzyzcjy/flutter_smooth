import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/scheduler_binding.dart';

void main() {
  group('PreemptStrategyNormal', () {
    test('vsyncLaterThan', () {
      expect(SmoothSchedulerBindingMixin.kOneFrameUs, 16666);

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10),
          oldVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 16),
          oldVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 17),
          oldVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10, microseconds: 16666),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 33),
          oldVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10, microseconds: 16666),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 34),
          oldVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10, microseconds: 33332),
      );
    });

    group('when no preempt render', () {
      testWidgets('when first frame', (tester) async {
        final strategy = PreemptStrategyNormal();

        TODO;

        expect(strategy.currentVsyncTargetTime, TODO);
        expect(strategy.shouldAct, TODO);
      });

      testWidgets('when second frame', (tester) async {
        TODO;
      });
    });

    group('when has preempt render', () {
      testWidgets('when first preempt render', (tester) async {
        TODO;
      });

      testWidgets('when second preempt render', (tester) async {
        TODO;
      });

      testWidgets('when preempt render is just before vsync', (tester) async {
        TODO;
      });

      testWidgets('when preempt render is just after vsync', (tester) async {
        TODO;
      });
    });
  });
}
