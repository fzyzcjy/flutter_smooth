import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/graft/dynamic_widget.dart';

void main() {
  testWidgets('simplest', (tester) async {
    await tester.pumpWidget(_TestDynamicWidget(builder: (context, index) {
      return TODO;
    }));
    TODO;
  });
}

class _TestDynamicWidget extends DynamicWidget<String> {
  final Widget Function(BuildContext, String index) builder;

  const _TestDynamicWidget({required this.builder});

  @override
  Widget? build(DynamicElement<Object> element, String index) =>
      builder(element, index);

  @override
  _TestRenderDynamic createRenderObject(BuildContext context) =>
      _TestRenderDynamic(childManager: context as DynamicElement<String>);

  @override
  void updateRenderObject(
      BuildContext context, covariant _TestRenderDynamic renderObject) {}
}

class _TestRenderDynamic extends RenderDynamic<String> {
  _TestRenderDynamic({required super.childManager});

  @override
  void performLayout() {
    super.performLayout();
    TODO;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    TODO;
  }
}
