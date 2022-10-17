import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/infra/service_locator.dart';

// NOTE since prototype, we inject preempt point *manually*.
// However, in real api, it should be done in RenderObject.layout, i.e. automatically
// without human intervention
class SmoothBuildPreemptPointWidget extends StatelessWidget {
  final Widget child;

  const SmoothBuildPreemptPointWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ServiceLocator.instance.actor.maybePreemptRenderBuildOrLayoutPhase();
    return child;
  }
}

class SmoothLayoutPreemptPointWidget extends SingleChildRenderObjectWidget {
  const SmoothLayoutPreemptPointWidget({super.key, super.child});

  @override
  RenderLayoutPreemptPoint createRenderObject(BuildContext context) =>
      RenderLayoutPreemptPoint();

  @override
  void updateRenderObject(
      BuildContext context, RenderLayoutPreemptPoint renderObject) {}
}

@visibleForTesting
class RenderLayoutPreemptPoint extends RenderProxyBox {
  RenderLayoutPreemptPoint({
    RenderBox? child,
  }) : super(child);

  @override
  void performLayout() {
    // print('$runtimeType.performLayout');
    ServiceLocator.instance.actor.maybePreemptRenderBuildOrLayoutPhase();
    super.performLayout();
  }
}
