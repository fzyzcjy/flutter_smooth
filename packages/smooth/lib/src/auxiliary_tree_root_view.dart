import 'package:flutter/rendering.dart';

// ref: [ViewConfiguration]
class AuxiliaryTreeRootViewConfiguration {
  const AuxiliaryTreeRootViewConfiguration({
    required this.size,
  });

  final Size size;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ViewConfiguration && other.size == size;
  }

  @override
  int get hashCode => size.hashCode;

  @override
  String toString() => '$size';
}

class AuxiliaryTreeRootView extends RenderObject
    with RenderObjectWithChildMixin<RenderBox> {
  AuxiliaryTreeRootView({
    RenderBox? child,
    required AuxiliaryTreeRootViewConfiguration configuration,
  }) : _configuration = configuration {
    this.child = child;
  }

  // NOTE ref [RenderView.size]
  /// The current layout size of the view.
  Size get size => _size;
  Size _size = Size.zero;

  // NOTE ref [RenderView.configuration] which has size and some other things
  /// The constraints used for the root layout.
  AuxiliaryTreeRootViewConfiguration get configuration => _configuration;
  AuxiliaryTreeRootViewConfiguration _configuration;

  set configuration(AuxiliaryTreeRootViewConfiguration value) {
    if (configuration == value) {
      return;
    }
    // print(
    //     '$runtimeType set configuration(i.e. size) $_configuration -> $value');
    _configuration = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    // print(
    //     '$runtimeType performLayout configuration.size=${configuration.size}');

    _size = configuration.size;

    // https://github.com/fzyzcjy/yplusplus/issues/5815#issuecomment-1256952047
    if (_size == Size.zero) {
      print('WARN: $runtimeType.size is zero, then the subtree may be weird');
    }

    assert(child != null);
    child!.layout(BoxConstraints.tight(_size));
  }

  // ref [RenderView]
  @override
  void paint(PaintingContext context, Offset offset) {
    // NOTE we have to temporarily remove debugActiveLayout
    // b/c [AuxiliaryTreeRootView.paint] is called inside [preemptRender]
    // which is inside main tree's build/layout.
    // thus, if not set it to null we will see error
    // https://github.com/fzyzcjy/yplusplus/issues/5783#issuecomment-1254974511
    // In short, this is b/c [debugActiveLayout] is global variable instead
    // of per-tree variable
    final oldDebugActiveLayout = RenderObject.debugActiveLayout;
    RenderObject.debugActiveLayout = null;
    try {
      // print('$runtimeType paint child start');
      context.paintChild(child!, offset);
      // print('$runtimeType paint child end');
    } finally {
      RenderObject.debugActiveLayout = oldDebugActiveLayout;
    }
  }

  @override
  void debugAssertDoesMeetConstraints() => true;

  void prepareInitialFrame() {
    // ref: [RenderView]
    scheduleInitialLayout();
    scheduleInitialPaint(_updateMatricesAndCreateNewRootLayer());
  }

  // ref: [RenderView]
  TransformLayer _updateMatricesAndCreateNewRootLayer() {
    final rootLayer = TransformLayer(transform: Matrix4.identity());
    rootLayer.attach(this);
    return rootLayer;
  }

  // ref: [RenderView]
  @override
  bool get isRepaintBoundary => true;

  // ref: [RenderView]
  @override
  Rect get paintBounds => Offset.zero & size;

  // ref: [RenderView]
  @override
  void performResize() {
    assert(false);
  }

  // ref: [RenderView]
  @override
  Rect get semanticBounds => paintBounds;
}
