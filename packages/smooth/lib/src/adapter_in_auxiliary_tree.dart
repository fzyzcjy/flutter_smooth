import 'package:flutter/material.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';

class AdapterInAuxiliaryTreeWidget extends SingleChildRenderObjectWidget {
  final AuxiliaryTreePack pack;
  final Object slot;

  const AdapterInAuxiliaryTreeWidget({
    super.key,
    required this.pack,
    required this.slot,
    super.child,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RenderAdapterInAuxiliaryTree createRenderObject(BuildContext context) =>
      _RenderAdapterInAuxiliaryTree(
        pack: pack,
        slot: slot,
      );

  @override
  void updateRenderObject(
      BuildContext context,
      // ignore: library_private_types_in_public_api
      _RenderAdapterInAuxiliaryTree renderObject) {
    renderObject
      ..pack = pack
      ..slot = slot;
  }
}

class _RenderAdapterInAuxiliaryTree extends RenderBox {
  _RenderAdapterInAuxiliaryTree({
    required this.pack,
    required this.slot,
  });

  AuxiliaryTreePack pack;
  Object slot;

  @override
  void performLayout() {
    // print('$runtimeType.performLayout called');

    // old
    // size = constraints.biggest;

    // https://github.com/fzyzcjy/yplusplus/issues/5924#issuecomment-1264585802
    size = pack.mainSubTreeSizeOfSlot[slot] ?? constraints.biggest;
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

    context.addLayer(pack.mainSubTreeLayerHandleOfSlot[slot]!.layer!);
    // context.addLayer(_simpleLayer.layer!);
  }
}
