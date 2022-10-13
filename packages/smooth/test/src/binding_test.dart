import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MainLayerTreeModeInAuxTreeView', (tester) async {
    expect(binding.mainLayerTreeModeInAuxTreeView,
        MainLayerTreeModeInAuxTreeView.previousPlainFrame);

    final smoothBuilderRunReasons = <RunPipelineReason>[];
    final smoothBuilderResults = <MainLayerTreeModeInAuxTreeView>[];

    await tester.pumpWidget(SmoothParent(
      child: MaterialApp(
        home: SmoothBuilder(
          builder: (_, child) => AlwaysBuildBuilder(
            onBuild: () {
              smoothBuilderRunReasons
                  .add(AuxiliaryTreePack.debugRunPipelineReason!);
              smoothBuilderResults.add(binding.mainLayerTreeModeInAuxTreeView);
            },
            child: child,
          ),
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
      [smoothBuilderRunReasons, smoothBuilderResults],
      [
        [
          RunPipelineReason.preemptRenderBuildOrLayoutPhase,
          RunPipelineReason.plainAfterFlushLayout,
          RunPipelineReason.preemptRenderPostDrawFramePhase,
        ],
        [
          MainLayerTreeModeInAuxTreeView.previousPlainFrame,
          MainLayerTreeModeInAuxTreeView.currentPlainFrame,
          MainLayerTreeModeInAuxTreeView.currentPlainFrame,
        ],
      ],
    );

    expect(binding.mainLayerTreeModeInAuxTreeView,
        MainLayerTreeModeInAuxTreeView.currentPlainFrame,
        reason: 'post frame');
  });
}
