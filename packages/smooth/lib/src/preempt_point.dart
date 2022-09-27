import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/service_locator.dart';

// NOTE since prototype, we inject preempt point *manually*.
// However, in real api, it should be done in RenderObject.layout, i.e. automatically
// without human intervention
class SmoothPreemptPoint extends StatelessWidget {
  final Widget child;

  const SmoothPreemptPoint({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BuildPreemptPointWidget(
      child: LayoutPreemptPointWidget(
        child: child,
      ),
    );
  }
}

@visibleForTesting
class BuildPreemptPointWidget extends StatelessWidget {
  final Widget child;

  const BuildPreemptPointWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ServiceLocator.instance.actor.maybePreemptRender();
    return child;
  }
}

@visibleForTesting
class LayoutPreemptPointWidget extends SingleChildRenderObjectWidget {
  const LayoutPreemptPointWidget({super.key, super.child});

  @override
  RenderLayoutPreemptPoint createRenderObject(BuildContext context) =>
      RenderLayoutPreemptPoint();

  @override
  void updateRenderObject(
      BuildContext context, RenderLayoutPreemptPoint renderObject) {}
}

@visibleForTesting
class RenderLayoutPreemptPoint extends RenderProxyBox {
  RenderLayoutPreemptPoint({RenderBox? child}) : super(child);

  @override
  void performLayout() {
    ServiceLocator.instance.actor.maybePreemptRender();
    super.performLayout();
  }
}
