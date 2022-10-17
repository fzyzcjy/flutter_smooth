import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart'; // ignore: implementation_imports
import 'package:smooth/src/drop_in/list_view/physics.dart';
import 'package:smooth/src/drop_in/list_view/simulation.dart'; // ignore: implementation_imports

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

  SimulationInfo? get activeBallisticSimulationInfo {
    final activity = this.activity;
    if (activity is! _SmoothBallisticScrollActivity) return null;
    return activity.info;
  }

  SmoothScrollPhysics get _physicsTyped => physics as SmoothScrollPhysics;

  _SmoothBallisticScrollActivity? get _previousBallisticActivity {
    final activity = this.activity;
    return activity is _SmoothBallisticScrollActivity ? activity : null;
  }

  // ref [super.createScrollPosition], except for marked regions
  @override
  void goBallistic(double velocity) {
    // print('hi $runtimeType.goBallistic velocity=$velocity');
    // debugPrintStack();

    assert(hasPixels);

    final previousBallisticActivity = _previousBallisticActivity;

    Simulation? createSimulation() =>
        _physicsTyped.createBallisticSimulationEnhanced(
          this,
          velocity,
          previous: previousBallisticActivity?.info.realSimulation.inner,
          potentialTimeShiftFromPrevious: (previousBallisticActivity
                      ?.controller.lastElapsedDuration?.inMicroseconds ??
                  0) /
              1000000,
        );

    final simulation = MemorizedSimulation.wrap(createSimulation());

    if (simulation != null) {
      beginActivity(_SmoothBallisticScrollActivity(
        this,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? true,
        // NOTE need to create a *new* simulation, not the old one.
        //      Because [Simulation]'s doc says, some subclasses will change
        //      state when called, and must only call with monotonic timestamps.
        clonedSimulation: createSimulation()!,
      ));

      Timeline.timeSync(
          'goBallistic',
          arguments: <String, String>{
            'info': activity.toString(),
            'this': toString(),
            'pixels': pixels.toString(),
            'velocity': velocity.toString(),
          },
          () {});
    } else {
      Timeline.timeSync(
          'goBallistic',
          arguments: <String, String>{'info': 'choose to goIdle'},
          () {});

      goIdle();
    }
  }
}

class _SmoothBallisticScrollActivity extends BallisticScrollActivity {
  factory _SmoothBallisticScrollActivity(
    ScrollActivityDelegate delegate,
    MemorizedSimulation simulation,
    TickerProvider vsync,
    bool shouldIgnorePointer, // ignore: avoid_positional_boolean_parameters
    {
    required Simulation clonedSimulation,
  }) {
    late final Ticker createdTicker;

    final ans = _SmoothBallisticScrollActivity.raw(
      delegate,
      simulation,
      LambdaTickerProvider((onTick) {
        createdTicker = vsync.createTicker(onTick);
        return createdTicker;
      }),
      shouldIgnorePointer,
    );

    ans.info = SimulationInfo(
      realSimulation: simulation,
      ballisticScrollActivityTicker: createdTicker,
      clonedSimulation: clonedSimulation,
    );

    return ans;
  }

  _SmoothBallisticScrollActivity.raw(
    super.delegate,
    super.simulation,
    super.vsync,
    // ignore: avoid_positional_boolean_parameters
    super.shouldIgnorePointer,
  );

  // some extra fields
  late final SimulationInfo info;

  @override
  String toString() => '${super.toString()}(info: $info)';
}

// TODO move
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
