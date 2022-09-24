// ignore_for_file: invalid_use_of_protected_member, avoid_print

import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hello_package/demo/impl/auxiliary_tree.dart';

class Actor {
  static final instance = Actor._();

  final stopwatch = () {
    final s = Stopwatch();
    print('stopwatch frequency=${s.frequency}');
    s.start();
    return s;
  }();

  Actor._();

  var lastPreemptTimeUs = 0;

  void maybePreemptRender() {
    if (AuxiliaryTreePack.instance == null) {
      // means this experiment is NOT enabled.
      return;
    }

    // TODO how much time?
    const kThresh = 14 * 1000;
    // const kThresh = 100 * 1000;

    final now = DateTime.now().microsecondsSinceEpoch;
    var currentFrameStartTimeUs =
        SchedulerBinding.instance.currentFrameStartTimeUs!;
    final deltaTime = now - max(lastPreemptTimeUs, currentFrameStartTimeUs);
    if (deltaTime > kThresh) {
      // print('$runtimeType maybePreemptRender say yes '
      //     'now=$now currentFrameStartTimeUs=$currentFrameStartTimeUs lastPreemptTimeUs=$lastPreemptTimeUs');
      lastPreemptTimeUs = now;
      preemptRender();
    }
  }

  void preemptRender() {
    Timeline.timeSync('PreemptRender', () {
      // print('$runtimeType preemptRender start');

      // ref: https://github.com/fzyzcjy/yplusplus/issues/5780#issuecomment-1254562485
      // ref: RenderView.compositeFrame

      final builder = SceneBuilder();

      preemptModifyLayerTree();

      // why this layer - from RenderView.compositeFrame
      final binding = WidgetsFlutterBinding.ensureInitialized();
      final scene = binding.renderView.layer!.buildScene(builder);

      Timeline.timeSync('window.render', () {
        print(
            'call window.render (now=${DateTime.now()}, stopwatch=${stopwatch.elapsed})');
        window.render(scene);
      });

      scene.dispose();
    });

    // print('$runtimeType preemptRender end');
  }

  void preemptModifyLayerTree() {
    AuxiliaryTreePack.instance!.runPipeline(debugReason: 'preemptModifyLayerTree');
  }
}
