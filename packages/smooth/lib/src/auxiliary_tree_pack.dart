import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/auxiliary_tree_root_view.dart';
import 'package:smooth/src/remove_sub_tree_widget.dart';
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
  final _removeSubTreeController = RemoveSubTreeController();
  Duration? _previousRunPipelineTimeStamp;

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

    final wrappedWidget = RemoveSubTreeWidget(
      controller: _removeSubTreeController,
      child: TickerRegistryInheritedWidget(
        registry: tickerRegistry,
        child: widget(this),
      ),
    );

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[AuxiliaryTreePack#${shortHash(this)}.root]',
      child: wrappedWidget,
    ).attachToRenderTree(buildOwner);

    ServiceLocator.instance.auxiliaryTreeRegistry._attach(this);
  }

  void runPipeline(
    Duration timeStamp, {
    required bool skipIfTimeStampUnchanged,
    required String debugReason,
  }) {
    // https://github.com/fzyzcjy/flutter_smooth/issues/23#issuecomment-1261687755
    if (skipIfTimeStampUnchanged &&
        _previousRunPipelineTimeStamp == timeStamp) {
      print(
          '$runtimeType runPipeline skip since timeStamp=$timeStamp same as previous');
      return;
    }
    _previousRunPipelineTimeStamp = timeStamp;

    Timeline.timeSync('AuxTree.RunPipeline', () {
      print(
          '$runtimeType runPipeline start timeStamp=$timeStamp debugReason=$debugReason');

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

    // #54
    final previousRunPipelineTimeStamp = _previousRunPipelineTimeStamp;
    if (previousRunPipelineTimeStamp != null) {
      _removeSubTreeController.markRemoveSubTree();

      runPipeline(
        previousRunPipelineTimeStamp,
        skipIfTimeStampUnchanged: false,
        debugReason: 'AuxiliaryTreePack.dispose',
      );
    }
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
