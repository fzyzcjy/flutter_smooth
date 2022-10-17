// ==========================================================================
// NOTE this file is copied from my internal repository. do not modify here.
// ==========================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ignore_for_file: curly_braces_in_flow_control_structures, always_require_non_null_named_parameters, omit_local_variable_types, avoid-non-null-assertion

class EnhancedPadding extends SingleChildRenderObjectWidget {
  // ignore: unnecessary-nullable
  const EnhancedPadding({
    super.key,
    this.enableAllowNegativePadding = false,
    this.enableAllowOutOfBoundHitTest = false,
    required this.padding,
    super.child,
  });

  /// The amount of space by which to inset the child.
  final EdgeInsetsGeometry padding;

  final bool enableAllowNegativePadding;
  final bool enableAllowOutOfBoundHitTest;

  @override
  RenderEnhancedPadding createRenderObject(BuildContext context) {
    return RenderEnhancedPadding(
      enableAllowNegativePadding: enableAllowNegativePadding,
      enableAllowOutOfBoundHitTest: enableAllowOutOfBoundHitTest,
      padding: padding,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderEnhancedPadding renderObject) {
    renderObject
      ..enableAllowNegativePadding = enableAllowNegativePadding
      ..enableAllowOutOfBoundHitTest = enableAllowOutOfBoundHitTest
      ..padding = padding
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  }
}

class RenderEnhancedPadding extends RenderShiftedBox
    with
        // NOTE XXX add
        HitTestAllowOutOfBoundRenderBoxMixin {
  RenderEnhancedPadding({
    required this.enableAllowNegativePadding,
    required this.enableAllowOutOfBoundHitTest,
    required EdgeInsetsGeometry padding,
    TextDirection? textDirection,
    RenderBox? child,
  })  :
        // NOTE XXX
        assert(enableAllowNegativePadding || padding.isNonNegative),
        _textDirection = textDirection,
        _padding = padding,
        super(child);

  // NOTE XXX add
  bool enableAllowNegativePadding;
  @override
  bool enableAllowOutOfBoundHitTest;

  EdgeInsets? _resolvedPadding;

  void _resolve() {
    if (_resolvedPadding != null) return;
    _resolvedPadding = padding.resolve(textDirection);
    // NOTE XXX
    assert(enableAllowNegativePadding || _resolvedPadding!.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;

  set padding(EdgeInsetsGeometry value) {
    // NOTE XXX
    assert(enableAllowNegativePadding || value.isNonNegative);
    if (_padding == value) return;
    _padding = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [padding].
  ///
  /// This may be changed to null, but only after the [padding] has been changed
  /// to a value that does not depend on the direction.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;

  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedResolution();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child!.getMinIntrinsicWidth(
              math.max(0.0, height - totalVerticalPadding)) +
          totalHorizontalPadding;
    return totalHorizontalPadding;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child!.getMaxIntrinsicWidth(
              math.max(0.0, height - totalVerticalPadding)) +
          totalHorizontalPadding;
    return totalHorizontalPadding;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child!.getMinIntrinsicHeight(
              math.max(0.0, width - totalHorizontalPadding)) +
          totalVerticalPadding;
    return totalVerticalPadding;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
      return child!.getMaxIntrinsicHeight(
              math.max(0.0, width - totalHorizontalPadding)) +
          totalVerticalPadding;
    return totalVerticalPadding;
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    _resolve();
    assert(_resolvedPadding != null);
    if (child == null) {
      size = constraints.constrain(Size(
        _resolvedPadding!.left + _resolvedPadding!.right,
        _resolvedPadding!.top + _resolvedPadding!.bottom,
      ));
      return;
    }
    final BoxConstraints innerConstraints =
        constraints.deflate(_resolvedPadding!);
    child!.layout(innerConstraints, parentUsesSize: true);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset =
        Offset(_resolvedPadding!.left, _resolvedPadding!.top);
    size = constraints.constrain(Size(
      _resolvedPadding!.left + child!.size.width + _resolvedPadding!.right,
      _resolvedPadding!.top + child!.size.height + _resolvedPadding!.bottom,
    ));
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      final Rect outerRect = offset & size;
      debugPaintPadding(context.canvas, outerRect,
          child != null ? _resolvedPadding!.deflateRect(outerRect) : null);
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
  }
}

mixin HitTestAllowOutOfBoundRenderBoxMixin on RenderBox {
  bool get enableAllowOutOfBoundHitTest;

  // NOTE XXX 修改自[RenderBox.hitTest]
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'Cannot hit test a render box that has never been laid out.'),
            describeForError(
                'The hitTest() method was called on this RenderBox'),
            ErrorDescription(
              "Unfortunately, this object's geometry is not known at this time, "
              'probably because it has never been laid out. '
              'This means it cannot be accurately hit-tested.',
            ),
            ErrorHint(
              'If you are trying '
              'to perform a hit test during the layout phase itself, make sure '
              "you only hit test nodes that have completed layout (e.g. the node's "
              'children, after their layout() method has been called).',
            ),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription(
            'Although this node is not marked as needing layout, '
            'its size is not set.',
          ),
          ErrorHint(
            'A RenderBox object must have an '
            'explicit size before it can be hit-tested. Make sure '
            'that the RenderBox in question sets its size during layout.',
          ),
        ]);
      }
      return true;
    }());
    if (enableAllowOutOfBoundHitTest || size.contains(position)) {
      if (hitTestChildren(result, position: position) ||
          hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }
}
