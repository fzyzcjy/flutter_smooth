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
// see [RenderSliverBoxChildManager] for long doc comments for most methods
abstract class RenderDynamicChildManager {
  void createChild(int index, {required RenderBox? after});

  void removeChild(RenderBox child);

  void didAdoptChild(RenderBox child);

  void didStartLayout() {}

  void didFinishLayout() {}

  bool debugAssertChildListLocked() => true;
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
        // final childParentData = _childElements[index]!.renderObject?.parentData
        //     as DynamicParentData?;

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

      // renderObject.debugChildIntegrityEnabled = false; // Moving children will temporary violate the integrity.
      newChildren.keys.forEach(processElement);
    } finally {
      _currentlyUpdatingChildIndex = null;
      // renderObject.debugChildIntegrityEnabled = true;
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

  // throw away, since both of its check are meaningless in DynamicWidget
  // 1. Verify that the children index in childList is in ascending order.
  //    -> our "index" is slot and is orderless
  // 2. Verify that there is no dangling keepalive child as the result of [move].
  //    -> we do not implement keepalive
  // bool _debugChildIntegrityEnabled = true;
  // bool _debugVerifyChildOrder() {}

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    childManager.didAdoptChild(child as RenderBox);
  }

  bool _debugAssertChildListLocked() =>
      childManager.debugAssertChildListLocked();

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    assert(firstChild != null);
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    // The child is in the childList maintained by ContainerRenderObjectMixin.
    // We can call super.move and update parentData with the new slot.
    super.move(child, after: after);
    childManager.didAdoptChild(child); // updates the slot in the parentData
    // Its slot may change even if super.move does not change the position.
    // In this case, we still want to mark as needs layout.
    markNeedsLayout();
  }

  // throw away this method, since `keepAlive === false`, and the method
  // collapse to simply call super
  // void remove(RenderBox child) {}

  // throw away this method, since all about keep alive
  // void removeAll() {}

  void _createOrObtainChild(int index, {required RenderBox? after}) {
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      assert(constraints == this.constraints);
      childManager.createChild(index, after: after);
    });
  }

  void _destroyOrCacheChild(RenderBox child) {
    assert(child.parent == this);
    childManager.removeChild(child);
    assert(child.parent == null);
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
  bool addInitialChild({int index = 0}) {
    assert(_debugAssertChildListLocked());
    assert(firstChild == null);
    _createOrObtainChild(index, after: null);
    if (firstChild != null) {
      assert(firstChild == lastChild);
      assert(indexOf(firstChild!) == index);
      return true;
    }
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
    });
  }

  /// Returns the index of the given child, as given by the
  /// [DynamicParentData.index] field of the child's [parentData].
  int indexOf(RenderBox child) {
    final childParentData = child.parentData! as DynamicParentData;
    assert(childParentData.index != null);
    return childParentData.index!;
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final children = <DiagnosticsNode>[];
    if (firstChild != null) {
      RenderBox? child = firstChild;
      while (true) {
        final childParentData = child!.parentData! as DynamicParentData;
        children.add(child.toDiagnosticsNode(
            name: 'child with index ${childParentData.index}'));
        if (child == lastChild) {
          break;
        }
        child = childParentData.nextSibling;
      }
    }
    return children;
  }
}
