import 'package:flutter/foundation.dart';
import 'package:smooth/src/preempt_strategy.dart';

class PreemptStrategyTest implements PreemptStrategy {
  final ValueGetter<bool> _shouldAct;
  final ValueGetter<Duration> _currentSmoothFrameTimeStamp;

  PreemptStrategyTest({
    required ValueGetter<bool> shouldAct,
    required ValueGetter<Duration> currentSmoothFrameTimeStamp,
  })  : _shouldAct = shouldAct,
        _currentSmoothFrameTimeStamp = currentSmoothFrameTimeStamp;

  @override
  bool get shouldAct => _shouldAct();

  @override
  Duration get currentSmoothFrameTimeStamp => _currentSmoothFrameTimeStamp;

  @override
  void onPreemptRender() {}
}
