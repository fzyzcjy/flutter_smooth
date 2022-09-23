// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_package/demo/impl/actor.dart';

// NOTE since prototype, we inject preempt point *manually*.
// However, in real api, it should be done in RenderObject.layout, i.e. automatically
// without human intervention
class PreemptPoint extends StatelessWidget {
  final int dummy;
  final Widget child;

  const PreemptPoint({
    super.key,
    required this.dummy,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _BuildPreemptPointWidget(
      child: _LayoutPreemptPointWidget(
        dummy: dummy,
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
  final int dummy;

  const _LayoutPreemptPointWidget({
    required this.dummy,
    super.child,
  });

  @override
  _RenderLayoutPreemptPoint createRenderObject(BuildContext context) =>
      _RenderLayoutPreemptPoint(
        dummy: dummy,
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderLayoutPreemptPoint renderObject) {
    renderObject.dummy = dummy;
  }
}

class _RenderLayoutPreemptPoint extends RenderProxyBox {
  _RenderLayoutPreemptPoint({
    required int dummy,
    RenderBox? child,
  })  : _dummy = dummy,
        super(child);

  int get dummy => _dummy;
  int _dummy;

  set dummy(int value) {
    if (_dummy == value) return;
    _dummy = value;
    print('$runtimeType markNeedsLayout because dummy changes');
    markNeedsLayout();
  }

  @override
  void performLayout() {
    Actor.instance.maybePreemptRender();
    super.performLayout();
  }
}
