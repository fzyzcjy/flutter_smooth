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
  static SmoothScrollPositionWithSingleContext of(ScrollableState state) =>
      state.position as SmoothScrollPositionWithSingleContext;

  SmoothScrollPositionWithSingleContext({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  SimulationInfo? get lastSimulation => _lastSimulation;
  SimulationInfo? _lastSimulation;

  // ref [super.createScrollPosition], except for marked regions
  @override
  void goBallistic(double velocity) {
    assert(hasPixels);
    final simulation = physics.createBallisticSimulation(this, velocity);
    if (simulation != null) {
      // NOTE MODIFIED start
      // NOTE need to create a *new* simulation, not the old one.
      //      Because [Simulation]'s doc says, some subclasses will change
      //      state when called, and must only call with monotonic timestamps.
      _lastSimulation = SimulationInfo(
        simulation: physics.createBallisticSimulation(this, velocity)!,
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
  final Simulation simulation;

  /// When the [simulation] is used in the animation in [BallisticScrollActivity],
  /// what is the start time stamp of that animation.
  final Duration startTimeStamp;

  const SimulationInfo({
    required this.simulation,
    required this.startTimeStamp,
  });
}
