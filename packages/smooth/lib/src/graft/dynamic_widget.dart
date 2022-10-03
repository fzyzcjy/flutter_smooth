import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that has dynamic number of children
// ref [SliverList], i.e. [SliverMultiBoxAdaptorWidget]
abstract class DynamicWidget<S extends Object> extends RenderObjectWidget {
  const DynamicWidget({super.key});

  @override
  DynamicElement<S> createElement() => DynamicElement(this);

  @override
  RenderDynamic<S> createRenderObject(BuildContext context);

  Widget? build(DynamicElement element, S index);
}

// ref [RenderSliverBoxChildManager]
// see [RenderSliverBoxChildManager] for long doc comments for most methods
abstract class RenderDynamicChildManager<S extends Object> {
  void createChild(S index, {required RenderBox? after});

  void removeChild(RenderBox child);

  void didAdoptChild(RenderBox child);

  void didStartLayout();

  void didFinishLayout();

  bool debugAssertChildListLocked();
}

// ref [SliverMultiBoxAdaptorElement] - the whole class is copied and (largely)
// modified from it
class DynamicElement<S extends Object> extends RenderObjectElement
    implements RenderDynamicChildManager<S> {
  DynamicElement(DynamicWidget<S> super.widget);

  @override
  RenderDynamic<S> get renderObject => super.renderObject as RenderDynamic<S>;

  // no need to mimic this, since its logic is for a changeable delegate object
  // void update(covariant SliverMultiBoxAdaptorWidget newWidget) {}

  // ref [SliverMultiBoxAdaptorElement]
  final _childElements = SplayTreeMap<S, Element?>();
  RenderBox? _currentBeforeChild;

  // ref [SliverMultiBoxAdaptorElement]
  @override
  void performRebuild() {
    super.performRebuild();
    _currentBeforeChild = null;
    assert(_currentlyUpdatingChildIndex == null);
    try {
      final widgetTyped = widget as DynamicWidget<S>;
      final indices = _childElements.keys.toList();
      for (final index in indices) {
        _currentlyUpdatingChildIndex = index;
        final newChild = updateChild(
            _childElements[index], _build(index, widgetTyped), index);
        if (newChild != null) {
          _childElements[index] = newChild;
          _currentBeforeChild = newChild.renderObject as RenderBox?;
        } else {
          _childElements.remove(index);
        }
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
    }
  }

  // ref [SliverMultiBoxAdaptorElement]
  Widget? _build(S index, DynamicWidget<S> widget) {
    // originally: `return widget.delegate.build(this, index);`
    // but we do not have any changeable `delegate` variable to simplify impl
    return widget.build(this, index);
  }

  // ref [SliverMultiBoxAdaptorElement]
  @override
  void createChild(S index, {required RenderBox? after}) {
    assert(_currentlyUpdatingChildIndex == null);
    owner!.buildScope(this, () {
      // final insertFirst = after == null;
      // assert(insertFirst || _childElements[index - 1] != null);
      // _currentBeforeChild = insertFirst ? null : (_childElements[index - 1]!.renderObject as RenderBox?);
      _currentBeforeChild = after;
      Element? newChild;
      try {
        final adaptorWidget = widget as DynamicWidget<S>;
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
    final S index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    // assert(index >= 0);
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

  S? _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final childParentData = child.parentData! as DynamicParentData<S>;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, S slot) {
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child as RenderBox, after: _currentBeforeChild);
    assert(() {
      final childParentData = child.parentData! as DynamicParentData<S>;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child, S oldSlot, S newSlot) {
    assert(_currentlyUpdatingChildIndex == newSlot);
    renderObject.move(child as RenderBox, after: _currentBeforeChild);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, S slot) {
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
class DynamicParentData<S extends Object> extends ParentData
    with ContainerParentDataMixin<RenderBox> {
  /// The index of this child according to the [RenderDynamicChildManager].
  S? index;

  @override
  String toString() => 'index=$index; ${super.toString()}';
}

// ref [RenderSliverMultiBoxAdaptor]
abstract class RenderDynamic<S extends Object> extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, DynamicParentData<S>> {
  RenderDynamic({required this.childManager});

  /// The delegate that manages the children of this object.
  ///
  /// Rather than having a concrete list of children, a
  /// [RenderDynamic] uses a [RenderDynamicChildManager] to
  /// create children during layout.
  // ref [RenderSliverMultiBoxAdaptor]
  final RenderDynamicChildManager<S> childManager;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! DynamicParentData<S>) {
      child.parentData = DynamicParentData<S>();
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

  // originally named `_createOrObtainChild`, but no "obtain" logic since no keepalive
  void _createChild(S index, {required RenderBox? after}) {
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      assert(constraints == this.constraints);
      childManager.createChild(index, after: after);
    });
  }

  // originally named `_destroyOrCacheChild`, but no "cache" logic since no keepalive
  void _destroyChild(RenderBox child) {
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
  bool addInitialChild({required S index}) {
    assert(_debugAssertChildListLocked());
    assert(firstChild == null);
    _createChild(index, after: null);
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
    required S index,
    bool parentUsesSize = false,
  }) {
    assert(_debugAssertChildListLocked());
    // final S index = indexOf(firstChild!) - 1;
    _createChild(index, after: null);
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
    required S index,
    required RenderBox after,
    bool parentUsesSize = false,
  }) {
    assert(_debugAssertChildListLocked());
    // final S index = indexOf(after) + 1;
    _createChild(index, after: after);
    final RenderBox? child = childAfter(after);
    if (child != null && indexOf(child) == index) {
      child.layout(childConstraints, parentUsesSize: parentUsesSize);
      return child;
    }
    return null;
  }

  // ref [RenderSliverMultiBoxAdaptor], but modified
  /// Called after layout with the slots that can be garbage collected.
  @protected
  void collectGarbage(Iterable<S> slotsToRemove) {
    assert(_debugAssertChildListLocked());
    invokeLayoutCallback((constraints) {
      for (final slot in slotsToRemove) {
        _destroyChild(TODO);
      }
    });
  }

  /// Returns the index of the given child, as given by the
  /// [DynamicParentData.index] field of the child's [parentData].
  S indexOf(RenderBox child) {
    final childParentData = child.parentData! as DynamicParentData<S>;
    assert(childParentData.index != null);
    return childParentData.index!;
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final children = <DiagnosticsNode>[];
    if (firstChild != null) {
      RenderBox? child = firstChild;
      while (true) {
        final childParentData = child!.parentData! as DynamicParentData<S>;
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
