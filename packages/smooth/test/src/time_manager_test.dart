import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:mockito/mockito.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/time_manager.dart';

void main() {
  const kTenSeconds = Duration(seconds: 10);
  const kActThresh = TimeManager.kActThresh;

  late TimeManager manager;
  setUp(() => manager = TimeManager());

  group('when has no preempt render', () {
    test('when initial', () {
      manager.onBeginFrame(
          currentFrameTimeStamp: kTenSeconds + kOneFrame, now: kTenSeconds);

      manager.expect(
        phase: SmoothFramePhase.initial,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame,
        shouldActOnBuildOrLayoutPhaseTimeStamp:
            kTenSeconds + kOneFrame - kActThresh,
      );
    });

    test('when two frames', () {
      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrame,
        now: kTenSeconds,
      );

      manager.afterPlainOldRender(
          now: kTenSeconds + const Duration(milliseconds: 15));

      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrame * 2,
        now: kTenSeconds + kOneFrame,
      );

      manager.expect(
        phase: SmoothFramePhase.initial,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame * 2,
        shouldActOnBuildOrLayoutPhaseTimeStamp:
            kTenSeconds + kOneFrame * 2 - kActThresh,
      );
    });
  });

  group('when has build/layout phase preempt render', () {
    group('inside one plain-old frame, when has one preemptRender', () {
      void _body({required Duration timeWhenPreemptRender}) {
        manager.onBeginFrame(
            currentFrameTimeStamp: kTenSeconds + kOneFrame, now: kTenSeconds);
        manager.expect(
          phase: SmoothFramePhase.initial,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame,
          shouldActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrame - kActThresh,
        );

        manager.afterBuildOrLayoutPhasePreemptRender(
            now: timeWhenPreemptRender);

        manager.expect(
          phase: SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender,
          // since now is "after" the preemptRender, when talking about timestamps,
          // we should mimic it as if we are having a second 60FPS plain old
          // frame.
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame * 2,
          shouldActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrame * 2 - kActThresh,
        );
      }

      test('when preemptRender is just before vsync', () {
        _body(
          timeWhenPreemptRender: kTenSeconds + const Duration(milliseconds: 16),
        );
      });

      test('when preemptRender is just after vsync', () {
        _body(
          timeWhenPreemptRender: kTenSeconds + const Duration(milliseconds: 17),
        );
      });
    });

    // let's focus on the second preemptRender
    group('inside one plain-old frame, when has two preemptRender', () {
      void _body({required Duration nowWhenSecondPreemptRender}) {
        manager.onBeginFrame(
            currentFrameTimeStamp: kTenSeconds + kOneFrame, now: kTenSeconds);

        manager.afterBuildOrLayoutPhasePreemptRender(
            now: kTenSeconds + const Duration(microseconds: 16500));

        manager.afterBuildOrLayoutPhasePreemptRender(
            now: nowWhenSecondPreemptRender);

        manager.expect(
          phase: SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrame * 3,
          shouldActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrame * 3 - kActThresh,
        );
      }

      test('when second preemptRender is just before vsync', () {
        _body(
          nowWhenSecondPreemptRender:
              kTenSeconds + kOneFrame + const Duration(milliseconds: 16),
        );
      });

      test('when second preemptRender is just after vsync', () {
        _body(
          nowWhenSecondPreemptRender:
              kTenSeconds + kOneFrame + const Duration(milliseconds: 17),
        );
      });
    });

    // these are not tested, since when onBeginFrame, old data will be cleared
    // group('when second plain-old frame begins', () {});
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
