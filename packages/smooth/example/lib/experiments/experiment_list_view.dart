import 'package:flutter/foundation.dart';
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
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    // ref [super.createScrollPosition]
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

  @override
  void goBallistic(double velocity) {
    // ref [super.createScrollPosition]
    assert(hasPixels);
    final simulation = physics.createBallisticSimulation(this, velocity);
    if (simulation != null) {
      // TODO do something here?
      print('hi ${describeIdentity(this)}.goBallistic simulation=$simulation');

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
