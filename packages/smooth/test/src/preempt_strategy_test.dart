import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/scheduler_binding.dart';
import 'package:smooth/src/simple_date_time.dart';

import 'preempt_strategy_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PreemptStrategyDependency>()])
void main() {
  group('PreemptStrategyNormal', () {
    final startDateTime = DateTime(2000);
    const firstFrameTimeStamp = Duration(seconds: 10);
    const kActThresh = PreemptStrategyNormal.kActThresh;

    late MockPreemptStrategyDependency dependency;
    late PreemptStrategyNormal strategy;
    setUp(() {
      dependency = MockPreemptStrategyDependency();
      strategy = PreemptStrategyNormal(dependency: dependency);
    });

    group('when no preempt render', () {
      const currentFrameTimeStamp = firstFrameTimeStamp;
      final beginFrameDateTime = startDateTime;

      testWidgets('when now=begin-of-frame', (tester) async {
        dependency.mock(
          now: startDateTime,
          currentFrameTimeStamp: currentFrameTimeStamp,
          beginFrameDateTime: beginFrameDateTime,
        );
        strategy.expect(
          currentSmoothFrameTimeStamp: firstFrameTimeStamp,
          shouldActTimeStamp: firstFrameTimeStamp - kActThresh,
        );
      });

      testWidgets('when now=near-end-of-frame', (tester) async {
        dependency.mock(
          now: startDateTime.add(const Duration(milliseconds: 16)),
          currentFrameTimeStamp: currentFrameTimeStamp,
          beginFrameDateTime: beginFrameDateTime,
        );
        strategy.expect(
          currentSmoothFrameTimeStamp: firstFrameTimeStamp,
          shouldActTimeStamp: firstFrameTimeStamp - kActThresh,
        );
      });

      testWidgets('when now=long-later', (tester) async {
        dependency.mock(
          now: startDateTime.add(const Duration(milliseconds: 100000)),
          currentFrameTimeStamp: currentFrameTimeStamp,
          beginFrameDateTime: beginFrameDateTime,
        );
        strategy.expect(
          currentSmoothFrameTimeStamp: firstFrameTimeStamp,
          shouldActTimeStamp: firstFrameTimeStamp - kActThresh,
        );
      });
    });

    group('when has preempt render', () {
      group('when verify after preemptRender called', () {
        testWidgets('when preemptRender is just before vsync', (tester) async {
          dependency.mock(
            now: startDateTime.add(const Duration(milliseconds: 16)),
            currentFrameTimeStamp: firstFrameTimeStamp,
            beginFrameDateTime: startDateTime,
          );

          strategy.onPreemptRender();

          strategy.expect(
            currentSmoothFrameTimeStamp: TODO,
            shouldActTimeStamp: TODO,
          );
        });

        testWidgets('when preemptRender is just after vsync', (tester) async {
          TODO;
        });
      });

      group('when verify after second frame begins', () {
        testWidgets('simple', (tester) async {
          TODO;
        });
      });
    });
  });

  // temporarily disable, re-enable later #45
  // group('vsyncLaterThan', () {
  //   test('kOneFrameUs', () {
  //     expect(kOneFrameUs, 16666);
  //   });
  //
  //   test('when same', () {
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 10),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 10),
  //     );
  //   });
  //
  //   test('when larger', () {
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 10, milliseconds: 16),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 10),
  //     );
  //
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 10, milliseconds: 17),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 10, microseconds: 16666),
  //     );
  //
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 10, milliseconds: 33),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 10, microseconds: 16666),
  //     );
  //
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 10, milliseconds: 34),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 10, microseconds: 33332),
  //     );
  //   });
  //
  //   test('when smaller', () {
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 9, milliseconds: 984),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 10),
  //     );
  //
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 9, milliseconds: 983),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 9, microseconds: 1000000 - 16666),
  //     );
  //
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 9, milliseconds: 967),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 9, microseconds: 1000000 - 16666),
  //     );
  //
  //     expect(
  //       PreemptStrategyNormal.vsyncLaterThan(
  //         time: const Duration(seconds: 9, milliseconds: 966),
  //         baseVsync: const Duration(seconds: 10),
  //       ),
  //       const Duration(seconds: 9, microseconds: 1000000 - 33332),
  //     );
  //   });
  // });
}

extension on MockPreemptStrategyDependency {
  void mock({
    required DateTime now,
    required Duration currentFrameTimeStamp,
    required DateTime beginFrameDateTime,
  }) {
    when(this.now()).thenReturn(now.toSimple());
    when(this.currentFrameTimeStamp).thenReturn(currentFrameTimeStamp);
    when(this.beginFrameDateTime).thenReturn(beginFrameDateTime);
  }
}

extension on PreemptStrategyNormal {
  void expect({
    required Duration currentSmoothFrameTimeStamp,
    required Duration shouldActTimeStamp,
  }) {
    flutter_test.expect(
        this.currentSmoothFrameTimeStamp, currentSmoothFrameTimeStamp);
    flutter_test.expect(this.shouldActTimeStamp, shouldActTimeStamp);
  }
}
