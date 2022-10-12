import 'package:clock/clock.dart';
import 'package:smooth/src/simple_date_time.dart';
import 'package:smooth/src/time_converter.dart';

enum SmoothFramePhase {
  /// A new frame starts, and no preemptRender happens yet
  initial,

  /// Build/Layout phase preemptRender happens
  ///
  /// This can happen zero to many times in one frame
  /// If it does not happen, this variant will not appear.
  afterBuildOrLayoutPhasePreemptRender,

  /// The plain-old pipeline renders (i.e. about to submit window.render)
  afterPlainOldRender,

  /// PostDrawFrame phase preemptRender happens
  ///
  /// This can happen zero or one time in one frame.
  /// If it does not happen, this variant will not appear.
  onOrAfterPostDrawFramePhasePreemptRender,
}

class TimeManager {
  static const kActThresh = Duration(milliseconds: 2);

  TimeManager();

  SmoothFramePhase phase = SmoothFramePhase.initial;

  /// Fancy version of [SchedulerBinding.currentFrameTimeStamp],
  /// by considering both plain-old frames and also smooth extra frames.
  ///
  /// When confused about the correct value of this field, just think about
  /// how we mimic the [SchedulerBinding.currentFrameTimeStamp].
  Duration get currentSmoothFrameTimeStamp => TODO;

  /// When now > this timestamp, should act; otherwise, should not act.
  ///
  /// null means invalid (e.g. we are in a phase that has no meaningful value)
  Duration? get thresholdActOnBuildOrLayoutPhaseTimeStamp {
    if (!(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender)) {
      return null;
    }

    return TODO;
  }

  Duration? get thresholdActOnPostDrawFramePhaseTimeStamp {
    if (phase != SmoothFramePhase.afterPlainOldRender) return null;

    return TODO;
  }

  void onBeginFrame({
    required Duration currentFrameTimeStamp,
    required Duration now,
  }) {
    assert(phase == SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender ||
        phase == SmoothFramePhase.afterPlainOldRender);
    phase = SmoothFramePhase.initial;

    TODO;
  }

  void afterBuildOrLayoutPhasePreemptRender({required Duration now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    assert(thresholdActOnBuildOrLayoutPhaseTimeStamp! <= now);
    phase = SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender;

    TODO;
  }

  void afterPlainOldRender({required Duration now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    phase = SmoothFramePhase.afterPlainOldRender;

    TODO;
  }

  void beforePostDrawFramePhasePreemptRender({required Duration now}) {
    assert(phase == SmoothFramePhase.afterPlainOldRender);
    assert(thresholdActOnPostDrawFramePhaseTimeStamp! <= now);
    phase = SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender;

    TODO;
  }

  static Duration normalNowTimeStamp() => TimeConverter.instance
      .dateTimeToAdjustedFrameTimeStamp(clock.nowSimple());
}
