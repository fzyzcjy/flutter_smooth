import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/infra/service_locator.dart';

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
  static const kActThresh =
      AdjustedFrameTimeStamp.unchecked(microseconds: 2 * 1000);

  TimeManager();

  SmoothFramePhase phase = SmoothFramePhase.afterRunAuxPipelineForPlainOld;

  /// Fancy version of [SchedulerBinding.currentFrameTimeStamp],
  /// by considering both plain-old frames and also smooth extra frames.
  ///
  /// When confused about the correct value of this field, just think about
  /// how we mimic the [SchedulerBinding.currentFrameTimeStamp].
  AdjustedFrameTimeStamp get currentSmoothFrameTimeStamp =>
      _currentSmoothFrameTimeStamp!;
  AdjustedFrameTimeStamp? _currentSmoothFrameTimeStamp;

  /// When now > this timestamp, should act; otherwise, should not act.
  ///
  /// null means invalid (e.g. we are in a phase that has no meaningful value)
  AdjustedFrameTimeStamp? get thresholdActOnBuildOrLayoutPhaseTimeStamp {
    if (!(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender)) {
      return null;
    }

    return currentSmoothFrameTimeStamp - kActThresh;
  }

  AdjustedFrameTimeStamp? get thresholdActOnPostDrawFramePhaseTimeStamp {
    if (phase != SmoothFramePhase.afterRunAuxPipelineForPlainOld) return null;
    return currentSmoothFrameTimeStamp;
  }

  void onBeginFrame({required AdjustedFrameTimeStamp currentFrameTimeStamp}) {
    assert(phase == SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender ||
        phase == SmoothFramePhase.afterRunAuxPipelineForPlainOld);
    phase = SmoothFramePhase.initial;

    _currentSmoothFrameTimeStamp = currentFrameTimeStamp;
  }

  void afterBuildOrLayoutPhasePreemptRender(
      {required AdjustedFrameTimeStamp now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    assert(thresholdActOnBuildOrLayoutPhaseTimeStamp! <= now);
    phase = SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender;

    // https://github.com/fzyzcjy/yplusplus/issues/6162#issuecomment-1276068643
    final nextVsync =
        vsyncLaterThan(time: now, baseVsync: _currentSmoothFrameTimeStamp!);
    final nextVsyncInFarFuture = nextVsync - now >
        const AdjustedFrameTimeStamp.unchecked(microseconds: 12 * 1000);
    final newSmoothFrameTimeStamp = nextVsync +
        (nextVsyncInFarFuture
            ? const AdjustedFrameTimeStamp.uncheckedZero()
            : kOneFrameAFTS);

    assert(newSmoothFrameTimeStamp > _currentSmoothFrameTimeStamp!,
        'newSmoothFrameTimeStamp=$newSmoothFrameTimeStamp should be greater than _currentSmoothFrameTimeStamp=$_currentSmoothFrameTimeStamp');
    _currentSmoothFrameTimeStamp = newSmoothFrameTimeStamp;
  }

  void afterRunAuxPipelineForPlainOld({required AdjustedFrameTimeStamp now}) {
    assert(phase == SmoothFramePhase.initial ||
        phase == SmoothFramePhase.afterBuildOrLayoutPhasePreemptRender);
    phase = SmoothFramePhase.afterRunAuxPipelineForPlainOld;
  }

  void beforePostDrawFramePhasePreemptRender(
      {required AdjustedFrameTimeStamp now}) {
    assert(phase == SmoothFramePhase.afterRunAuxPipelineForPlainOld);
    assert(thresholdActOnPostDrawFramePhaseTimeStamp! <= now);
    phase = SmoothFramePhase.onOrAfterPostDrawFramePhasePreemptRender;

    _currentSmoothFrameTimeStamp =
        _currentSmoothFrameTimeStamp! + kOneFrameAFTS;
  }

  static AdjustedFrameTimeStamp get normalNow =>
      ServiceLocator.instance.timeConverter
          .dateTimeToAdjustedFrameTimeStamp(clock.nowSimple());

  @visibleForTesting
  static AdjustedFrameTimeStamp vsyncLaterThan({
    required AdjustedFrameTimeStamp time,
    required AdjustedFrameTimeStamp baseVsync,
  }) {
    final diffMicroseconds = time.inMicroseconds - baseVsync.inMicroseconds;
    return baseVsync +
        AdjustedFrameTimeStamp.unchecked(
          microseconds: (diffMicroseconds / kOneFrameUs).ceil() * kOneFrameUs,
        );
  }
}
