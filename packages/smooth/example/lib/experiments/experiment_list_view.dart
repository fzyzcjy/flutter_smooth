import 'package:flutter/material.dart';

class ExperimentListView extends StatefulWidget {
  const ExperimentListView({super.key});

  @override
  State<ExperimentListView> createState() => _ExperimentListViewState();
}

class _ExperimentListViewState extends State<ExperimentListView> {
  final controller = _MyScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          controller: controller,
          itemBuilder: (_, index) => ListTile(
            title: Text('i=$index'),
          ),
        ),
      ),
    );
  }
}

class _MyScrollController extends ScrollController {
  // ref [super.createScrollPosition], except for return custom sub-class
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _MyScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _MyScrollPositionWithSingleContext
    extends ScrollPositionWithSingleContext {
  _MyScrollPositionWithSingleContext({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  // why "cloned": because [Simulation]'s doc says, some subclasses will change
  // state when called, and must only call with monotonic timestamps.
  Simulation? get lastSimulationCloned => _lastSimulationCloned;
  Simulation? _lastSimulationCloned;

  // ref [super.createScrollPosition], except for marked regions
  @override
  void goBallistic(double velocity) {
    assert(hasPixels);
    final simulation = physics.createBallisticSimulation(this, velocity);
    if (simulation != null) {
      // NOTE MODIFIED start
      _lastSimulationCloned = physics.createBallisticSimulation(this, velocity);
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

extension on ScrollableState {
  _MyScrollPositionWithSingleContext get positionTyped =>
      position as _MyScrollPositionWithSingleContext;
}
