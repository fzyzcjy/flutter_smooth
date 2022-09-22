// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forest', (tester) async {
    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;

    final secondTreePack = SecondTreePack();

    print('before pumpWidget');
    secondTreePack.rootView.scheduleInitialLayout();

    var mainTreeBuilderBuildCount = 0;
    late StateSetter mainTreeStatefulBuilderSetState;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (_, setState) {
          mainTreeStatefulBuilderSetState = setState;
          mainTreeBuilderBuildCount++;
          print(
              'main tree StatefulBuilder.builder callback ($mainTreeBuilderBuildCount)');

          // for (var iter = 0; iter < 3; ++iter) {
          //   print(
          //       'mainTree(StatefulBuilder).builder, run second tree pipeline iter=#$iter');
          //
          //   secondTreePack.innerStatefulBuilderSetState(() {});
          //
          //   // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
          //   // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
          //   secondTreePack.buildOwner.buildScope(secondTreePack.element);
          //   secondTreePack.pipelineOwner.flushLayout();
          //   secondTreePack.pipelineOwner.flushCompositingBits();
          //   secondTreePack.pipelineOwner.flushPaint();
          //   // renderView.compositeFrame(); // this sends the bits to the GPU
          //   // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
          //   secondTreePack.buildOwner.finalizeTree();
          //   print('rootView.size=${secondTreePack.rootView.size}');
          // }

          return SecondTreeAdapterWidget(
            child: SizedBox(width: 20, height: 20),
          );
        }),
      ),
    ));

    for (var i = 0; i < 5; ++i) {
      mainTreeStatefulBuilderSetState(() {});
      await tester.pump();
    }

    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
  });
}

class SecondTreeAdapterWidget extends SingleChildRenderObjectWidget {
  const SecondTreeAdapterWidget({
    super.key,
    super.child,
  });

  @override
  RenderSecondTreeAdapter createRenderObject(BuildContext context) =>
      RenderSecondTreeAdapter();

  @override
  void updateRenderObject(
      BuildContext context, RenderSecondTreeAdapter renderObject) {}
}

class RenderSecondTreeAdapter extends RenderShiftedBox {
  RenderSecondTreeAdapter({
    RenderBox? child,
  }) : super(child);

  // TODO handle layout!
}

class SecondTreePack {
  late final PipelineOwner pipelineOwner;
  late final SecondTreeRootView rootView;
  late final BuildOwner buildOwner;
  late final RenderObjectToWidgetElement<RenderBox> element;

  var innerStatefulBuilderBuildCount = 0;
  late StateSetter innerStatefulBuilderSetState;

  SecondTreePack() {
    pipelineOwner = PipelineOwner();
    rootView = pipelineOwner.rootNode = SecondTreeRootView();
    buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () =>
          print('second tree BuildOwner.onBuildScheduled called'),
    );

    final secondTreeWidget = StatefulBuilder(builder: (_, setState) {
      print(
          'secondTreeWidget(StatefulBuilder).builder called ($innerStatefulBuilderBuildCount)');

      innerStatefulBuilderSetState = setState;
      innerStatefulBuilderBuildCount++;

      return SizedBox(
          width: innerStatefulBuilderBuildCount.toDouble(), height: 10);
    });

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: secondTreeWidget,
    ).attachToRenderTree(buildOwner);
  }
}

class SecondTreeRootView extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  @override
  void performLayout() {
    assert(child != null);
    child!.layout(const BoxConstraints(), parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}
