import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/graft/auxiliary_tree_pack.dart';
import 'package:smooth/src/graft/auxiliary_tree_root_view.dart';
import 'package:smooth/src/graft/dynamic_widget.dart';

class GraftAdapterInMainTreeController<S extends Object> {
  _RenderGraftAdapterInMainTreeInner? _renderBox;

  void _attach(_RenderGraftAdapterInMainTreeInner value) {
    assert(_renderBox == null);
    _renderBox = value;
  }

  void _detach(_RenderGraftAdapterInMainTreeInner value) {
    assert(_renderBox == value);
    _renderBox = null;
  }

  void buildChild(S slot) => _renderBox!._buildChild(slot);

  void layoutChild(S slot) => _renderBox!._layoutChild(slot);
}

class GraftAdapterInMainTree<S extends Object> extends StatelessWidget {
  final GraftAuxiliaryTreePack<S> pack;
  final Widget Function(BuildContext context, S slot) mainTreeChildBuilder;

  const GraftAdapterInMainTree({
    super.key,
    required this.pack,
    required this.mainTreeChildBuilder,
  });

  @override
  Widget build(BuildContext context) {
    print('${describeIdentity(this)}.build call buildScope');
    // see diagram in #5942 for why we build here
    pack.buildOwner.buildScope(pack.element);

    // wrong #5942
    // print('${describeIdentity(this)}.build create children '
    //     '(slots=${pack.childPlaceholderRegistry.slots})');
    // // NOTE the [slots] are updated after we call [buildOwner.buildScope]
    // // just above.
    // final children = pack.childPlaceholderRegistry.slots
    //     .map((slot) => AdapterInMainTreeChildWidget(
    //           slot: slot,
    //           child: widget.childBuilder(context, slot),
    //         ))
    //     .toList();

    // hack: [_AdapterInMainTreeInner] does not respect "offset" in paint
    // now, so we add a RepaintBoundary to let offset==0
    return RepaintBoundary(
      child: _GraftAdapterInMainTreeInner(
        pack: pack,
        mainTreeChildBuilder: mainTreeChildBuilder,
      ),
    );
  }
}

class _GraftAdapterInMainTreeInner<S extends Object> extends DynamicWidget<S> {
  final GraftAuxiliaryTreePack<S> pack;
  final Widget Function(BuildContext context, S slot) mainTreeChildBuilder;

  const _GraftAdapterInMainTreeInner({
    required this.pack,
    required this.mainTreeChildBuilder,
  });

  @override
  Widget? build(DynamicElement<Object> element, S index) =>
      mainTreeChildBuilder(element, index);

  @override
  // ignore: library_private_types_in_public_api
  _RenderGraftAdapterInMainTreeInner<S> createRenderObject(
          BuildContext context) =>
      _RenderGraftAdapterInMainTreeInner(
        childManager: context as DynamicElement<S>,
        pack: pack,
      );

  @override
  void updateRenderObject(
      BuildContext context,
      // ignore: library_private_types_in_public_api
      _RenderGraftAdapterInMainTreeInner<S> renderObject) {
    renderObject.pack = pack;
  }
}

class _AdapterParentData<S extends Object>
    extends ContainerBoxParentData<RenderBox> {
  S get slot => _slot!;
  S? _slot;

  set slot(S value) => _slot = value;
}

