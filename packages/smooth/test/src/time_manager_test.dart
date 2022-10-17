import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:smooth/smooth.dart';
import 'package:smooth/src/infra/time_manager.dart';

void main() {
  const kTenSeconds = AdjustedFrameTimeStamp.unchecked(seconds: 10);
  const kActThresh = TimeManager.kActThresh;

  late TimeManager manager;
  setUp(() => manager = TimeManager());

  group('when has no preemptRender', () {
    test('simple', () {
      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        // now: kTenSeconds,
      );

      manager.expect(
        phase: SmoothFramePhase.initial,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        thresholdActOnBuildOrLayoutPhaseTimeStamp:
            kTenSeconds + kOneFrameAFTS - kActThresh,
        thresholdActOnPostDrawFramePhaseTimeStamp: null,
      );

      manager.afterRunAuxPipelineForPlainOld(
          now: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 15));

      manager.expect(
        phase: SmoothFramePhase.afterRunAuxPipelineForPlainOld,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        // no meaningful value
        thresholdActOnBuildOrLayoutPhaseTimeStamp: null,
        thresholdActOnPostDrawFramePhaseTimeStamp: kTenSeconds + kOneFrameAFTS,
      );

      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 2,
        // now: kTenSeconds + kOneFrameAFTS,
      );

      manager.expect(
        phase: SmoothFramePhase.initial,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 2,
        thresholdActOnBuildOrLayoutPhaseTimeStamp:
            kTenSeconds + kOneFrameAFTS * 2 - kActThresh,
        thresholdActOnPostDrawFramePhaseTimeStamp: null,
      );
    });

    test('when jank', () {
      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        // now: kTenSeconds,
      );

      manager.expect(
        phase: SmoothFramePhase.initial,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        thresholdActOnBuildOrLayoutPhaseTimeStamp:
            kTenSeconds + kOneFrameAFTS - kActThresh,
        thresholdActOnPostDrawFramePhaseTimeStamp: null,
      );

      manager.afterRunAuxPipelineForPlainOld(
          // it janks
          now: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 30));

      manager.expect(
        phase: SmoothFramePhase.afterRunAuxPipelineForPlainOld,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        thresholdActOnBuildOrLayoutPhaseTimeStamp: null,
        thresholdActOnPostDrawFramePhaseTimeStamp: kTenSeconds + kOneFrameAFTS,
      );

      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 3,
        // now: kTenSeconds + kOneFrameAFTS,
      );

      manager.expect(
        phase: SmoothFramePhase.initial,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 3,
        thresholdActOnBuildOrLayoutPhaseTimeStamp:
            kTenSeconds + kOneFrameAFTS * 3 - kActThresh,
        thresholdActOnPostDrawFramePhaseTimeStamp: null,
      );
    });
  });

  group('when has BuildOrLayoutPhasePreemptRender', () {
    group('inside one plain-old frame, when has one preemptRender', () {
      void _body({required AdjustedFrameTimeStamp timeWhenPreemptRender}) {
        manager.onBeginFrame(
          currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
          // now: kTenSeconds,
        );
        manager.expect(
          phase: SmoothFramePhase.initial,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
          thresholdActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrameAFTS - kActThresh,
          thresholdActOnPostDrawFramePhaseTimeStamp: null,
        );

        manager.afterBuildOrLayoutPhasePreemptRender(
            now: timeWhenPreemptRender);

        manager.expect(
          phase: SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender,
          // since now is "after" the preemptRender, when talking about timestamps,
          // we threshold mimic it as if we are having a second 60FPS plain old
          // frame.
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 2,
          thresholdActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrameAFTS * 2 - kActThresh,
          thresholdActOnPostDrawFramePhaseTimeStamp: null,
        );

        manager.afterRunAuxPipelineForPlainOld(
            now: timeWhenPreemptRender +
                const AdjustedFrameTimeStamp.unchecked(milliseconds: 2));

        manager.expect(
          phase: SmoothFramePhase.afterRunAuxPipelineForPlainOld,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 2,
          thresholdActOnBuildOrLayoutPhaseTimeStamp: null,
          thresholdActOnPostDrawFramePhaseTimeStamp:
              kTenSeconds + kOneFrameAFTS * 2,
        );
      }

      test('when preemptRender is just before vsync', () {
        _body(
          timeWhenPreemptRender: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 16),
        );
      });

      test('when preemptRender is just after vsync', () {
        _body(
          timeWhenPreemptRender: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 17),
        );
      });
    });

    // let's focus on the second preemptRender
    group('inside one plain-old frame, when has two preemptRender', () {
      void _body({required AdjustedFrameTimeStamp nowWhenSecondPreemptRender}) {
        manager.onBeginFrame(
          currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
          // now: kTenSeconds,
        );

        manager.afterBuildOrLayoutPhasePreemptRender(
            now: kTenSeconds +
                const AdjustedFrameTimeStamp.unchecked(microseconds: 16500));

        manager.afterBuildOrLayoutPhasePreemptRender(
            now: nowWhenSecondPreemptRender);

        manager.expect(
          phase: SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 3,
          thresholdActOnBuildOrLayoutPhaseTimeStamp:
              kTenSeconds + kOneFrameAFTS * 3 - kActThresh,
          thresholdActOnPostDrawFramePhaseTimeStamp: null,
        );

        manager.afterRunAuxPipelineForPlainOld(
            now: nowWhenSecondPreemptRender +
                const AdjustedFrameTimeStamp.unchecked(milliseconds: 2));

        manager.expect(
          phase: SmoothFramePhase.afterRunAuxPipelineForPlainOld,
          currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 3,
          thresholdActOnBuildOrLayoutPhaseTimeStamp: null,
          thresholdActOnPostDrawFramePhaseTimeStamp:
              kTenSeconds + kOneFrameAFTS * 3,
        );
      }

      test('when second preemptRender is just before vsync', () {
        _body(
          nowWhenSecondPreemptRender: kTenSeconds +
              kOneFrameAFTS +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 16),
        );
      });

      test('when second preemptRender is just after vsync', () {
        _body(
          nowWhenSecondPreemptRender: kTenSeconds +
              kOneFrameAFTS +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 17),
        );
      });
    });

    // these are not tested, since when onBeginFrame, old data will be cleared
    // group('when second plain-old frame begins', () {});
  });

  group('when has PostDrawFramePhasePreemptRender', () {
    test('simple case', () {
      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        // now: kTenSeconds,
      );
      manager.afterRunAuxPipelineForPlainOld(
          now: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 16));

      manager.expect(
        phase: SmoothFramePhase.afterRunAuxPipelineForPlainOld,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        thresholdActOnBuildOrLayoutPhaseTimeStamp: null,
        thresholdActOnPostDrawFramePhaseTimeStamp: kTenSeconds + kOneFrameAFTS,
      );

      manager.beforePostDrawFramePhasePreemptRender(
          now: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 17));

      manager.expect(
        phase: SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 2,
        thresholdActOnBuildOrLayoutPhaseTimeStamp: null,
        thresholdActOnPostDrawFramePhaseTimeStamp: null,
      );
    });
  });

  group(
      'when has BuildOrLayoutPhasePreemptRender and PostDrawFramePhasePreemptRender',
      () {
    test('simple case', () {
      manager.onBeginFrame(
        currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
        // now: kTenSeconds,
      );

      manager.afterBuildOrLayoutPhasePreemptRender(
          now: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 16));

      manager.afterRunAuxPipelineForPlainOld(
          now: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 32));

      manager.beforePostDrawFramePhasePreemptRender(
          now: kTenSeconds +
              const AdjustedFrameTimeStamp.unchecked(milliseconds: 34));

      manager.expect(
        phase: SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender,
        currentSmoothFrameTimeStamp: kTenSeconds + kOneFrameAFTS * 3,
        thresholdActOnBuildOrLayoutPhaseTimeStamp: null,
        thresholdActOnPostDrawFramePhaseTimeStamp: null,
      );
    });
  });

  test('reproduce #6128', () {
    manager.onBeginFrame(
      currentFrameTimeStamp: kTenSeconds + kOneFrameAFTS,
      // now: kTenSeconds,
    );

    manager.afterBuildOrLayoutPhasePreemptRender(
        now: kTenSeconds +
            const AdjustedFrameTimeStamp.unchecked(milliseconds: 16));

    manager.afterRunAuxPipelineForPlainOld(
        now: kTenSeconds +
            const AdjustedFrameTimeStamp.unchecked(milliseconds: 20));

    // i.e. threshold *not* have PostDrawFramePhasePreemptRender
    expect(manager.thresholdActOnPostDrawFramePhaseTimeStamp,
        kTenSeconds + kOneFrameAFTS * 2);
  });
}

extension on TimeManager {
  void expect({
    required SmoothFramePhase phase,
    required AdjustedFrameTimeStamp currentSmoothFrameTimeStamp,
    required AdjustedFrameTimeStamp? thresholdActOnBuildOrLayoutPhaseTimeStamp,
    required AdjustedFrameTimeStamp? thresholdActOnPostDrawFramePhaseTimeStamp,
  }) {
    flutter_test.expect(this.phase, phase, reason: 'phase');
    flutter_test.expect(
        this.currentSmoothFrameTimeStamp, currentSmoothFrameTimeStamp,
        reason: 'currentSmoothFrameTimeStamp');
    flutter_test.expect(this.thresholdActOnBuildOrLayoutPhaseTimeStamp,
        thresholdActOnBuildOrLayoutPhaseTimeStamp,
        reason: 'thresholdActOnBuildOrLayoutPhaseTimeStamp');
    flutter_test.expect(this.thresholdActOnPostDrawFramePhaseTimeStamp,
        thresholdActOnPostDrawFramePhaseTimeStamp,
        reason: 'thresholdActOnPostDrawFramePhaseTimeStamp');
  }
}
