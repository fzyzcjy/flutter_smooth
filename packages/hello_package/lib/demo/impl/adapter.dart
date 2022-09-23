// ignore_for_file: avoid_print, prefer_const_constructors, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'auxiliary_tree.dart';

class AdapterInMainTreeWidget extends SingleChildRenderObjectWidget {
  final AuxiliaryTreePack pack;
  final int dummy;

  const AdapterInMainTreeWidget({
    super.key,
    required this.pack,
    required this.dummy,
    super.child,
  });

  @override
  RenderAdapterInMainTree createRenderObject(BuildContext context) =>
      RenderAdapterInMainTree(
        pack: pack,
        dummy: dummy,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderAdapterInMainTree renderObject) {
    renderObject
      ..pack = pack
      ..dummy = dummy;
  }
}

class RenderAdapterInMainTree extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderAdapterInMainTree({
    required this.pack,
    required int dummy,
  }) : _dummy = dummy;

  AuxiliaryTreePack pack;

  int get dummy => _dummy;
  int _dummy;

  set dummy(int value) {
    if (_dummy == value) return;
    _dummy = value;
    print('$runtimeType markNeedsLayout because dummy changes');
    markNeedsLayout();
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    print('$runtimeType.layout called');
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  void performLayout() {
    print('$runtimeType.performLayout start');

    // NOTE
    pack.rootView.configuration =
        AuxiliaryTreeRootViewConfiguration(size: constraints.biggest);

    print('$runtimeType.performLayout child.layout start');
    child!.layout(constraints);
    print('$runtimeType.performLayout child.layout end');

    size = constraints.biggest;
  }

  // TODO correct?
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(offset == Offset.zero,
        '$runtimeType prototype has not deal with offset yet');

    print('$runtimeType.paint called');

    // ref: RenderOpacity

    // TODO this makes "second tree root layer" be *removed* from its original
    //      parent. shall we move it back later? o/w can be slow!
    final auxiliaryTreeRootLayer = pack.rootView.layer!;

    // print(
    //     'just start auxiliaryTreeRootLayer=${auxiliaryTreeRootLayer.toStringDeep()}');

    // HACK!!!
    if (auxiliaryTreeRootLayer.attached) {
      print('$runtimeType.paint detach the auxiliaryTreeRootLayer');
      // TODO attach again later?
      auxiliaryTreeRootLayer.detach();
    }

    // print(
    //     'before addLayer auxiliaryTreeRootLayer=${auxiliaryTreeRootLayer.toStringDeep()}');

    print('$runtimeType.paint addLayer');
    // NOTE addLayer, not pushLayer!!!
    context.addLayer(auxiliaryTreeRootLayer);
    // context.pushLayer(auxiliaryTreeRootLayer, (context, offset) {}, offset);

    print('auxiliaryTreeRootLayer.attached=${auxiliaryTreeRootLayer.attached}');
    print(
        'after addLayer auxiliaryTreeRootLayer=${auxiliaryTreeRootLayer.toStringDeep()}');

    // ================== paint those child in main tree ===================

    // NOTE do *not* have any relation w/ self's PaintingContext, as we will not paint there
    {
      // ref: [PaintingContext.pushLayer]
      if (pack.mainSubTreeLayerHandle.layer!.hasChildren) {
        pack.mainSubTreeLayerHandle.layer!.removeAllChildren();
      }
      final childContext = PaintingContext(
          pack.mainSubTreeLayerHandle.layer!, context.estimatedBounds);
      child!.paint(childContext, Offset.zero);
      childContext.stopRecordingIfNeeded();
    }

    // =====================================================================
  }
}

class AdapterInAuxiliaryTreeWidget extends SingleChildRenderObjectWidget {
  final AuxiliaryTreePack pack;
  final int dummy;

  const AdapterInAuxiliaryTreeWidget({
    super.key,
    required this.pack,
    required this.dummy,
    super.child,
  });

  @override
  RenderAdapterInAuxiliaryTree createRenderObject(BuildContext context) =>
      RenderAdapterInAuxiliaryTree(
        pack: pack,
        dummy: dummy,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderAdapterInAuxiliaryTree renderObject) {
    renderObject
      ..pack = pack
      ..dummy = dummy;
  }
}

class RenderAdapterInAuxiliaryTree extends RenderBox {
  RenderAdapterInAuxiliaryTree({
    required this.pack,
    required int dummy,
  }) : _dummy = dummy;

  AuxiliaryTreePack pack;

  int get dummy => _dummy;
  int _dummy;

  set dummy(int value) {
    if (_dummy == value) return;
    _dummy = value;
    print('$runtimeType markNeedsLayout because dummy changes');
    markNeedsLayout();
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    print('$runtimeType.layout called');
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  void performLayout() {
    print('$runtimeType.performLayout called');
    size = constraints.biggest;
  }

  // TODO correct?
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(offset == Offset.zero,
        '$runtimeType prototype has not deal with offset yet');
   
    print('$runtimeType paint');
    context.addLayer(pack.mainSubTreeLayerHandle.layer!);
  }
}
