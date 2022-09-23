// ignore_for_file: invalid_use_of_protected_member, avoid_print

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hello_package/demo/impl/auxiliary_tree.dart';

class Actor {
  static final instance = Actor._();

  Actor._();

  var lastPreemptTimeUs = 0;

  void maybePreemptRender() {
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
    // print('$runtimeType preemptRender start');

    // ref: https://github.com/fzyzcjy/yplusplus/issues/5780#issuecomment-1254562485
    // ref: RenderView.compositeFrame

    final builder = SceneBuilder();

    preemptModifyLayerTree();

    // why this layer - from RenderView.compositeFrame
    final binding = WidgetsFlutterBinding.ensureInitialized();
    final scene = binding.renderView.layer!.buildScene(builder);

    print('call window.render');
    window.render(scene);

    scene.dispose();

    // print('$runtimeType preemptRender end');
  }

  void preemptModifyLayerTree() {
    final pack = AuxiliaryTreePack.instance;
    if (pack == null) {
      // print('$runtimeType preemptModifyLayerTree pack==null thus skip');
      return;
    }
    pack.runPipeline();
  }
}
