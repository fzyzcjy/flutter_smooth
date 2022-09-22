// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forest', (tester) async {
    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;

    final pipelineOwner = PipelineOwner();
    final rootView = pipelineOwner.rootNode = MeasurementView();
    final buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () =>
          print('second tree BuildOwner.onBuildScheduled called'),
    );

    var secondTreeWidgetBuildTime = 0;
    late StateSetter secondTreeSetState;
    final secondTreeWidget = StatefulBuilder(builder: (_, setState) {
      print(
          'secondTreeWidget(StatefulBuilder).builder called ($secondTreeWidgetBuildTime)');

      secondTreeSetState = setState;
      secondTreeWidgetBuildTime++;

      return SizedBox(width: secondTreeWidgetBuildTime.toDouble(), height: 10);
    });

    // ignore: unused_local_variable
    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: secondTreeWidget,
    ).attachToRenderTree(buildOwner);

    print('before pumpWidget');
    rootView.scheduleInitialLayout();

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

            secondTreeSetState(() {});

            // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
            // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
            buildOwner.buildScope(element);
            pipelineOwner.flushLayout();
            pipelineOwner.flushCompositingBits();
            pipelineOwner.flushPaint();
            // renderView.compositeFrame(); // this sends the bits to the GPU
            // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
            buildOwner.finalizeTree();
            print('rootView.size=${rootView.size}');
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
