import 'package:flutter/material.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';

class AdapterInAuxiliaryTreeWidget extends SingleChildRenderObjectWidget {
  final AuxiliaryTreePack pack;

  const AdapterInAuxiliaryTreeWidget({
    super.key,
    required this.pack,
    super.child,
  });

  @override
  RenderAdapterInAuxiliaryTree createRenderObject(BuildContext context) =>
      RenderAdapterInAuxiliaryTree(
        pack: pack,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderAdapterInAuxiliaryTree renderObject) {
    renderObject.pack = pack;
  }
}

class RenderAdapterInAuxiliaryTree extends RenderBox {
  RenderAdapterInAuxiliaryTree({
    required this.pack,
  });

  AuxiliaryTreePack pack;

  @override
  void performLayout() {
    // print('$runtimeType.performLayout called');
    size = constraints.biggest;
  }

  // TODO correct?
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(offset == Offset.zero,
        '$runtimeType prototype has not deal with offset yet');

    // printWrapped('$runtimeType.paint before addLayer');
    // printWrapped(
    //     'pack.mainSubTreeLayerHandle.layer=${pack.mainSubTreeLayerHandle.layer?.toStringDeep()}');

    // print('$runtimeType paint');

    context.addLayer(pack.mainSubTreeLayerHandle.layer!);
    // context.addLayer(_simpleLayer.layer!);
  }
}
