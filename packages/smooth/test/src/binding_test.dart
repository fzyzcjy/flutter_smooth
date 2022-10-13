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
        MainLayerTreeModeInAuxTreeView.currentPlainFrame);

    final smoothBuilderRunReasons = <RunPipelineReason>[];
    final smoothBuilderResults = <MainLayerTreeModeInAuxTreeView>[];

    await tester.pumpWidget(SmoothParent(
      child: MaterialApp(
        home: SmoothBuilder(
          builder: (_, child) => AnimationControllerProvider(
            builder: (_, animation) => AnimatedBuilder(
              animation: animation,
              builder: (_, __) {
                smoothBuilderRunReasons
                    .add(AuxiliaryTreePack.debugRunPipelineReason!);
                smoothBuilderResults
                    .add(binding.mainLayerTreeModeInAuxTreeView);
                return child;
              },
            ),
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
          // what reason does not matter. The important thing is,
          // the reason (i.e. when it is called) corresponds correctly
          // to the [MainLayerTreeModeInAuxTreeView] value
          RunPipelineReason.attachToRenderTree,
          RunPipelineReason.renderAdapterInMainTreePerformLayout,
          RunPipelineReason.preemptRenderBuildOrLayoutPhase,
          RunPipelineReason.plainAfterFlushLayout,
          RunPipelineReason.preemptRenderPostDrawFramePhase,
        ],
        [
          MainLayerTreeModeInAuxTreeView.previousPlainFrame,
          MainLayerTreeModeInAuxTreeView.previousPlainFrame,
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
