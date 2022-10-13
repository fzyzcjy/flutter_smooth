import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MainLayerTreeModeInAuxTreeView', (tester) async {
    expect(binding.mainLayerTreeModeInAuxTreeView,
        MainLayerTreeModeInAuxTreeView.previousPlainFrame);

    final smoothBuilderResults = <MainLayerTreeModeInAuxTreeView>[];

    await tester.pumpWidget(SmoothParent(
      child: MaterialApp(
        home: SmoothBuilder(
          builder: (_, child) {
            smoothBuilderResults.add(binding.mainLayerTreeModeInAuxTreeView);
            return child;
          },
          child: Column(
            children: [
              AlwaysLayoutBuilder(onPerformLayout: () {
                binding.elapseBlocking(const Duration(microseconds: 16500));
              }),
              SmoothPreemptPoint(child: Container()),
              AlwaysLayoutBuilder(onPerformLayout: () {
                binding.elapseBlocking(const Duration(microseconds: 16500));
              }),
              AlwaysPaintBuilder(onPaint: () {
                binding.elapseBlocking(const Duration(microseconds: 16500));
              }),
            ],
          ),
        ),
      ),
    ));

    expect(
      smoothBuilderResults,
      [
        // extra preemptRender in build/layout phase
        MainLayerTreeModeInAuxTreeView.previousPlainFrame,
        // plain
        MainLayerTreeModeInAuxTreeView.currentPlainFrame,
        // extra preemptRender in PostDrawFrame phase
        MainLayerTreeModeInAuxTreeView.currentPlainFrame,
      ],
    );

    expect(binding.mainLayerTreeModeInAuxTreeView,
        MainLayerTreeModeInAuxTreeView.currentPlainFrame,
        reason: 'post frame');
  });
}
