import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

class SmoothScrollController extends ScrollController {
  // ref [super.createScrollPosition], except for return custom sub-class
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return SmoothScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class SmoothScrollPositionWithSingleContext
    extends ScrollPositionWithSingleContext {
  static SmoothScrollPositionWithSingleContext of(
          ScrollController controller) =>
      controller.position as SmoothScrollPositionWithSingleContext;

  SmoothScrollPositionWithSingleContext({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  SimulationInfo? get lastSimulationInfo => _lastSimulationInfo;
  SimulationInfo? _lastSimulationInfo;

  // ref [super.createScrollPosition], except for marked regions
  @override
  void goBallistic(double velocity) {
    assert(hasPixels);

    // NOTE MODIFIED start
    // use [MemorizedSimulation] to wrap
    final simulation = MemorizedSimulation.wrap(
        physics.createBallisticSimulation(this, velocity));
    // NOTE MODIFIED end

    if (simulation != null) {
      // NOTE MODIFIED start
      // NOTE need to create a *new* simulation, not the old one.
      //      Because [Simulation]'s doc says, some subclasses will change
      //      state when called, and must only call with monotonic timestamps.
      _lastSimulationInfo = SimulationInfo(
        realSimulation: simulation,
        clonedSimulation: physics.createBallisticSimulation(this, velocity)!,
        // TODO correct? should we "+kOneFrame"?
        startTimeStamp:
            SchedulerBinding.instance.currentFrameTimeStamp + kOneFrame,
      );
      // NOTE MODIFIED end

      beginActivity(BallisticScrollActivity(
        this,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? true,
      ));
    } else {
      goIdle();
    }
  }
}

class SimulationInfo {
  final MemorizedSimulation realSimulation;
  final Simulation clonedSimulation;

  /// When the [clonedSimulation] is used in the animation in [BallisticScrollActivity],
  /// what is the start time stamp of that animation.
  final Duration startTimeStamp;

  const SimulationInfo({
    required this.realSimulation,
    required this.clonedSimulation,
    required this.startTimeStamp,
  });
}

class MemorizedSimulation extends ProxySimulation {
  MemorizedSimulation(super.inner);

  static MemorizedSimulation? wrap(Simulation? inner) =>
      inner == null ? null : MemorizedSimulation(inner);

  double? get lastX => _lastX;
  double? _lastX;

  @override
  double x(double time) {
    final ans = super.x(time);
    _lastX = ans;
    return ans;
  }
}

class ProxySimulation extends Simulation {
  final Simulation inner;

  ProxySimulation(this.inner);

  @override
  double x(double time) => inner.x(time);

  @override
  double dx(double time) => inner.dx(time);

  @override
  bool isDone(double time) => inner.isDone(time);
}
