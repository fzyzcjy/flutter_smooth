// ignore_for_file: invalid_use_of_protected_member, avoid_print

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hello_package/demo/impl/auxiliary_tree.dart';

class Actor {
  static final instance = Actor._();

  Actor._();

  void maybePreemptRender() {
    // TODO how much time?
    const kThresh = Duration(milliseconds: 14);

    final deltaTime = DateTime.now()
        .difference(SchedulerBinding.instance.currentFrameStartTime!);
    if (deltaTime > kThresh) {
      preemptRender();
    }
  }

  void preemptRender() {
    print('$runtimeType preemptRender start');

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

    print('$runtimeType preemptRender end');
  }

  void preemptModifyLayerTree() {
    refreshAuxiliaryTree();
  }

  void refreshAuxiliaryTree() {
    print('$runtimeType refreshAuxiliaryTree start');

    final pack = AuxiliaryTreePack.instance;
    if (pack == null) {
      print('$runtimeType refreshAuxiliaryTree pack==null thus skip');
      return;
    }

    pack.innerStatefulBuilderSetState(() {});

    // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
    // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
    pack.buildOwner.buildScope(pack.element);
    pack.pipelineOwner.flushLayout();
    pack.pipelineOwner.flushCompositingBits();
    pack.pipelineOwner.flushPaint();
    // renderView.compositeFrame(); // this sends the bits to the GPU
    // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
    pack.buildOwner.finalizeTree();

    print('$runtimeType refreshAuxiliaryTree end');
  }
}
