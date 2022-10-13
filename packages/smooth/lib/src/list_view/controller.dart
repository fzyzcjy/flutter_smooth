import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';

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

  ValueListenable<SimulationInfo?> get lastSimulationInfo =>
      _lastSimulationInfo;
  final _lastSimulationInfo = ValueNotifier<SimulationInfo?>(null);

  // ref [super.createScrollPosition], except for marked regions
  @override
  void goBallistic(double velocity) {
    print('hi goBallistic velocity=$velocity');

    assert(hasPixels);

    // NOTE MODIFIED start
    // use [MemorizedSimulation] to wrap
    final simulation = MemorizedSimulation.wrap(
        physics.createBallisticSimulation(this, velocity));
    // NOTE MODIFIED end

    if (simulation != null) {
      late final Ticker ballisticScrollActivityTicker;

      beginActivity(BallisticScrollActivity(
        this,
        simulation,
        // NOTE MODIFIED start
        LambdaTickerProvider((onTick) {
          ballisticScrollActivityTicker = context.vsync.createTicker(onTick);
          return ballisticScrollActivityTicker;
        }),
        // context.vsync,
        // NOTE MODIFIED end
        activity?.shouldIgnorePointer ?? true,
      ));

      // NOTE MODIFIED start
      // NOTE need to create a *new* simulation, not the old one.
      //      Because [Simulation]'s doc says, some subclasses will change
      //      state when called, and must only call with monotonic timestamps.
      _lastSimulationInfo.value = SimulationInfo(
        ballisticScrollActivityTicker: ballisticScrollActivityTicker,
        clonedSimulation: physics.createBallisticSimulation(this, velocity)!,
      );
      // NOTE MODIFIED end
    } else {
      goIdle();
    }
  }
}

class LambdaTickerProvider implements TickerProvider {
  final Ticker Function(TickerCallback onTick) _createTicker;

  const LambdaTickerProvider(this._createTicker);

  @override
  Ticker createTicker(TickerCallback onTick) => _createTicker(onTick);
}

class SimulationInfo {
  final Ticker ballisticScrollActivityTicker;
  final Simulation clonedSimulation;

  const SimulationInfo({
    required this.ballisticScrollActivityTicker,
    required this.clonedSimulation,
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

  @override
  String toString() => 'ProxySimulation($inner)';
}