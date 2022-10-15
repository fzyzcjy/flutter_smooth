import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// TODO merge with other test widgets?
class SpyRenderObjectWidget extends SingleChildRenderObjectWidget {
  final VoidCallback onPerformLayout;

  const SpyRenderObjectWidget({
    super.key,
    required this.onPerformLayout,
    super.child,
  });

  @override
  RenderSpy createRenderObject(BuildContext context) =>
      RenderSpy(onPerformLayout: onPerformLayout);

  @override
  void updateRenderObject(BuildContext context, RenderSpy renderObject) =>
      renderObject.onPerformLayout = onPerformLayout;
}

class RenderSpy extends RenderProxyBox {
  RenderSpy({RenderBox? child, required this.onPerformLayout}) : super(child);

  VoidCallback onPerformLayout;

  @override
  void performLayout() {
    super.performLayout();
    onPerformLayout();
  }
}

class SpyStatefulWidget extends StatefulWidget {
  final VoidCallback? onBuild;
  final VoidCallback? onInitState;
  final VoidCallback? onDidUpdateWidget;
  final VoidCallback? onDispose;
  final Widget? child;

  const SpyStatefulWidget({
    super.key,
    this.onBuild,
    this.onInitState,
    this.onDidUpdateWidget,
    this.onDispose,
    this.child,
  });

  @override
  State<SpyStatefulWidget> createState() => _SpyStatefulWidgetState();
}

class _SpyStatefulWidgetState extends State<SpyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    widget.onInitState?.call();
  }

  @override
  void didUpdateWidget(covariant SpyStatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.onDidUpdateWidget?.call();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild?.call();
    return widget.child ?? Container();
  }
}
