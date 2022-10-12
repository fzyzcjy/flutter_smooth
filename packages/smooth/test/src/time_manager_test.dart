import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/phase.dart';
import 'package:smooth/src/time_manager.dart';

void main() {
  const kTenSeconds = Duration(seconds: 10);
  const kActThresh = TimeManager.kActThresh;

  late Duration now;
  late TimeManager strategy;
  setUp(() {
    now = kTenSeconds;
    strategy = TimeManager(nowTimeStamp: () => now);
  });

  group('when has no preempt render', () {
    group('when initial, i.e. only call onBeginFrame', () {
      test('when now=begin-of-frame', () {
        strategy.onBeginFrame(kTenSeconds + kOneFrame);
        now = kTenSeconds + const Duration(microseconds: 1);

        strategy.expect(
          phase: SmoothFramePhase.initial,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame,
          shouldActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrame - kActThresh,
        );
      });

      test('when now=near-end-of-frame', () {
        strategy.onBeginFrame(kTenSeconds + kOneFrame);
        now = kTenSeconds + const Duration(milliseconds: 16);

        strategy.expect(
          phase: SmoothFramePhase.initial,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame,
          shouldActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrame - kActThresh,
        );
      });

      test('when now=long-later', () {
        strategy.onBeginFrame(kTenSeconds + kOneFrame);
        now = kTenSeconds + const Duration(seconds: 100);

        strategy.expect(
          phase: SmoothFramePhase.initial,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame,
          shouldActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrame - kActThresh,
        );
      });
    });

    test('when two frames', () {
      strategy.onBeginFrame(kTenSeconds + kOneFrame);
      now = kTenSeconds + kOneFrame;
      strategy.onBeginFrame(kTenSeconds + kOneFrame * 2);
      now = kTenSeconds + kOneFrame + const Duration(milliseconds: 1);

      strategy.expect(
        phase: SmoothFramePhase.initial,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame * 2,
        shouldActOnBuildOrLayoutPhaseTimeStamp:
            kTenSeconds + kOneFrame * 2 - kActThresh,
      );
    });
  });

  group('when has build/layout phase preempt render', () {
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
            now: startDateTime.add(kOneFrame + const Duration(milliseconds: 1)),
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
            now: startDateTime.add(kOneFrame + nowWhenSecondPreemptRenderShift),
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

  group('when has afterDrawFrame phase preempt render', () {
    TODO;
  });

  test('reproduce #6128', () {
    TODO;
  });
}

extension on MockTimeManagerDependency {
  void mock({
    required Duration nowTimeStamp,
    required Duration currentFrameTimeStamp,
  }) {
    when(this.nowTimeStamp).thenReturn(nowTimeStamp);
    when(this.currentFrameTimeStamp).thenReturn(currentFrameTimeStamp);
  }
}

extension on TimeManager {
  void expect({
    required SmoothFramePhase phase,
    required Duration currentSmoothFrameTimeStamp,
    required Duration shouldActOnBuildOrLayoutPhaseTimeStamp,
  }) {
    flutter_test.expect(this.phase, phase, reason: 'phase');
    flutter_test.expect(
        this.currentSmoothFrameTimeStamp, currentSmoothFrameTimeStamp,
        reason: 'currentSmoothFrameTimeStamp');
    flutter_test.expect(this.shouldActOnBuildOrLayoutPhaseTimeStamp,
        shouldActOnBuildOrLayoutPhaseTimeStamp,
        reason: 'shouldActOnBuildOrLayoutPhaseTimeStamp');
  }
}
