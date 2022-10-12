import 'package:clock/clock.dart';
import 'package:smooth/smooth.dart';
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
  afterRunAuxPipelineForPlainOld,

  /// PostDrawFrame phase preemptRender happens
  ///
  /// This can happen zero or one time in one frame.
  /// If it does not happen, this variant will not appear.
  onOrAfterPostDrawFramePhasePreemptRender,
}

class TimeManager {
  static const kActThresh = Duration(milliseconds: 2);

  TimeManager();

  SmoothFramePhase phase = SmoothFramePhase.afterRunAuxPipelineForPlainOld;

  /// Fancy version of [SchedulerBinding.currentFrameTimeStamp],
  /// by considering both plain-old frames and also smooth extra frames.
  ///
  /// When confused about the correct value of this field, just think about
  /// how we mimic the [SchedulerBinding.currentFrameTimeStamp].
  Duration get currentSmoothFrameTimeStamp => _currentSmoothFrameTimeStamp!;
  Duration? _currentSmoothFrameTimeStamp;

  /// When now > this timestamp, should act; otherwise, should not act.
  ///
  /// null means invalid (e.g. we are in a phase that has no meaningful value)
  Duration? get thresholdActOnBuildOrLayoutPhaseTimeStamp {
    if (!(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender)) {
      return null;
    }

    return currentSmoothFrameTimeStamp - kActThresh;
  }

  Duration? get thresholdActOnPostDrawFramePhaseTimeStamp {
    if (phase != SmoothFramePhase.afterRunAuxPipelineForPlainOld) return null;
    return currentSmoothFrameTimeStamp;
  }

  void onBeginFrame({required Duration currentFrameTimeStamp}) {
    assert(phase == SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender ||
        phase == SmoothFramePhase.afterRunAuxPipelineForPlainOld);
    phase = SmoothFramePhase.initial;

    _currentSmoothFrameTimeStamp = currentFrameTimeStamp;
  }

  void afterBuildOrLayoutPhasePreemptRender({required Duration now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    assert(thresholdActOnBuildOrLayoutPhaseTimeStamp! <= now);
    phase = SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender;

    _currentSmoothFrameTimeStamp = _currentSmoothFrameTimeStamp! + kOneFrame;
  }

  void afterRunAuxPipelineForPlainOld({required Duration now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    phase = SmoothFramePhase.afterRunAuxPipelineForPlainOld;
  }

  void beforePostDrawFramePhasePreemptRender({required Duration now}) {
    assert(phase == SmoothFramePhase.afterRunAuxPipelineForPlainOld);
    assert(thresholdActOnPostDrawFramePhaseTimeStamp! <= now);
    phase = SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender;

    _currentSmoothFrameTimeStamp = _currentSmoothFrameTimeStamp! + kOneFrame;
  }

  static Duration get normalNow => TimeConverter.instance
      .dateTimeToAdjustedFrameTimeStamp(clock.nowSimple());
}
