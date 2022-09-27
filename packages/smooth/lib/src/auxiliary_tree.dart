import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/service_locator.dart';

class AuxiliaryTreeRegistry {
  Iterable<AuxiliaryTreePack> get trees => _trees;
  final _trees = Set<AuxiliaryTreePack>.identity();

  void _attach(AuxiliaryTreePack value) {
    assert(!_trees.contains(value));
    _trees.add(value);
  }

  void _detach(AuxiliaryTreePack value) {
    assert(_trees.contains(value));
    _trees.remove(value);
  }
}

class AuxiliaryTreePack {
  late final PipelineOwner pipelineOwner;
  late final AuxiliaryTreeRootView rootView;
  late final BuildOwner buildOwner;
  late final RenderObjectToWidgetElement<RenderBox> element;

  final mainSubTreeLayerHandle = LayerHandle(OffsetLayer());
  final tickerRegistry = TickerRegistry();

  AuxiliaryTreePack(Widget Function(AuxiliaryTreePack) widget) {
    pipelineOwner = PipelineOwner();
    rootView = pipelineOwner.rootNode = AuxiliaryTreeRootView(
      configuration: const AuxiliaryTreeRootViewConfiguration(size: Size.zero),
    );
    buildOwner = BuildOwner(
      focusManager: FocusManager(),
      // onBuildScheduled: () =>
      //     print('second tree BuildOwner.onBuildScheduled called'),
    );

    rootView.prepareInitialFrame();

    final wrappedWidget = TickerRegistryInheritedWidget(
      registry: tickerRegistry,
      child: widget(this),
    );

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[AuxiliaryTreePack#${shortHash(this)}.root]',
      child: wrappedWidget,
    ).attachToRenderTree(buildOwner);

    ServiceLocator.instance.auxiliaryTreeRegistry._attach(this);
  }

  void runPipeline(Duration timeStamp, {required String debugReason}) {
    Timeline.timeSync('AuxTree.RunPipeline', () {
      // print('$runtimeType runPipeline start debugReason=$debugReason');

      _callExtraTickerTick(timeStamp);

      // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
      // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
      buildOwner.buildScope(element);
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      // ignore: unnecessary_lambdas
      _temporarilyRemoveDebugActiveLayout(() {
        pipelineOwner.flushPaint();
      });
      // renderView.compositeFrame(); // this sends the bits to the GPU
      // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
      buildOwner.finalizeTree();

      // printWrapped('$runtimeType.runPipeline end');
      // printWrapped('pack.rootView.layer=${rootView.layer?.toStringDeep()}');
      // printWrapped(
      //     'pack.element.renderObject=${element.renderObject.toStringDeep()}');

      // print('$runtimeType runPipeline end');
    });
  }

  /// #5814
  void _callExtraTickerTick(Duration timeStamp) {
    // #5821
    // final now = DateTime.now();
    // final timeStamp = SchedulerBinding.instance.currentFrameTimeStamp +
    //     Duration(
    //         microseconds: now.microsecondsSinceEpoch -
    //             SchedulerBinding.instance.currentFrameStartTimeUs!);

    // print('$runtimeType callExtraTickerTick tickers=${tickerRegistry.tickers}');

    for (final ticker in tickerRegistry.tickers) {
      ticker.maybeExtraTick(timeStamp);
    }
  }

  void dispose() {
    ServiceLocator.instance.auxiliaryTreeRegistry._detach(this);
  }
}

void _temporarilyRemoveDebugActiveLayout(VoidCallback f) {
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
