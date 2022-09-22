// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forest', (tester) async {
    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (_, setState) {
          // deliberately do it *inside* a build!
          final size = measureWidget(const SizedBox(width: 640, height: 480));
          print('call measureWidget and get size=$size');

          // even do it twice!
          final size2 = measureWidget(const SizedBox(width: 123, height: 456));
          print('call measureWidget and get size2=$size2');

          SchedulerBinding.instance.addPostFrameCallback((_) {
            print('deliberately setState');
            setState(() {});
          });

          return Text('$size');
        }),
      ),
    ));

    for (var i = 0; i < 5; ++i) {
      await tester.pump();
    }

    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
  });
}

Size measureWidget(Widget widget) {
  final PipelineOwner pipelineOwner = PipelineOwner();
  final MeasurementView rootView = pipelineOwner.rootNode = MeasurementView();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
  final RenderObjectToWidgetElement<RenderBox> element =
  RenderObjectToWidgetAdapter<RenderBox>(
    container: rootView,
    debugShortDescription: '[root]',
    child: widget,
  ).attachToRenderTree(buildOwner);
  try {
    rootView.scheduleInitialLayout();
    pipelineOwner.flushLayout();
    return rootView.size;
  } finally {
    // Clean up.
    element.update(RenderObjectToWidgetAdapter<RenderBox>(container: rootView));
    buildOwner.finalizeTree();
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