class _RenderGraftAdapterInMainTreeInner<S extends Object>
    extends RenderDynamic<S> with _MainTreeChildrenLayoutActor<S> {
  _RenderGraftAdapterInMainTreeInner({
    required this.pack,
    required super.childManager,
  }) : super();

  @override
  GraftAuxiliaryTreePack<S> pack;

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    pack.adapterInMainTreeController._attach(this);
  }

  @override
  void detach() {
    pack.adapterInMainTreeController._detach(this);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AdapterParentData<S>) {
      child.parentData = _AdapterParentData<S>();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // TODO correct? #5871
    if (defaultHitTestChildren(result, position: position)) return true;
    if (pack.rootView.hitTest(result, position: position)) return true;
    return false;
  }

  @override
  void performLayout() {
    // print('$runtimeType.performLayout start');

    // NOTE
    pack.rootView.configuration =
        GraftAuxiliaryTreeRootViewConfiguration(size: constraints.biggest);

    _mainTreeChildrenLayout();

    // old (before #5942)
    // // https://github.com/fzyzcjy/yplusplus/issues/5815#issuecomment-1256952866
    // // NOTE need to be *after* setting pack.rootView.configuration
    // // hack, just for prototype
    // pack.runPipeline(
    //   ServiceLocator.instance.preemptStrategy.currentSmoothFrameTimeStamp,
    //   skipIfTimeStampUnchanged: false,
    //   debugReason: 'RenderAdapterInMainTree.performLayout',
    // );
    //
    // // print('$runtimeType.performLayout child.layout start');
    // RenderBox? child = firstChild;
    // while (child != null) {
    //   final childParentData = child.parentData! as _AdapterParentData;
    //
    //   child.layout(constraints);
    //   pack.mainSubTreeData(childParentData.slot).size = child.size;
    //
    //   child = childParentData.nextSibling;
    // }
    // // print('$runtimeType.performLayout child.layout end');

    size = constraints.biggest;
  }

  // TODO correct?
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintAuxiliaryTreeRootLayerToCurrentContext(context, offset);
    _paintSubTreesToPackLayer(pack, firstChild, context.estimatedBounds);
  }

  // ref: RenderOpacity
  void _paintAuxiliaryTreeRootLayerToCurrentContext(
      PaintingContext context, Offset offset) {
    assert(offset == Offset.zero,
        '$runtimeType prototype has not deal with offset yet');

    // TODO this makes "second tree root layer" be *removed* from its original
    //      parent. shall we move it back later? o/w can be slow!
    final auxiliaryTreeRootLayer = pack.rootView.layer!;

    // print(
    //     'just start auxiliaryTreeRootLayer=${auxiliaryTreeRootLayer.toStringDeep()}');

    // this may or may not be good...
    // HACK!!!
    // related https://github.com/fzyzcjy/yplusplus/issues/5884#issuecomment-1264216323
    if (auxiliaryTreeRootLayer.attached) {
      // print('$runtimeType.paint detach the auxiliaryTreeRootLayer');
      // TODO attach again later?
      auxiliaryTreeRootLayer.detach();
    }

    // printWrapped('$runtimeType.paint before addLayer');
    // printWrapped('pack.rootView.layer=${pack.rootView.layer?.toStringDeep()}');
    // printWrapped(
    //     'pack.element.renderObject=${pack.element.renderObject.toStringDeep()}');

    // print('$runtimeType.paint addLayer');
    // NOTE addLayer, not pushLayer!!!
    context.addLayer(auxiliaryTreeRootLayer);
    // context.pushLayer(auxiliaryTreeRootLayer, (context, offset) {}, offset);

    // print('auxiliaryTreeRootLayer.attached=${auxiliaryTreeRootLayer.attached}');
    // printWrapped(
    //     '$runtimeType._paintAuxiliaryTreeRootLayerToCurrentContext after addLayer '
    //     'context.containerLayer.attached=${context.containerLayer.attached} '
    //     'auxiliaryTreeRootLayer=${auxiliaryTreeRootLayer.toStringDeep()}');
  }

  // NOTE do *not* have any relation w/ self's PaintingContext, as we will not paint there
  static void _paintSubTreesToPackLayer<S extends Object>(
    GraftAuxiliaryTreePack<S> pack,
    RenderBox? firstChild,
    Rect estimatedBounds,
  ) {
    final usedSlots = <Object>[];
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _AdapterParentData<S>;
      final slot = childParentData.slot;

      usedSlots.add(slot);
      _paintSubTreeToPackLayer(
          child, pack.mainSubTreeData(slot).layerHandle, estimatedBounds);

      child = childParentData.nextSibling;
    }

    // TODO should reuse, not throw away #5928
    pack.removeMainSubTreeSlotsWhere((slot) => !usedSlots.contains(slot));
  }

  static void _paintSubTreeToPackLayer(RenderBox child,
      LayerHandle<OffsetLayer> layerHandle, Rect estimatedBounds) {
    print('_paintSubTreeToPackLayer child=$child layerHandle=$layerHandle');

    // ref: [PaintingContext.pushLayer]
    if (layerHandle.layer!.hasChildren) {
      layerHandle.layer!.removeAllChildren();
    }
    final childContext = PaintingContext(layerHandle.layer!, estimatedBounds);
    child.paint(childContext, Offset.zero);
    // ignore: invalid_use_of_protected_member
    childContext.stopRecordingIfNeeded();
  }
}

mixin _MainTreeChildrenLayoutActor<S extends Object> on RenderDynamic<S> {
  GraftAuxiliaryTreePack<S> get pack;

  /// Whether we are doing layout for main tree children
  var _debugMainTreeChildrenLayoutActive = false;
  final _hasLayoutChildrenSlots = <S>{};
  RenderBox? _lastBuildChild;

  void _mainTreeChildrenLayout() {
    // #5942
    assert(() {
      _debugMainTreeChildrenLayoutActive = true;
      return true;
    }());
    try {
      _hasLayoutChildrenSlots.clear();
      _lastBuildChild = null;

      pack.pipelineOwner.flushLayout();

      _collectGarbage(_hasLayoutChildrenSlots);
    } finally {
      assert(() {
        _debugMainTreeChildrenLayoutActive = false;
        return true;
      }());
    }
  }

  // see diagram in #5942, also ref [LayoutBuilder] and [RenderSliver]
  void _buildChild(S slot) {
    assert(_debugMainTreeChildrenLayoutActive);

    createOrUpdateChild(index: slot, after: _lastBuildChild);

    _lastBuildChild = childFromIndex(slot);
  }

  // see diagram in #5942, also ref [LayoutBuilder] and [RenderSliver]
  void _layoutChild(S slot) {
    assert(_debugMainTreeChildrenLayoutActive);

    final child = childFromIndex(slot)!;
    child.layout(constraints);

    assert(!_hasLayoutChildrenSlots.contains(slot));
    _hasLayoutChildrenSlots.add(slot);
  }

  void _collectGarbage(Set<S> whitelistSlots) {
    assert(_debugMainTreeChildrenLayoutActive);

    final slotsToRemove = <S>[];

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as DynamicParentData<S>;
      final slot = childParentData.index;

      if (!whitelistSlots.contains(slot)) slotsToRemove.add(slot!);

      child = childParentData.nextSibling;
    }

    collectGarbage(slotsToRemove);
  }
}

// void printWrapped(String text) =>
//     RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);
