import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/enhanced_padding.dart';

class SmoothListView extends StatefulWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final double? cacheExtent;

  const SmoothListView.builder({
    super.key,
    this.cacheExtent,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  State<SmoothListView> createState() => _SmoothListViewState();
}

class _SmoothListViewState extends State<SmoothListView> {
  final controller = _SmoothScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cacheExtent =
        widget.cacheExtent ?? RenderAbstractViewport.defaultCacheExtent;
    final effectiveItemCount = widget.itemCount + 2;

    return SmoothBuilder(
      builder: (context, child) => ClipRect(
        child: SmoothShift(
          child: child,
        ),
      ),
      child: EnhancedPadding(
        enableAllowNegativePadding: true,
        padding: EdgeInsets.only(
          top: -cacheExtent,
          bottom: -cacheExtent,
        ),
        child: ListView.builder(
          controller: controller,
          // NOTE set [cacheExtent] here to zero, because we will use overflow box
          cacheExtent: 0,
          itemCount: effectiveItemCount,
          itemBuilder: (context, index) {
            if (index == 0 || index == effectiveItemCount - 1) {
              return SizedBox(height: cacheExtent);
            }
            return widget.itemBuilder(context, index - 1);
          },
        ),
      ),
    );
  }
}

class _SmoothScrollController extends ScrollController {
  // ref [super.createScrollPosition], except for return custom sub-class
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SmoothScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _SmoothScrollPositionWithSingleContext
    extends ScrollPositionWithSingleContext {
  _SmoothScrollPositionWithSingleContext({
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

extension on ScrollableState {
  _SmoothScrollPositionWithSingleContext get positionTyped =>
      position as _SmoothScrollPositionWithSingleContext;
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
