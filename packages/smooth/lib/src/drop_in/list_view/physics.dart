import 'package:flutter/cupertino.dart';
import 'package:smooth/src/drop_in/list_view/simulation.dart';

abstract class SmoothScrollPhysics implements ScrollPhysics {
  Simulation? createBallisticSimulationEnhanced(
      ScrollMetrics position, double velocity,
      {required Simulation? previous,
      required double potentialTimeShiftFromPrevious});
}

class SmoothClampingScrollPhysics extends ClampingScrollPhysics
    implements SmoothScrollPhysics {
  const SmoothClampingScrollPhysics({super.parent});

  @override
  SmoothClampingScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      SmoothClampingScrollPhysics(parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulationEnhanced(
      ScrollMetrics position, double velocity,
      {required Simulation? previous,
      required double potentialTimeShiftFromPrevious}) {
    final raw = super.createBallisticSimulation(position, velocity);
    if (raw is! ClampingScrollSimulation) return raw;

    final ClampingScrollSimulation effectivePrevious;
    final double effectivePotentialTimeShiftFromPrevious;
    if (previous is ShiftingSimulation) {
      effectivePrevious = previous.inner as ClampingScrollSimulation;
      effectivePotentialTimeShiftFromPrevious =
          potentialTimeShiftFromPrevious + previous.timeShift;
    } else if (previous is ClampingScrollSimulation) {
      effectivePrevious = previous;
      effectivePotentialTimeShiftFromPrevious = potentialTimeShiftFromPrevious;
    } else {
      return raw;
    }

    final potentialPositionShiftFromPrevious = raw.position -
        effectivePrevious.x(effectivePotentialTimeShiftFromPrevious);
    final isSuccessor = _isSuccessor(
      raw: raw,
      previous: effectivePrevious,
      timeShiftFromPrevious: effectivePotentialTimeShiftFromPrevious,
      positionShiftFromPrevious: potentialPositionShiftFromPrevious,
    );

    // print('hi $runtimeType.createBallisticSimulationEnhanced '
    //     'position=$position velocity=$velocity '
    //     'raw=$raw previous=$previous '
    //     'effectivePrevious=$effectivePrevious '
    //     'potentialTimeShiftFromPrevious=$potentialTimeShiftFromPrevious '
    //     'effectivePotentialTimeShiftFromPrevious=$effectivePotentialTimeShiftFromPrevious '
    //     'potentialPositionShiftFromPrevious=$potentialPositionShiftFromPrevious '
    //     'isSuccessor=$isSuccessor');

    if (!isSuccessor) return raw;

    return ShiftingSimulation(
      effectivePrevious,
      timeShift: effectivePotentialTimeShiftFromPrevious,
      positionShift: potentialPositionShiftFromPrevious,
    );
  }

  static bool _isSuccessor({
    required ClampingScrollSimulation raw,
    required ClampingScrollSimulation previous,
    required double timeShiftFromPrevious,
    required double positionShiftFromPrevious,
  }) {
    // check all constructor arguments of [raw]
    return _roughlyEquals(raw.position,
            previous.x(timeShiftFromPrevious) + positionShiftFromPrevious) &&
        _roughlyEquals(raw.velocity, previous.dx(timeShiftFromPrevious)) &&
        _roughlyEquals(raw.friction, previous.friction);
  }
}

bool _roughlyEquals(double a, double b, {double eps = 1e-5}) {
  final delta = a - b;
  return delta > -eps && delta < eps;
}
