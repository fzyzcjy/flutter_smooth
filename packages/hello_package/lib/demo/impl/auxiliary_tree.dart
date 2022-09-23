// ignore_for_file: avoid_print, prefer_const_constructors, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'adapter.dart';

class AuxiliaryTreePack {
  late final PipelineOwner pipelineOwner;
  late final AuxiliaryTreeRootView rootView;
  late final BuildOwner buildOwner;
  late final RenderObjectToWidgetElement<RenderBox> element;

  // since prototype, only one [RenderAdapterInSecondTree], so do like this
  final mainSubTreeLayerHandle = LayerHandle(OffsetLayer());

  late StateSetter innerStatefulBuilderSetState;

  // hack, use singleton just for prototype
  static AuxiliaryTreePack? instance;

  AuxiliaryTreePack(Widget Function(AuxiliaryTreePack) widget) {
    pipelineOwner = PipelineOwner();
    rootView = pipelineOwner.rootNode = AuxiliaryTreeRootView(
      configuration: AuxiliaryTreeRootViewConfiguration(size: Size.zero),
    );
    buildOwner = BuildOwner(
      focusManager: FocusManager(),
      // onBuildScheduled: () =>
      //     print('second tree BuildOwner.onBuildScheduled called'),
    );

    rootView.prepareInitialFrame();

    final wrappedWidget = StatefulBuilder(builder: (_, setState) {
      innerStatefulBuilderSetState = setState;
      return widget(this);
    });

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: wrappedWidget,
    ).attachToRenderTree(buildOwner);

    assert(instance == null);
    instance = this;
  }

  void runPipeline() {
    // print('$runtimeType runPipeline start');

    innerStatefulBuilderSetState(() {});

    // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
    // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
    buildOwner.buildScope(element);
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    temporarilyRemoveDebugActiveLayout(() {
      pipelineOwner.flushPaint();
    });
    // renderView.compositeFrame(); // this sends the bits to the GPU
    // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
    buildOwner.finalizeTree();

    // print('$runtimeType runPipeline end');
  }

  void temporarilyRemoveDebugActiveLayout(VoidCallback f) {
    // NOTE we have to temporarily remove debugActiveLayout
    // b/c [SecondTreeRootView.paint] is called inside [preemptRender]
    // which is inside main tree's build/layout.
    // thus, if not set it to null we will see error
    // https://github.com/fzyzcjy/yplusplus/issues/5783#issuecomment-1254974511
    // In short, this is b/c [debugActiveLayout] is global variable instead
    // of per-tree variable
    // and also
    // https://github.com/fzyzcjy/yplusplus/issues/5793#issuecomment-1256095858
    final oldDebugActiveLayout = RenderObject.debugActiveLayout;
    RenderObject.debugActiveLayout = null;
    try {
      f();
    } finally {
      RenderObject.debugActiveLayout = oldDebugActiveLayout;
    }
  }

  void dispose() {
    assert(instance == this);
    instance = null;
  }
}

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

    assert(child != null);
    child!.layout(BoxConstraints.tight(_size));
  }

  // ref RenderView
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
    // ref: RenderView
    scheduleInitialLayout();
    scheduleInitialPaint(_updateMatricesAndCreateNewRootLayer());
  }

  // ref: RenderView
  TransformLayer _updateMatricesAndCreateNewRootLayer() {
    final rootLayer = TransformLayer(transform: Matrix4.identity());
    rootLayer.attach(this);
    return rootLayer;
  }

  // ref: RenderView
  @override
  bool get isRepaintBoundary => true;

  // ref: RenderView
  @override
  Rect get paintBounds => Offset.zero & size;

  // ref: RenderView
  @override
  void performResize() {
    assert(false);
  }

  // hack: just give non-sense value, this is prototype
  @override
  Rect get semanticBounds => paintBounds;
}
