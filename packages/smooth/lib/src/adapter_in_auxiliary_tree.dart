import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';

class AdapterInAuxiliaryTree extends StatelessWidget {
  final AuxiliaryTreePack pack;
  final Object slot;

  const AdapterInAuxiliaryTree({
    super.key,
    required this.pack,
    required this.slot,
    // super.child,
  });

  @override
  Widget build(BuildContext context) {
    // hack, since [_AdapterInAuxiliaryTreeInner] not deal with offset yet
    return RepaintBoundary(
      child: _AdapterInAuxiliaryTreeInner(
        pack: pack,
        slot: slot,
      ),
    );
  }
}

class _AdapterInAuxiliaryTreeInner extends SingleChildRenderObjectWidget {
  final AuxiliaryTreePack pack;
  final Object slot;

  const _AdapterInAuxiliaryTreeInner({
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
    // print('$runtimeType.performLayout called '
    //     'slot=$slot '
    //     'pack.mainSubTreeSizeOfSlot[slot]=${pack.mainSubTreeSizeOfSlot[slot]} '
    //     'constraints=$constraints');

    // old
    // size = constraints.biggest;

    // https://github.com/fzyzcjy/yplusplus/issues/5924#issuecomment-1264585802
    final realSize = pack.mainSubTreeData(slot).size;
    size = realSize ?? _fallbackSize(constraints);
  }

  static Size _fallbackSize(BoxConstraints constraints) {
    final raw = constraints.biggest;
    // NOTE make it finite size, since a size cannot be infinite
    // https://github.com/fzyzcjy/yplusplus/issues/5930#issuecomment-1264641509
    return Size(
      min(raw.width, double.maxFinite),
      min(raw.height, double.maxFinite),
    );
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

    context.addLayer(pack.mainSubTreeData(slot).layerHandle.layer!);
    // context.addLayer(_simpleLayer.layer!);
  }
}
