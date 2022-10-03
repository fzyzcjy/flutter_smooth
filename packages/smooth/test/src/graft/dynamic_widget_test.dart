// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/graft/dynamic_widget.dart';

void main() {
  testWidgets('simplest', (tester) async {
    {
      late final List<String> childrenNamesWhenPaint;
      await tester.pumpWidget(_TestDynamicWidget(
        onPerformLayout: (that, constraints) {
          expect(that.firstChild, isNull);
          that.addInitialChild(index: 'a');
          that.firstChild!.layout(constraints);

          that.insertAndLayoutChild(constraints,
              index: 'b', after: that.firstChild!);
        },
        onPaint: (that) =>
            childrenNamesWhenPaint = that.childrenTestWidgetNames,
        dummy: 1,
      ));

      expect(_TestWidget.findAll(), ['a', 'b']);
      expect(childrenNamesWhenPaint, ['a', 'b']);
    }

    {
      late final List<String> childrenNamesWhenPaint;
      await tester.pumpWidget(_TestDynamicWidget(
        onPerformLayout: (that, constraints) {
          expect(that.childrenTestWidgetNames, ['a', 'b']);

          final a = that.firstChild! as _RenderTest;
          expect(a.name, 'a');
          // do not layout `a` and GC it

          final b = that.childAfter(a)! as _RenderTest;
          expect(b.name, 'b');
          b.layout(constraints);

          that.insertAndLayoutChild(constraints, index: 'c', after: b);
          expect(that.childrenTestWidgetNames, ['a', 'b', 'c']);

          that.collectGarbage(['a']);
          expect(that.childrenTestWidgetNames, ['b', 'c']);
        },
        onPaint: (that) =>
            childrenNamesWhenPaint = that.childrenTestWidgetNames,
        dummy: 2,
      ));
      await tester.pump();

      expect(_TestWidget.findAll(), ['b', 'c']);
      expect(childrenNamesWhenPaint, ['b', 'c']);
    }
  });
}

class _TestDynamicWidget extends DynamicWidget<String> {
  final void Function(_TestRenderDynamic, BoxConstraints) onPerformLayout;
  final void Function(_TestRenderDynamic) onPaint;
  final int dummy;

  const _TestDynamicWidget({
    required this.onPerformLayout,
    required this.onPaint,
    required this.dummy,
  });

  @override
  Widget? build(DynamicElement<Object> element, String index) =>
      _TestWidget(name: index);

  @override
  _TestRenderDynamic createRenderObject(BuildContext context) =>
      _TestRenderDynamic(
        childManager: context as DynamicElement<String>,
        onPerformLayout: onPerformLayout,
        onPaint: onPaint,
        dummy: dummy,
      );

  @override
  void updateRenderObject(
          BuildContext context, _TestRenderDynamic renderObject) =>
      renderObject
        ..onPerformLayout = onPerformLayout
        ..onPaint = onPaint
        ..dummy = dummy;
}

class _TestRenderDynamic extends RenderDynamic<String> {
  _TestRenderDynamic({
    required super.childManager,
    required this.onPerformLayout,
    required this.onPaint,
    required int dummy,
  }) : _dummy = dummy;

  void Function(_TestRenderDynamic, BoxConstraints) onPerformLayout;
  void Function(_TestRenderDynamic) onPaint;

  int get dummy => _dummy;
  int _dummy;

  set dummy(int value) {
    if (_dummy == value) return;
    _dummy = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    onPerformLayout(this, constraints);
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    onPaint(this);
    defaultPaint(context, offset);
  }

  List<String> get childrenTestWidgetNames =>
      getChildrenAsList().map((child) => (child as _RenderTest).name).toList();
}

class _TestWidget extends SingleChildRenderObjectWidget {
  final String name;

  const _TestWidget({required this.name});

  static List<String> findAll() => find
      .byType(_TestWidget)
      .evaluate()
      .map((element) => (element.widget as _TestWidget).name)
      .toList();

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTest(name: name);

  @override
  void updateRenderObject(BuildContext context, _RenderTest renderObject) =>
      renderObject.name = name;
}

class _RenderTest extends RenderProxyBox {
  _RenderTest({required this.name});

  String name;
}
