import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/infra/auxiliary_tree_root_view.dart';
import 'package:smooth/src/infra/remove_sub_tree_widget.dart';
import 'package:smooth/src/infra/service_locator.dart';
import 'package:smooth/src/infra/time/typed_time.dart';

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
  final ValueGetter<List<Ticker>>? wantSmoothTickTickers;

  late final PipelineOwner pipelineOwner;
  late final AuxiliaryTreeRootView rootView;
  late final BuildOwner _buildOwner;
  late final RenderObjectToWidgetElement<RenderBox> _element;

  final mainSubTreeLayerHandle = LayerHandle(OffsetLayer());
  final _tickerRegistry = TickerRegistry();
  final _removeSubTreeController = RemoveSubTreeController();
  AdjustedFrameTimeStamp? _previousRunPipelineTimeStamp;

  AuxiliaryTreePack(
    Widget Function(AuxiliaryTreePack) widget, {
    this.wantSmoothTickTickers,
  }) {
    pipelineOwner = PipelineOwner();
    rootView = pipelineOwner.rootNode = AuxiliaryTreeRootView(
      configuration: const AuxiliaryTreeRootViewConfiguration(size: Size.zero),
    );
    _buildOwner = BuildOwner(
      focusManager: FocusManager(),
      // onBuildScheduled: () =>
      //     print('second tree BuildOwner.onBuildScheduled called'),
    );

    rootView.prepareInitialFrame();

    final wrappedWidget = RemoveSubTreeWidget(
      controller: _removeSubTreeController,
      child: TickerRegistryInheritedWidget(
        registry: _tickerRegistry,
        child: widget(this),
      ),
    );

    _withDebugRunPipelineReason(RunPipelineReason.attachToRenderTree, () {
      _element = RenderObjectToWidgetAdapter<RenderBox>(
        container: rootView,
        debugShortDescription: '[AuxiliaryTreePack#${shortHash(this)}.root]',
        child: wrappedWidget,
      ).attachToRenderTree(_buildOwner);
    });

    ServiceLocator.instance.auxiliaryTreeRegistry._attach(this);
  }

  static RunPipelineReason? get debugRunPipelineReason =>
      _debugRunPipelineReason;
  static RunPipelineReason? _debugRunPipelineReason;

  void runPipeline(
    AdjustedFrameTimeStamp timeStamp, {
    required bool skipIfTimeStampUnchanged,
    required RunPipelineReason debugReason,
  }) {
    // https://github.com/fzyzcjy/flutter_smooth/issues/23#issuecomment-1261687755
    if (skipIfTimeStampUnchanged &&
        _previousRunPipelineTimeStamp == timeStamp) {
      // print(
      //     '$runtimeType runPipeline skip since timeStamp=$timeStamp same as previous');
      return;
    }
    _previousRunPipelineTimeStamp = timeStamp;

    // print(
    //     'hi $runtimeType.runPipeline debugReason=$debugReason layer=${rootView.layer}');

    _withDebugRunPipelineReason(debugReason, () {
      Timeline.timeSync('AuxTree.RunPipeline', () {
        // SimpleLog.instance.log(
        //     'AuxiliaryTreePack.runPipeline timeStamp=$timeStamp debugReason=$debugReason');
        // print(
        //     '$runtimeType runPipeline start timeStamp=$timeStamp debugReason=$debugReason');

        _callExtraTickerTick(timeStamp);

        // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
        // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
        _buildOwner.buildScope(_element);
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        _temporarilyRemoveDebugActiveLayout(() {
          // NOTE #5884
          // ignore: unnecessary_lambdas
          _temporarilyEnsureLayerAttached(() {
            // print(
            //     'hi call pipelineOwner.flushPaint pipelineOwner=${describeIdentity(pipelineOwner)} nodesNeedingPaint=${pipelineOwner.nodesNeedingPaint}');
            pipelineOwner.flushPaint();
          });
        });
        // renderView.compositeFrame(); // this sends the bits to the GPU
        // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
        _buildOwner.finalizeTree();

        // printWrapped(
        //     '$runtimeType.runPipeline after finalizeTree rootView.layer=${rootView.layer!.toStringDeep()}');

        // printWrapped('$runtimeType.runPipeline end');
        // printWrapped('pack.rootView.layer=${rootView.layer?.toStringDeep()}');
        // printWrapped(
        //     'pack.element.renderObject=${element.renderObject.toStringDeep()}');

        // print('$runtimeType runPipeline end');
      });
    });
  }

  static void _withDebugRunPipelineReason(
      RunPipelineReason debugReason, VoidCallback body) {
    assert(() {
      assert(_debugRunPipelineReason == null);
      _debugRunPipelineReason = debugReason;
      return true;
    }());
    try {
      body();
    } finally {
      assert(() {
        assert(_debugRunPipelineReason == debugReason);
        _debugRunPipelineReason = null;
        return true;
      }());
    }
  }

  // NOTE #5884
  void _temporarilyEnsureLayerAttached(void Function() run) {
    final dummyOwner = _DummyOwnerForLayer();

    // ignore: invalid_use_of_protected_member
    final needAction = !rootView.layer!.attached;

    if (needAction) {
      // ignore: invalid_use_of_protected_member
      rootView.layer!.attach(dummyOwner);
    }
    try {
      run();
    } finally {
      if (needAction) {
        // ignore: invalid_use_of_protected_member
        assert(rootView.layer!.owner == dummyOwner);
        rootView.layer!.detach(); // ignore: invalid_use_of_protected_member
      }
    }
  }

  /// #5814
  void _callExtraTickerTick(AdjustedFrameTimeStamp timeStamp) {
    // print('$runtimeType callExtraTickerTick tickers=${tickerRegistry.tickers}');

    for (final ticker in [
      ..._tickerRegistry.tickers,
      ...?wantSmoothTickTickers?.call(),
    ]) {
      ticker.maybeExtraTick(timeStamp.innerAdjustedFrameTimeStamp);
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
        debugReason: RunPipelineReason.auxiliaryTreePackDispose,
      );
    }
  }
}

enum RunPipelineReason {
  attachToRenderTree,
  preemptRenderBuildOrLayoutPhase,
  renderAdapterInMainTreePerformLayout,
  plainAfterFlushLayout,
  preemptRenderPostDrawFramePhase,
  auxiliaryTreePackDispose,
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

class _DummyOwnerForLayer {}
