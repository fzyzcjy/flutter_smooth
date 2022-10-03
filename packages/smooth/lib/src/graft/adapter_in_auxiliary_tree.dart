import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth/src/graft/auxiliary_tree_pack.dart';

class GraftAdapterInAuxiliaryTree<S extends Object> extends StatelessWidget {
  final S slot;

  const GraftAdapterInAuxiliaryTree({
    super.key,
    required this.slot,
    // super.child,
  });

  @override
  Widget build(BuildContext context) {
    final pack = AuxiliaryTreePackProvider.of(context).pack;

    // #5942
    pack.adapterInMainTreeController.buildChild(slot);

    // hack, since [_AdapterInAuxiliaryTreeInner] not deal with offset yet
    return RepaintBoundary(
      child: _GraftAdapterInAuxiliaryTreeInner(
        pack: pack,
        slot: slot,
      ),
    );
  }
}

class _GraftAdapterInAuxiliaryTreeInner<S extends Object>
    extends SingleChildRenderObjectWidget {
  final GraftAuxiliaryTreePack pack;
  final S slot;

  const _GraftAdapterInAuxiliaryTreeInner({
    required this.pack,
    required this.slot,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RenderGraftAdapterInAuxiliaryTree<S> createRenderObject(
          BuildContext context) =>
      _RenderGraftAdapterInAuxiliaryTree(
        pack: pack,
        slot: slot,
      );

  @override
  void updateRenderObject(
      BuildContext context,
      // ignore: library_private_types_in_public_api
      _RenderGraftAdapterInAuxiliaryTree<S> renderObject) {
    renderObject
      ..pack = pack
      ..slot = slot;
  }
}

class _RenderGraftAdapterInAuxiliaryTree<S extends Object> extends RenderBox {
  _RenderGraftAdapterInAuxiliaryTree({
    required this.pack,
    required this.slot,
  });

  GraftAuxiliaryTreePack pack;
  S slot;

  @override
  void performLayout() {
    // print('$runtimeType.performLayout called '
    //     'slot=$slot '
    //     'pack.mainSubTreeSizeOfSlot[slot]=${pack.mainSubTreeSizeOfSlot[slot]} '
    //     'constraints=$constraints');

    // old
    // size = constraints.biggest;

    // still old
    // // https://github.com/fzyzcjy/yplusplus/issues/5924#issuecomment-1264585802
    // final realSize = pack.mainSubTreeData(slot).size;
    // size = realSize ?? _fallbackSize(constraints);

    // #5942
    pack.adapterInMainTreeController.layoutChild(slot);
    size = pack.mainSubTreeData(slot).size ?? _fallbackSize(constraints);
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
