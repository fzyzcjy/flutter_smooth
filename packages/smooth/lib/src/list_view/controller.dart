import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:smooth/src/list_view/simulation.dart'; // ignore: implementation_imports

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
    print('hi $runtimeType.goBallistic velocity=$velocity');
    debugPrintStack();

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
        realSimulation: simulation,
        ballisticScrollActivityTicker: ballisticScrollActivityTicker,
        clonedSimulation: physics.createBallisticSimulation(this, velocity)!,
      );
      // NOTE MODIFIED end

      Timeline.timeSync(
          'goBallistic',
          arguments: <String, String>{
            'info': _lastSimulationInfo.value.toString(),
            'this': toString(),
            'pixels': pixels.toString(),
            'velocity': velocity.toString(),
          },
          () {});
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
  final MemorizedSimulation realSimulation;
  final Ticker ballisticScrollActivityTicker;
  final Simulation clonedSimulation;

  const SimulationInfo({
    required this.realSimulation,
    required this.ballisticScrollActivityTicker,
    required this.clonedSimulation,
  });

  @override
  String toString() => 'SimulationInfo{'
      'realSimulation: $realSimulation, '
      'ballisticScrollActivityTicker: $ballisticScrollActivityTicker, '
      'clonedSimulation: $clonedSimulation'
      '}';
}
