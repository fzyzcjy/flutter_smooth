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
  afterPostDrawFramePhasePreemptRender,
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

  Duration get shouldActOnBuildOrLayoutPhaseTimeStamp => TODO;

  Duration get shouldActOnPostDrawFramePhaseTimeStamp => TODO;

  void onBeginFrame({
    required Duration currentFrameTimeStamp,
    required Duration now,
  }) {
    assert(phase == SmoothFramePhase.afterPostDrawFramePhasePreemptRender ||
        phase == SmoothFramePhase.afterPlainOldRender);
    phase = SmoothFramePhase.initial;

    TODO;
  }

  /// Please call it *after* the preemptRender finishes
  void afterBuildOrLayoutPhasePreemptRender({required Duration now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    assert(shouldActOnBuildOrLayoutPhaseTimeStamp <= now);
    phase = SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender;

    TODO;
  }

  void afterPlainOldRender({required Duration now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    phase = SmoothFramePhase.afterPlainOldRender;

    TODO;
  }

  /// Please call it *after* the preemptRender finishes
  void afterPostDrawFramePhasePreemptRender({required Duration now}) {
    assert(phase == SmoothFramePhase.afterPlainOldRender);
    assert(shouldActOnPostDrawFramePhaseTimeStamp <= now);
    phase = SmoothFramePhase.afterPostDrawFramePhasePreemptRender;

    TODO;
  }

  static Duration normalNowTimeStamp() => TimeConverter.instance
      .dateTimeToAdjustedFrameTimeStamp(clock.nowSimple());
}
