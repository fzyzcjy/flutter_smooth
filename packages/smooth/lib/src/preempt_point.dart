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
  final Object? debugToken;
  final Widget child;

  const BuildPreemptPointWidget({
    super.key,
    this.debugToken,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ServiceLocator.instance.actor.maybePreemptRender(debugToken: debugToken);
    return child;
  }
}

@visibleForTesting
class LayoutPreemptPointWidget extends SingleChildRenderObjectWidget {
  final Object? debugToken;

  const LayoutPreemptPointWidget({
    super.key,
    this.debugToken,
    super.child,
  });

  @override
  RenderLayoutPreemptPoint createRenderObject(BuildContext context) =>
      RenderLayoutPreemptPoint(debugToken: debugToken);

  @override
  void updateRenderObject(
      BuildContext context, RenderLayoutPreemptPoint renderObject) {
    renderObject.debugToken = debugToken;
  }
}

@visibleForTesting
class RenderLayoutPreemptPoint extends RenderProxyBox {
  RenderLayoutPreemptPoint({
    required this.debugToken,
    RenderBox? child,
  }) : super(child);

  Object? debugToken;

  @override
  void performLayout() {
    print('$runtimeType.performLayout');
    ServiceLocator.instance.actor.maybePreemptRender(debugToken: debugToken);
    super.performLayout();
  }
}
