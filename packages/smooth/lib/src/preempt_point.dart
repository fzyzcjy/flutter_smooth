import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/actor.dart';

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
    return _BuildPreemptPointWidget(
      child: _LayoutPreemptPointWidget(
        child: child,
      ),
    );
  }
}

class _BuildPreemptPointWidget extends StatelessWidget {
  final Widget child;

  const _BuildPreemptPointWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    Actor.instance.maybePreemptRender();
    return child;
  }
}

class _LayoutPreemptPointWidget extends SingleChildRenderObjectWidget {
  const _LayoutPreemptPointWidget({
    super.child,
  });

  @override
  _RenderLayoutPreemptPoint createRenderObject(BuildContext context) =>
      _RenderLayoutPreemptPoint();

  @override
  void updateRenderObject(
      BuildContext context, _RenderLayoutPreemptPoint renderObject) {}
}

class _RenderLayoutPreemptPoint extends RenderProxyBox {
  _RenderLayoutPreemptPoint({
    RenderBox? child,
  }) : super(child);

  @override
  void performLayout() {
    Actor.instance.maybePreemptRender();
    super.performLayout();
  }
}
