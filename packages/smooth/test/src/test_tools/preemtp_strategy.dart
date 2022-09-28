// TODO remove?
// import 'package:flutter/foundation.dart';
// import 'package:smooth/src/preempt_strategy.dart';
//
// class PreemptStrategyTest implements PreemptStrategy {
//   final bool Function({Object? debugToken}) _shouldAct;
//   final ValueGetter<Duration> _currentSmoothFrameTimeStamp;
//
//   PreemptStrategyTest({
//     required bool Function({Object? debugToken}) shouldAct,
//     required ValueGetter<Duration> currentSmoothFrameTimeStamp,
//   })  : _shouldAct = shouldAct,
//         _currentSmoothFrameTimeStamp = currentSmoothFrameTimeStamp;
//
//   @override
//   bool shouldAct({Object? debugToken}) => _shouldAct(debugToken: debugToken);
//
//   @override
//   Duration get currentSmoothFrameTimeStamp => _currentSmoothFrameTimeStamp();
//
//   @override
//   void onPreemptRender() {}
// }
