import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SpyBuilder extends StatefulWidget {
  final VoidCallback? onBuild;
  final VoidCallback? onPerformLayout;
  final Widget? child;

  const SpyBuilder({
    super.key,
    this.onBuild,
    this.onPerformLayout,
    this.child,
  });

  @override
  State<SpyBuilder> createState() => _SpyBuilderState();
}

class _SpyBuilderState extends State<SpyBuilder> {
  @override
  Widget build(BuildContext context) {
    var result = widget.child ?? Container();

    final onBuild = widget.onBuild;
    if (onBuild != null) {
      result = _SpyBuildBuilder(onBuild: onBuild, child: result);
    }

    final onPerformLayout = widget.onPerformLayout;
    if (onPerformLayout != null) {
      result =
          _SpyLayoutBuilder(onPerformLayout: onPerformLayout, child: result);
    }

    return result;
  }
}

class _SpyBuildBuilder extends StatefulWidget {
  final VoidCallback onBuild;
  final Widget? child;

  const _SpyBuildBuilder({required this.onBuild, this.child});

  @override
  State<_SpyBuildBuilder> createState() => _SpyBuildBuilderState();
}

class _SpyBuildBuilderState extends State<_SpyBuildBuilder> {
  @override
  Widget build(BuildContext context) {
    widget.onBuild();
    return widget.child ?? Container();
  }
}

class _SpyLayoutBuilder extends SingleChildRenderObjectWidget {
  final VoidCallback onPerformLayout;

  const _SpyLayoutBuilder({
    required this.onPerformLayout,
    super.child,
  });

  @override
  _RenderSpyLayoutBuilder createRenderObject(BuildContext context) =>
      _RenderSpyLayoutBuilder(
        onPerformLayout: onPerformLayout,
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderSpyLayoutBuilder renderObject) {
    renderObject.onPerformLayout = onPerformLayout;
  }
}

class _RenderSpyLayoutBuilder extends RenderProxyBox {
  _RenderSpyLayoutBuilder({
    required this.onPerformLayout,
    RenderBox? child,
  }) : super(child);

  VoidCallback onPerformLayout;

  @override
  void performLayout() {
    super.performLayout();
    onPerformLayout();
  }
}
