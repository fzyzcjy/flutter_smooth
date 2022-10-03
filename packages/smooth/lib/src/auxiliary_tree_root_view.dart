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

// NOTE ref [RenderView], which is "tree root view" for main tree
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
      // ignore: avoid_print
      print(
          'WARN: AuxiliaryTreeRootView.size is zero, then the subtree may be weird');
    }

    assert(child != null);
    child!.layout(BoxConstraints.tight(_size));
  }

  // ref [RenderView]
  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
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
    final rootLayer = MyTransformLayer(transform: Matrix4.identity());
    rootLayer.attach(this);
    return rootLayer;
  }

  // ref [RenderView] and [RenderProxyBox]
  //
  // [RenderProxyBox] is:
  //
  // (RenderBox)
  // bool hitTest(BoxHitTestResult result, { required Offset position }) {
  //   if (_size!.contains(position)) {
  //     if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
  //       result.add(BoxHitTestEntry(this, position));
  //       return true;
  //     }
  //   }
  //   return false;
  // }
  //
  // (RenderProxyBoxMixin)
  // bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
  //   return child?.hitTest(result, position: position) ?? false;
  // }
  //
  // -----
  //
  // [RenderView] is:
  // bool hitTest(HitTestResult result, { required Offset position }) {
  //   if (child != null) {
  //     child!.hitTest(BoxHitTestResult.wrap(result), position: position);
  //   }
  //   result.add(HitTestEntry(this));
  //   return true;
  // }
  bool hitTest(HitTestResult result, {required Offset position}) {
    // TODO correct? #5871
    final childHit =
        child!.hitTest(BoxHitTestResult.wrap(result), position: position);
    if (childHit) result.add(HitTestEntry(this));
    return childHit;
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

class MyTransformLayer extends TransformLayer {
  MyTransformLayer({super.transform, super.offset});

  @override
  // ignore: unnecessary_overrides
  void attach(covariant Object owner) {
    // print('${describeIdentity(this)}.attach owner=$owner');
    // printWrapped(StackTrace.current.toString());
    super.attach(owner);
  }

  @override
  // ignore: unnecessary_overrides
  void detach() {
    // print('${describeIdentity(this)}.detach (old)owner=$owner');
    // printWrapped(StackTrace.current.toString());
    super.detach();
  }
}
