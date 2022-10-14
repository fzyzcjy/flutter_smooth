import 'package:flutter/cupertino.dart';
import 'package:smooth/src/list_view/simulation.dart';

abstract class SmoothScrollPhysics implements ScrollPhysics {
  @override
  Simulation? createBallisticSimulationEnhanced(
      ScrollMetrics position, double velocity,
      {required Simulation? previous, required double previousTimeShift});
}

class SmoothClampingScrollPhysics extends ClampingScrollPhysics
    implements SmoothScrollPhysics {
  @override
  Simulation? createBallisticSimulationEnhanced(
      ScrollMetrics position, double velocity,
      {required Simulation? previous, required double previousTimeShift}) {
    final raw = super.createBallisticSimulation(position, velocity);

    if (raw is ClampingScrollSimulation &&
        previous is ClampingScrollSimulation &&
        _simulationsEqualExceptPositionAndTimeShift(
          raw: raw,
          previous: previous,
          previousTimeShift: previousTimeShift,
        )) {
      return ShiftingSimulation(
        previous,
        timeShift: previousTimeShift,
        positionShift: positionShift,
      );
    }

    return raw;
  }

  static bool _simulationsEqualExceptPositionAndTimeShift({
    required ClampingScrollSimulation raw,
    required ClampingScrollSimulation previous,
    required double previousTimeShift,
  }) {
    return TODO_position &&
        TODO_velocity &&
        _roughlyEquals(raw.friction, previous.friction);
  }
}

bool _roughlyEquals(double a, double b, {double eps = 1e-5}) {
  final delta = a - b;
  return delta > -eps && delta < eps;
}
