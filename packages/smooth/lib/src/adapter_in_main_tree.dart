import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';
import 'package:smooth/src/auxiliary_tree_root_view.dart';
import 'package:smooth/src/service_locator.dart';

class AdapterInMainTree extends StatelessWidget {
  final AuxiliaryTreePack pack;

  const AdapterInMainTree({super.key, required this.pack});

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
      child: _AdapterInMainTreeInner(
        pack: pack,
      ),
    );
  }
}

class _AdapterInMainTreeInner extends MultiChildRenderObjectWidget {
  final AuxiliaryTreePack pack;

  _AdapterInMainTreeInner({
    super.key,
    required this.pack,
    super.children,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RenderAdapterInMainTreeInner createRenderObject(BuildContext context) =>
      _RenderAdapterInMainTreeInner(
        pack: pack,
      );

  @override
  void updateRenderObject(
      BuildContext context,
      // ignore: library_private_types_in_public_api
      _RenderAdapterInMainTreeInner renderObject) {
    renderObject.pack = pack;
  }
}

class _AdapterParentData extends ContainerBoxParentData<RenderBox> {
  Object get slot => _slot!;
  Object? _slot;

  set slot(Object value) => _slot = value;
}

class _RenderAdapterInMainTreeInner extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _AdapterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _AdapterParentData> {
  _RenderAdapterInMainTreeInner({
    required this.pack,
  });

  AuxiliaryTreePack pack;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AdapterParentData) {
      child.parentData = _AdapterParentData();
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
        AuxiliaryTreeRootViewConfiguration(size: constraints.biggest);

    // https://github.com/fzyzcjy/yplusplus/issues/5815#issuecomment-1256952866
    // NOTE need to be *after* setting pack.rootView.configuration
    // hack, just for prototype
    pack.runPipeline(
      ServiceLocator.instance.preemptStrategy.currentSmoothFrameTimeStamp,
      skipIfTimeStampUnchanged: false,
      debugReason: 'RenderAdapterInMainTree.performLayout',
    );

    // print('$runtimeType.performLayout child.layout start');
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _AdapterParentData;

      child.layout(constraints);
      pack.mainSubTreeData(childParentData.slot).size = child.size;

      child = childParentData.nextSibling;
    }
    // print('$runtimeType.performLayout child.layout end');

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
  static void _paintSubTreesToPackLayer(
      AuxiliaryTreePack pack, RenderBox? firstChild, Rect estimatedBounds) {
    final usedSlots = <Object>[];
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _AdapterParentData;
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

// void printWrapped(String text) =>
//     RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);
//
// class AdapterInMainTreeChildWidget
//     extends ParentDataWidget<_AdapterParentData> {
//   final Object slot;
//
//   const AdapterInMainTreeChildWidget({
//     super.key,
//     required this.slot,
//     required super.child,
//   });
//
//   @override
//   void applyParentData(RenderObject renderObject) {
//     final parentData = renderObject.parentData! as _AdapterParentData;
//     parentData.slot = slot;
//   }
//
//   @override
//   Type get debugTypicalAncestorWidgetClass => _AdapterInMainTreeInner;
// }
