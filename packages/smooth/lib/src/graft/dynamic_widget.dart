import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that has dynamic number of children
// ref [SliverList], i.e. [SliverMultiBoxAdaptorWidget]
abstract class DynamicWidget extends RenderObjectWidget {
  const DynamicWidget({super.key});

  @override
  DynamicElement createElement() => DynamicElement(this);

  @override
  RenderDynamic createRenderObject(BuildContext context);

  Widget? build(DynamicElement element, int index);
}

// ref [RenderSliverBoxChildManager]
abstract class RenderDynamicChildManager {
  void createChild(int index, {required RenderBox? after});

  void removeChild(RenderBox child);
}

// ref [SliverMultiBoxAdaptorElement] - the whole class is copied and (largely)
// modified from it
class DynamicElement extends RenderObjectElement
    implements RenderDynamicChildManager {
  DynamicElement(DynamicWidget super.widget);

  @override
  RenderDynamic get renderObject => super.renderObject as RenderDynamic;

  // no need to mimic this, since its logic is for a changeable delegate object
  // void update(covariant SliverMultiBoxAdaptorWidget newWidget) {}

  // ref [SliverMultiBoxAdaptorElement]
  final _childElements = SplayTreeMap<int, Element?>();
  RenderBox? _currentBeforeChild;

  // ref [SliverMultiBoxAdaptorElement]
  @override
  void performRebuild() {
    super.performRebuild();
    _currentBeforeChild = null;
    bool childrenUpdated = false;
    assert(_currentlyUpdatingChildIndex == null);
    try {
      final newChildren = SplayTreeMap<int, Element?>();
      final widgetTyped = widget as DynamicWidget;
      void processElement(int index) {
        _currentlyUpdatingChildIndex = index;
        if (_childElements[index] != null &&
            _childElements[index] != newChildren[index]) {
          // This index has an old child that isn't used anywhere and should be deactivated.
          _childElements[index] =
              updateChild(_childElements[index], null, index);
          childrenUpdated = true;
        }
        final newChild =
            updateChild(newChildren[index], _build(index, widgetTyped), index);
        if (newChild != null) {
          childrenUpdated =
              childrenUpdated || _childElements[index] != newChild;
          _childElements[index] = newChild;
          final parentData =
              newChild.renderObject!.parentData! as DynamicParentData;
          // if (index == 0) {
          //   parentData.layoutOffset = 0.0;
          // } else if (indexToLayoutOffset.containsKey(index)) {
          //   parentData.layoutOffset = indexToLayoutOffset[index];
          // }
          // if (!parentData.keptAlive) {
          _currentBeforeChild = newChild.renderObject as RenderBox?;
          // }
        } else {
          childrenUpdated = true;
          _childElements.remove(index);
        }
      }

      for (final index in _childElements.keys.toList()) {
        final key = _childElements[index]!.widget.key;
        final newIndex =
            key == null ? null : widgetTyped.delegate.findIndexByKey(key);
        final childParentData = _childElements[index]!.renderObject?.parentData
            as DynamicParentData?;

        // if (childParentData != null && childParentData.layoutOffset != null) {
        //   indexToLayoutOffset[index] = childParentData.layoutOffset!;
        // }

        if (newIndex != null && newIndex != index) {
          // // The layout offset of the child being moved is no longer accurate.
          // if (childParentData != null) {
          //   childParentData.layoutOffset = null;
          // }

          newChildren[newIndex] = _childElements[index];
          if (_replaceMovedChildren) {
            // We need to make sure the original index gets processed.
            newChildren.putIfAbsent(index, () => null);
          }
          // We do not want the remapped child to get deactivated during processElement.
          _childElements.remove(index);
        } else {
          newChildren.putIfAbsent(index, () => _childElements[index]);
        }
      }

      renderObject.debugChildIntegrityEnabled =
          false; // Moving children will temporary violate the integrity.
      newChildren.keys.forEach(processElement);
    } finally {
      _currentlyUpdatingChildIndex = null;
      renderObject.debugChildIntegrityEnabled = true;
    }
  }

  // ref [SliverMultiBoxAdaptorElement]
  Widget? _build(int index, DynamicWidget widget) {
    // originally: `return widget.delegate.build(this, index);`
    // but we do not have any changeable `delegate` variable to simplify impl
    return widget.build(this, index);
  }

  // ref [SliverMultiBoxAdaptorElement]
  @override
  void createChild(int index, {required RenderBox? after}) {
    assert(_currentlyUpdatingChildIndex == null);
    owner!.buildScope(this, () {
      final insertFirst = after == null;
      assert(insertFirst || _childElements[index - 1] != null);
      _currentBeforeChild = insertFirst
          ? null
          : (_childElements[index - 1]!.renderObject as RenderBox?);
      Element? newChild;
      try {
        final adaptorWidget = widget as DynamicWidget;
        _currentlyUpdatingChildIndex = index;
        newChild = updateChild(
            _childElements[index], _build(index, adaptorWidget), index);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElements[index] = newChild;
      } else {
        _childElements.remove(index);
      }
    });
  }

  // no need to mimic this, since its logic is for `parentData.layoutOffset`
  // Element? updateChild(Element? child, Widget? newWidget, Object? newSlot)

  // ref [SliverMultiBoxAdaptorElement]
  @override
  void forgetChild(Element child) {
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
    super.forgetChild(child);
  }

  // ref [SliverMultiBoxAdaptorElement]
  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner!.buildScope(this, () {
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final Element? result = updateChild(_childElements[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  @override
  void didStartLayout() {
    assert(debugAssertChildListLocked());
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
  }

  int? _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final childParentData = child.parentData! as DynamicParentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, int slot) {
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child as RenderBox, after: _currentBeforeChild);
    assert(() {
      final childParentData = child.parentData! as DynamicParentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child, int oldSlot, int newSlot) {
    assert(_currentlyUpdatingChildIndex == newSlot);
    renderObject.move(child as RenderBox, after: _currentBeforeChild);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, int slot) {
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(child as RenderBox);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    assert(!_childElements.values.any((Element? child) => child == null));
    _childElements.values.cast<Element>().toList().forEach(visitor);
  }

// no need to mimic this, since in SliverList there exist out-of-screen
// things which are offstage, but we do not have that
// void debugVisitOnstageChildren(ElementVisitor visitor)
}

// ref [SliverMultiBoxAdaptorParentData]
class DynamicParentData extends ParentData
    with ContainerParentDataMixin<RenderBox> {
  /// The index of this child according to the [RenderDynamicChildManager].
  int? index;

  @override
  String toString() => 'index=$index; ${super.toString()}';
}

// ref [RenderSliverMultiBoxAdaptor]
abstract class RenderDynamic extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, DynamicParentData> {
  RenderDynamic({required this.childManager});

  /// The delegate that manages the children of this object.
  ///
  /// Rather than having a concrete list of children, a
  /// [RenderDynamic] uses a [RenderDynamicChildManager] to
  /// create children during layout.
  // ref [RenderSliverMultiBoxAdaptor]
  final RenderDynamicChildManager childManager;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! DynamicParentData) {
      child.parentData = DynamicParentData();
    }
  }

  /// Indicates whether integrity check is enabled.
  ///
  /// Setting this property to true will immediately perform an integrity check.
  ///
  /// The integrity check consists of:
  ///
  /// 1. Verify that the children index in childList is in ascending order.
  /// 2. Verify that there is no dangling keepalive child as the result of [move].
  bool get debugChildIntegrityEnabled => _debugChildIntegrityEnabled;
  bool _debugChildIntegrityEnabled = true;

  set debugChildIntegrityEnabled(bool enabled) {
    assert(enabled != null);
    assert(() {
      _debugChildIntegrityEnabled = enabled;
      return _debugVerifyChildOrder() &&
          (!_debugChildIntegrityEnabled || _debugDanglingKeepAlives.isEmpty);
    }());
  }

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    final DynamicParentData childParentData =
        child.parentData! as DynamicParentData;
    if (!childParentData._keptAlive) {
      childManager.didAdoptChild(child as RenderBox);
    }
  }

  bool _debugAssertChildListLocked() =>
      childManager.debugAssertChildListLocked();

  /// Verify that the child list index is in strictly increasing order.
  ///
  /// This has no effect in release builds.
  bool _debugVerifyChildOrder() {
    if (_debugChildIntegrityEnabled) {
      RenderBox? child = firstChild;
      int index;
      while (child != null) {
        index = indexOf(child);
        child = childAfter(child);
        assert(child == null || indexOf(child) > index);
      }
    }
    return true;
  }

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    assert(firstChild != null);
    assert(_debugVerifyChildOrder());
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    // There are two scenarios:
    //
    // 1. The child is not keptAlive.
    // The child is in the childList maintained by ContainerRenderObjectMixin.
    // We can call super.move and update parentData with the new slot.
    //
    // 2. The child is keptAlive.
    // In this case, the child is no longer in the childList but might be stored in
    // [_keepAliveBucket]. We need to update the location of the child in the bucket.
    final DynamicParentData childParentData =
        child.parentData! as DynamicParentData;
    if (!childParentData.keptAlive) {
      super.move(child, after: after);
      childManager.didAdoptChild(child); // updates the slot in the parentData
      // Its slot may change even if super.move does not change the position.
      // In this case, we still want to mark as needs layout.
      markNeedsLayout();
    } else {
      // If the child in the bucket is not current child, that means someone has
      // already moved and replaced current child, and we cannot remove this child.
      // if (_keepAliveBucket[childParentData.index] == child) {
      //   _keepAliveBucket.remove(childParentData.index);
      // }
      // assert(() {
      //   _debugDanglingKeepAlives.remove(child);
      //   return true;
      // }());
      // Update the slot and reinsert back to _keepAliveBucket in the new slot.
      childManager.didAdoptChild(child);
      // If there is an existing child in the new slot, that mean that child will
      // be moved to other index. In other cases, the existing child should have been
      // removed by updateChild. Thus, it is ok to overwrite it.
      // assert(() {
      //   if (_keepAliveBucket.containsKey(childParentData.index)) {
      //     _debugDanglingKeepAlives
      //         .add(_keepAliveBucket[childParentData.index]!);
      //   }
      //   return true;
      // }());
      // _keepAliveBucket[childParentData.index!] = child;
    }
  }

  // throw away this method, since `keepAlive === false`, and the method
  // collapse to simply call super
  // void remove(RenderBox child) {}

  // throw away this method, since all about keep alive
  // void removeAll() {}

  void _createOrObtainChild(int index, {required RenderBox? after}) {
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      assert(constraints == this.constraints);
      // if (_keepAliveBucket.containsKey(index)) {
      //   final RenderBox child = _keepAliveBucket.remove(index)!;
      //   final DynamicParentData childParentData =
      //       child.parentData! as DynamicParentData;
      //   assert(childParentData._keptAlive);
      //   dropChild(child);
      //   child.parentData = childParentData;
      //   insert(child, after: after);
      //   childParentData._keptAlive = false;
      // } else {
      _childManager.createChild(index, after: after);
      // }
    });
  }

  void _destroyOrCacheChild(RenderBox child) {
    // final DynamicParentData childParentData =
    //     child.parentData! as DynamicParentData;
    // if (childParentData.keepAlive) {
    //   assert(!childParentData._keptAlive);
    //   remove(child);
    //   _keepAliveBucket[childParentData.index!] = child;
    //   child.parentData = childParentData;
    //   super.adoptChild(child);
    //   childParentData._keptAlive = true;
    // } else {
    assert(child.parent == this);
    _childManager.removeChild(child);
    assert(child.parent == null);
    // }
  }

  // throw away this method, since all about keep alive
  // void attach(PipelineOwner owner) {}
  // void detach() {}
  // void redepthChildren() {}
  // void visitChildren(RenderObjectVisitor visitor) {}
  // void visitChildrenForSemantics(RenderObjectVisitor visitor) {}

  /// Called during layout to create and add the child with the given index and
  /// scroll offset.
  ///
  /// Calls [RenderSliverBoxChildManager.createChild] to actually create and add
  /// the child if necessary. The child may instead be obtained from a cache;
  /// see [DynamicParentData.keepAlive].
  ///
  /// Returns false if there was no cached child and `createChild` did not add
  /// any child, otherwise returns true.
  ///
  /// Does not layout the new child.
  ///
  /// When this is called, there are no visible children, so no children can be
  /// removed during the call to `createChild`. No child should be added during
  /// that call either, except for the one that is created and returned by
  /// `createChild`.
  @protected
  bool addInitialChild({int index = 0, double layoutOffset = 0.0}) {
    assert(_debugAssertChildListLocked());
    assert(firstChild == null);
    _createOrObtainChild(index, after: null);
    if (firstChild != null) {
      assert(firstChild == lastChild);
      assert(indexOf(firstChild!) == index);
      final DynamicParentData firstChildParentData =
          firstChild!.parentData! as DynamicParentData;
      firstChildParentData.layoutOffset = layoutOffset;
      return true;
    }
    childManager.setDidUnderflow(true);
    return false;
  }

  /// Called during layout to create, add, and layout the child before
  /// [firstChild].
  ///
  /// Calls [RenderSliverBoxChildManager.createChild] to actually create and add
  /// the child if necessary. The child may instead be obtained from a cache;
  /// see [DynamicParentData.keepAlive].
  ///
  /// Returns the new child or null if no child was obtained.
  ///
  /// The child that was previously the first child, as well as any subsequent
  /// children, may be removed by this call if they have not yet been laid out
  /// during this layout pass. No child should be added during that call except
  /// for the one that is created and returned by `createChild`.
  @protected
  RenderBox? insertAndLayoutLeadingChild(
    BoxConstraints childConstraints, {
    bool parentUsesSize = false,
  }) {
    assert(_debugAssertChildListLocked());
    final int index = indexOf(firstChild!) - 1;
    _createOrObtainChild(index, after: null);
    if (indexOf(firstChild!) == index) {
      firstChild!.layout(childConstraints, parentUsesSize: parentUsesSize);
      return firstChild;
    }
    childManager.setDidUnderflow(true);
    return null;
  }

  /// Called during layout to create, add, and layout the child after
  /// the given child.
  ///
  /// Calls [RenderSliverBoxChildManager.createChild] to actually create and add
  /// the child if necessary. The child may instead be obtained from a cache;
  /// see [DynamicParentData.keepAlive].
  ///
  /// Returns the new child. It is the responsibility of the caller to configure
  /// the child's scroll offset.
  ///
  /// Children after the `after` child may be removed in the process. Only the
  /// new child may be added.
  @protected
  RenderBox? insertAndLayoutChild(
    BoxConstraints childConstraints, {
    required RenderBox? after,
    bool parentUsesSize = false,
  }) {
    assert(_debugAssertChildListLocked());
    assert(after != null);
    final int index = indexOf(after!) + 1;
    _createOrObtainChild(index, after: after);
    final RenderBox? child = childAfter(after);
    if (child != null && indexOf(child) == index) {
      child.layout(childConstraints, parentUsesSize: parentUsesSize);
      return child;
    }
    childManager.setDidUnderflow(true);
    return null;
  }

  /// Called after layout with the number of children that can be garbage
  /// collected at the head and tail of the child list.
  ///
  /// Children whose [DynamicParentData.keepAlive] property is
  /// set to true will be removed to a cache instead of being dropped.
  ///
  /// This method also collects any children that were previously kept alive but
  /// are now no longer necessary. As such, it should be called every time
  /// [performLayout] is run, even if the arguments are both zero.
  @protected
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    assert(_debugAssertChildListLocked());
    assert(childCount >= leadingGarbage + trailingGarbage);
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      while (leadingGarbage > 0) {
        _destroyOrCacheChild(firstChild!);
        leadingGarbage -= 1;
      }
      while (trailingGarbage > 0) {
        _destroyOrCacheChild(lastChild!);
        trailingGarbage -= 1;
      }
      // // Ask the child manager to remove the children that are no longer being
      // // kept alive. (This should cause _keepAliveBucket to change, so we have
      // // to prepare our list ahead of time.)
      // _keepAliveBucket.values
      //     .where((RenderBox child) {
      //       final DynamicParentData childParentData =
      //           child.parentData! as DynamicParentData;
      //       return !childParentData.keepAlive;
      //     })
      //     .toList()
      //     .forEach(_childManager.removeChild);
      // assert(_keepAliveBucket.values.where((RenderBox child) {
      //   final DynamicParentData childParentData =
      //       child.parentData! as DynamicParentData;
      //   return !childParentData.keepAlive;
      // }).isEmpty);
    });
  }

  /// Returns the index of the given child, as given by the
  /// [DynamicParentData.index] field of the child's [parentData].
  int indexOf(RenderBox child) {
    assert(child != null);
    final DynamicParentData childParentData =
        child.parentData! as DynamicParentData;
    assert(childParentData.index != null);
    return childParentData.index!;
  }

  /// Returns the dimension of the given child in the main axis, as given by the
  /// child's [RenderBox.size] property. This is only valid after layout.
  @protected
  double paintExtentOf(RenderBox child) {
    assert(child != null);
    assert(child.hasSize);
    switch (constraints.axis) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    RenderBox? child = lastChild;
    final BoxHitTestResult boxResult = BoxHitTestResult.wrap(result);
    while (child != null) {
      if (hitTestBoxChild(boxResult, child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition)) {
        return true;
      }
      child = childBefore(child);
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return childScrollOffset(child)! - constraints.scrollOffset;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child != null);
    assert(child.parent == this);
    final DynamicParentData childParentData =
        child.parentData! as DynamicParentData;
    return childParentData.layoutOffset;
  }

  @override
  bool paintsChild(RenderBox child) {
    final DynamicParentData? childParentData =
        child.parentData as DynamicParentData?;
    return childParentData?.index != null &&
        !_keepAliveBucket.containsKey(childParentData!.index);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (!paintsChild(child)) {
      // This can happen if some child asks for the global transform even though
      // they are not getting painted. In that case, the transform sets set to
      // zero since [applyPaintTransformForBoxChild] would end up throwing due
      // to the child not being configured correctly for applying a transform.
      // There's no assert here because asking for the paint transform is a
      // valid thing to do even if a child would not be painted, but there is no
      // meaningful non-zero matrix to use in this case.
      transform.setZero();
    } else {
      applyPaintTransformForBoxChild(child, transform);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null) {
      return;
    }
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    final Offset mainAxisUnit, crossAxisUnit, originOffset;
    final bool addExtent;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry!.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry!.paintExtent, 0.0);
        addExtent = true;
        break;
    }
    assert(mainAxisUnit != null);
    assert(addExtent != null);
    RenderBox? child = firstChild;
    while (child != null) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx +
            mainAxisUnit.dx * mainAxisDelta +
            crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy +
            mainAxisUnit.dy * mainAxisDelta +
            crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) {
        childOffset += mainAxisUnit * paintExtentOf(child);
      }

      // If the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      if (mainAxisDelta < constraints.remainingPaintExtent &&
          mainAxisDelta + paintExtentOf(child) > 0) {
        context.paintChild(child, childOffset);
      }

      child = childAfter(child);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsNode.message(firstChild != null
        ? 'currently live children: ${indexOf(firstChild!)} to ${indexOf(lastChild!)}'
        : 'no children current live'));
  }

  /// Asserts that the reified child list is not empty and has a contiguous
  /// sequence of indices.
  ///
  /// Always returns true.
  bool debugAssertChildListIsNonEmptyAndContiguous() {
    assert(() {
      assert(firstChild != null);
      int index = indexOf(firstChild!);
      RenderBox? child = childAfter(firstChild!);
      while (child != null) {
        index += 1;
        assert(indexOf(child) == index);
        child = childAfter(child);
      }
      return true;
    }());
    return true;
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    if (firstChild != null) {
      RenderBox? child = firstChild;
      while (true) {
        final DynamicParentData childParentData =
            child!.parentData! as DynamicParentData;
        children.add(child.toDiagnosticsNode(
            name: 'child with index ${childParentData.index}'));
        if (child == lastChild) {
          break;
        }
        child = childParentData.nextSibling;
      }
    }
    // if (_keepAliveBucket.isNotEmpty) {
    //   final List<int> indices = _keepAliveBucket.keys.toList()..sort();
    //   for (final int index in indices) {
    //     children.add(_keepAliveBucket[index]!.toDiagnosticsNode(
    //       name: 'child with index $index (kept alive but not laid out)',
    //       style: DiagnosticsTreeStyle.offstage,
    //     ));
    //   }
    // }
    return children;
  }
}
