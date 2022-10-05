import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/simple_date_time.dart';

import 'preempt_strategy_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PreemptStrategyDependency>()])
void main() {
  group('PreemptStrategyNormal', () {
    final startDateTime = DateTime(2000);
    // NOTE the vsync "target" time means the the *end* of current 16.67ms frame
    // see VsyncTargetTime in flutter engine c++ code for more details
    const firstFrameTargetVsyncTimeStamp = Duration(seconds: 10);
    const kActThresh = PreemptStrategyNormal.kActThresh;

    late MockPreemptStrategyDependency dependency;
    late PreemptStrategyNormal strategy;
    setUp(() {
      dependency = MockPreemptStrategyDependency();
      strategy = PreemptStrategyNormal(dependency: dependency);
    });

    group('when no preempt render', () {
      const currentFrameTimeStamp = firstFrameTargetVsyncTimeStamp;
      final beginFrameDateTime = startDateTime;

      test('when now=begin-of-frame', () {
        dependency.mock(
          now: startDateTime,
          currentFrameTimeStamp: currentFrameTimeStamp,
          beginFrameDateTime: beginFrameDateTime,
        );
        strategy.expect(
          currentSmoothFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
          shouldActTimeStamp: firstFrameTargetVsyncTimeStamp - kActThresh,
          shouldAct: false,
        );
      });

      test('when now=near-end-of-frame', () {
        dependency.mock(
          now: startDateTime.add(const Duration(milliseconds: 16)),
          currentFrameTimeStamp: currentFrameTimeStamp,
          beginFrameDateTime: beginFrameDateTime,
        );
        strategy.expect(
          currentSmoothFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
          shouldActTimeStamp: firstFrameTargetVsyncTimeStamp - kActThresh,
          shouldAct: true,
        );
      });

      test('when now=long-later', () {
        dependency.mock(
          now: startDateTime.add(const Duration(milliseconds: 100000)),
          currentFrameTimeStamp: currentFrameTimeStamp,
          beginFrameDateTime: beginFrameDateTime,
        );
        strategy.expect(
          currentSmoothFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
          shouldActTimeStamp: firstFrameTargetVsyncTimeStamp - kActThresh,
          shouldAct: true,
        );
      });
    });

    group('when has preempt render', () {
      group('inside one plain-old frame, when has one preemptRender', () {
        void _body({required DateTime now}) {
          dependency.mock(
            now: now,
            currentFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
            beginFrameDateTime: startDateTime,
          );
          strategy.refresh();

          strategy.expect(
            currentSmoothFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
            shouldActTimeStamp:
                firstFrameTargetVsyncTimeStamp + kOneFrame - kActThresh,
            shouldAct: false,
          );
        }

        test('when preemptRender is just before vsync', () {
          _body(now: startDateTime.add(const Duration(milliseconds: 16)));
        });

        test('when preemptRender is just after vsync', () {
          _body(now: startDateTime.add(const Duration(milliseconds: 17)));
        });
      });

      group(
          'inside one plain-old frame, when has two preemptRender, and focus on the second',
          () {
        void _body({required DateTime nowWhenSecondPreemptRender}) {
          dependency.mock(
            now: startDateTime.add(const Duration(milliseconds: 16)),
            currentFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
            beginFrameDateTime: startDateTime,
          );
          strategy.refresh();

          dependency.mock(
            now: nowWhenSecondPreemptRender,
            // NOTE [currentFrameTimeStamp] and [beginFrameDateTime] are
            // unchanged, because they are unchanged in one plain-old frame
            // even if there are multiple extra preempt frames
            currentFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
            beginFrameDateTime: startDateTime,
          );
          strategy.refresh();

          strategy.expect(
            currentSmoothFrameTimeStamp:
                firstFrameTargetVsyncTimeStamp + kOneFrame,
            shouldActTimeStamp:
                firstFrameTargetVsyncTimeStamp + kOneFrame * 2 - kActThresh,
            shouldAct: false,
          );
        }

        test('when second preemptRender is just before vsync', () {
          _body(
            nowWhenSecondPreemptRender:
                startDateTime.add(kOneFrame + const Duration(milliseconds: 16)),
          );
        });

        test('when second preemptRender is just after vsync', () {
          _body(
            nowWhenSecondPreemptRender:
                startDateTime.add(kOneFrame + const Duration(milliseconds: 17)),
          );
        });
      });

      group('when second plain-old frame begins', () {
        for (final nowWhenPreemptRenderShift in const [
          Duration(milliseconds: 16),
          Duration(milliseconds: 17),
        ]) {
          test(
              'when have one preemptRender previously (nowWhenSecondPreemptRenderShift=$nowWhenPreemptRenderShift)',
              () {
            dependency.mock(
              now: startDateTime.add(nowWhenPreemptRenderShift),
              currentFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
              beginFrameDateTime: startDateTime,
            );
            strategy.refresh();

            dependency.mock(
              now: startDateTime
                  .add(kOneFrame + const Duration(milliseconds: 1)),
              // second frame
              currentFrameTimeStamp: firstFrameTargetVsyncTimeStamp + kOneFrame,
              beginFrameDateTime: startDateTime.add(kOneFrame),
            );

            strategy.expect(
              currentSmoothFrameTimeStamp:
                  firstFrameTargetVsyncTimeStamp + kOneFrame,
              shouldActTimeStamp:
                  firstFrameTargetVsyncTimeStamp + kOneFrame - kActThresh,
              shouldAct: false,
            );
          });
        }

        for (final nowWhenSecondPreemptRenderShift in const [
          Duration(milliseconds: 16),
          Duration(milliseconds: 17),
        ]) {
          test(
              'when have two preemptRender previously (nowWhenSecondPreemptRenderShift=$nowWhenSecondPreemptRenderShift)',
              () {
            dependency.mock(
              now: startDateTime.add(const Duration(milliseconds: 16)),
              currentFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
              beginFrameDateTime: startDateTime,
            );
            strategy.refresh();

            dependency.mock(
              now: startDateTime
                  .add(kOneFrame + nowWhenSecondPreemptRenderShift),
              currentFrameTimeStamp: firstFrameTargetVsyncTimeStamp,
              beginFrameDateTime: startDateTime,
            );
            strategy.refresh();

            // the "*2" is because, we have *two* preemptRender above
            // so we assume the first plain-old frame runs for 2/60s
            dependency.mock(
              now: startDateTime
                  .add(kOneFrame * 2 + const Duration(milliseconds: 1)),
              // second frame
              currentFrameTimeStamp:
                  firstFrameTargetVsyncTimeStamp + kOneFrame * 2,
              beginFrameDateTime: startDateTime.add(kOneFrame * 2),
            );

            strategy.expect(
              currentSmoothFrameTimeStamp:
                  firstFrameTargetVsyncTimeStamp + kOneFrame * 2,
              shouldActTimeStamp:
                  firstFrameTargetVsyncTimeStamp + kOneFrame * 2 - kActThresh,
              shouldAct: false,
            );
          });
        }
      });
    });
  });

  group('vsyncLaterThan', () {
    test('kOneFrameUs', () {
      expect(kOneFrameUs, 16666);
    });

    test('when same', () {
      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10),
      );
    });

    test('when larger', () {
      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 16),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10, microseconds: 16666),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 17),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10, microseconds: 33332),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 33),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10, microseconds: 33332),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 10, milliseconds: 34),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10, microseconds: 16666 * 3),
      );
    });

    test('when smaller', () {
      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 9, milliseconds: 984),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 10),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 9, milliseconds: 983),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 9, microseconds: 1000000 - 16666),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 9, milliseconds: 967),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 9, microseconds: 1000000 - 16666),
      );

      expect(
        PreemptStrategyNormal.vsyncLaterThan(
          time: const Duration(seconds: 9, milliseconds: 966),
          baseVsync: const Duration(seconds: 10),
        ),
        const Duration(seconds: 9, microseconds: 1000000 - 33332),
      );
    });
  });
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
    required bool shouldAct,
  }) {
    debugPrint(
      'PreemptStrategyNormal.expect actual: '
      'currentSmoothFrameTimeStamp=${this.currentSmoothFrameTimeStamp} '
      'shouldActTimeStamp=${this.shouldActTimeStamp} '
      'shouldAct=${this.shouldAct()}',
    );

    flutter_test.expect(
      this.currentSmoothFrameTimeStamp,
      currentSmoothFrameTimeStamp,
      reason: 'currentSmoothFrameTimeStamp',
    );
    flutter_test.expect(
      this.shouldActTimeStamp,
      shouldActTimeStamp,
      reason: 'shouldActTimeStamp',
    );
    flutter_test.expect(
      this.shouldAct(),
      shouldAct,
      reason: 'shouldAct',
    );
  }
}
