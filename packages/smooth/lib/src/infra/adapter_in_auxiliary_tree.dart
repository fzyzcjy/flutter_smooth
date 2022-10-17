import 'package:flutter/material.dart';
import 'package:smooth/src/infra/auxiliary_tree_pack.dart';

class AdapterInAuxiliaryTreeWidget extends SingleChildRenderObjectWidget {
  final AuxiliaryTreePack pack;

  const AdapterInAuxiliaryTreeWidget({
    super.key,
    required this.pack,
    super.child,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RenderAdapterInAuxiliaryTree createRenderObject(BuildContext context) =>
      _RenderAdapterInAuxiliaryTree(
        pack: pack,
      );

  @override
  void updateRenderObject(
      BuildContext context,
      // ignore: library_private_types_in_public_api
      _RenderAdapterInAuxiliaryTree renderObject) {
    renderObject.pack = pack;
  }
}

class _RenderAdapterInAuxiliaryTree extends RenderBox {
  _RenderAdapterInAuxiliaryTree({
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

    // print('$runtimeType paint');

    context.addLayer(pack.mainSubTreeLayerHandle.layer!);
  }
}
