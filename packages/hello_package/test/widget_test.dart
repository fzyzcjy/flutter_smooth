// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forest', (tester) async {
    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;

    final secondTree = SecondTree();

    print('before pumpWidget');
    secondTree.rootView.scheduleInitialLayout();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (_, setState) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            print('mainTree(StatefulBuilder).setState');
            setState(() {});
          });

          for (var iter = 0; iter < 3; ++iter) {
            print(
                'mainTree(StatefulBuilder).builder, run second tree pipeline iter=#$iter');

            secondTree.innerStatefulBuilderSetState(() {});

            // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
            // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
            secondTree.buildOwner.buildScope(secondTree.element);
            secondTree.pipelineOwner.flushLayout();
            secondTree.pipelineOwner.flushCompositingBits();
            secondTree.pipelineOwner.flushPaint();
            // renderView.compositeFrame(); // this sends the bits to the GPU
            // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
            secondTree.buildOwner.finalizeTree();
            print('rootView.size=${secondTree.rootView.size}');
          }

          return SizedBox(width: 20, height: 20);
        }),
      ),
    ));

    for (var i = 0; i < 5; ++i) {
      await tester.pump();
    }

    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
  });
}

class SecondTree {
  late final PipelineOwner pipelineOwner;
  late final MeasurementView rootView;
  late final BuildOwner buildOwner;
  late final RenderObjectToWidgetElement<RenderBox> element;

  var innerStatefulBuilderBuildTime = 0;
  late StateSetter innerStatefulBuilderSetState;

  SecondTree() {
    pipelineOwner = PipelineOwner();
    rootView = pipelineOwner.rootNode = MeasurementView();
    buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () =>
          print('second tree BuildOwner.onBuildScheduled called'),
    );

    final secondTreeWidget = StatefulBuilder(builder: (_, setState) {
      print(
          'secondTreeWidget(StatefulBuilder).builder called ($innerStatefulBuilderBuildTime)');

      innerStatefulBuilderSetState = setState;
      innerStatefulBuilderBuildTime++;

      return SizedBox(
          width: innerStatefulBuilderBuildTime.toDouble(), height: 10);
    });

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: secondTreeWidget,
    ).attachToRenderTree(buildOwner);
  }
}

class MeasurementView extends RenderBox
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
