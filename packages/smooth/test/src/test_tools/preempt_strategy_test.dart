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

    // TODO more
  });
}
