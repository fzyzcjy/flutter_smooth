import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/infra/auxiliary_tree_pack.dart';
import 'package:smooth/src/infra/auxiliary_tree_root_view.dart';
import 'package:smooth/src/infra/service_locator.dart';

class AdapterInMainTreeWidget extends SingleChildRenderObjectWidget {
  final AuxiliaryTreePack pack;

  const AdapterInMainTreeWidget({
    super.key,
    required this.pack,
    super.child,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RenderAdapterInMainTree createRenderObject(BuildContext context) =>
      _RenderAdapterInMainTree(
        pack: pack,
      );

  @override
  void updateRenderObject(
      BuildContext context,
      // ignore: library_private_types_in_public_api
      _RenderAdapterInMainTree renderObject) {
    renderObject.pack = pack;
  }
}

class _RenderAdapterInMainTree extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderAdapterInMainTree({
    required this.pack,
  });

  AuxiliaryTreePack pack;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // https://github.com/fzyzcjy/yplusplus/issues/5917#issuecomment-1265350754
    final childHit = child!.hitTest(result, position: position);
    final auxTreeHit = pack.rootView.hitTest(result, position: position);
    return childHit || auxTreeHit;
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
      ServiceLocator.instance.timeManager.currentSmoothFrameTimeStamp,
      skipIfTimeStampUnchanged: false,
      debugReason: RunPipelineReason.renderAdapterInMainTreePerformLayout,
    );

    // print('$runtimeType.performLayout child.layout start');
    child!.layout(constraints);
    // print('$runtimeType.performLayout child.layout end');

    size = constraints.biggest;
  }

  // TODO correct?
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintAuxiliaryTreeRootLayerToCurrentContext(context, offset);
    _paintSubTreeToPackLayer(context.estimatedBounds);
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
  void _paintSubTreeToPackLayer(Rect estimatedBounds) {
    // ref: [PaintingContext.pushLayer]
    if (pack.mainSubTreeLayerHandle.layer!.hasChildren) {
      pack.mainSubTreeLayerHandle.layer!.removeAllChildren();
    }
    final childContext =
        PaintingContext(pack.mainSubTreeLayerHandle.layer!, estimatedBounds);
    child!.paint(childContext, Offset.zero);
    // ignore: invalid_use_of_protected_member
    childContext.stopRecordingIfNeeded();
  }
}

// void printWrapped(String text) =>
//     RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);
