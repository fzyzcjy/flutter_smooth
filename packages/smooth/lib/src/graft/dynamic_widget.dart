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

  // no need to mimic [SliverMultiBoxAdaptorElement.update],
  // since we do not have a changeable delegate object
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
          if (index == 0) {
            parentData.layoutOffset = 0.0;
          } else if (indexToLayoutOffset.containsKey(index)) {
            parentData.layoutOffset = indexToLayoutOffset[index];
          }
          if (!parentData.keptAlive) {
            _currentBeforeChild = newChild.renderObject as RenderBox?;
          }
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

        if (childParentData != null && childParentData.layoutOffset != null) {
          indexToLayoutOffset[index] = childParentData.layoutOffset!;
        }

        if (newIndex != null && newIndex != index) {
          // The layout offset of the child being moved is no longer accurate.
          if (childParentData != null) {
            childParentData.layoutOffset = null;
          }

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
    return widget.delegate.build(this, index);
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

  // ref [SliverMultiBoxAdaptorElement]
  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    final oldParentData = child?.renderObject?.parentData as DynamicParentData?;
    final newChild = super.updateChild(child, newWidget, newSlot);
    final newParentData =
        newChild?.renderObject?.parentData as DynamicParentData?;

    // Preserve the old layoutOffset if the renderObject was swapped out.
    if (oldParentData != newParentData &&
        oldParentData != null &&
        newParentData != null) {
      newParentData.layoutOffset = oldParentData.layoutOffset;
    }
    return newChild;
  }

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
    final firstIndex = _childElements.firstKey() ?? 0;
    final lastIndex = _childElements.lastKey() ?? 0;
    (widget as DynamicWidget).delegate.didFinishLayout(firstIndex, lastIndex);
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

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.cast<Element>().where((Element child) {
      final parentData = child.renderObject!.parentData! as DynamicParentData;
      final double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject!.paintBounds.width;
          break;
        case Axis.vertical:
          itemExtent = child.renderObject!.paintBounds.height;
          break;
      }

      return parentData.layoutOffset != null &&
          parentData.layoutOffset! <
              renderObject.constraints.scrollOffset +
                  renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset! + itemExtent >
              renderObject.constraints.scrollOffset;
    }).forEach(visitor);
  }
}

class DynamicParentData extends ParentData
    with ContainerParentDataMixin<RenderBox> {}

// ref [RenderSliverMultiBoxAdaptor]
abstract class RenderDynamic extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, DynamicParentData> {
  RenderDynamic({required this.childManager});

  // ref [RenderSliverMultiBoxAdaptor]
  final RenderDynamicChildManager childManager;

// TODO
}
