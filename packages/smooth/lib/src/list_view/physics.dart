import 'package:flutter/cupertino.dart';
import 'package:smooth/src/list_view/simulation.dart';

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

    if (!(raw is ClampingScrollSimulation &&
        previous is ClampingScrollSimulation)) return raw;

    final potentialPositionShiftFromPrevious =
        raw.position - previous.x(potentialTimeShiftFromPrevious);
    final isSuccessor = _isSuccessor(
      raw: raw,
      previous: previous,
      timeShiftFromPrevious: potentialTimeShiftFromPrevious,
      positionShiftFromPrevious: potentialPositionShiftFromPrevious,
    );

    print('hi $runtimeType.createBallisticSimulationEnhanced '
        'position=$position velocity=$velocity '
        'raw=$raw previous=$previous '
        'potentialTimeShiftFromPrevious=$potentialTimeShiftFromPrevious '
        'potentialPositionShiftFromPrevious=$potentialPositionShiftFromPrevious '
        'isSuccessor=$isSuccessor');

    if (!isSuccessor) return raw;

    return ShiftingSimulation(
      previous,
      timeShift: potentialTimeShiftFromPrevious,
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
