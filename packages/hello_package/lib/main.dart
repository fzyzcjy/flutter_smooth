// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    print('$runtimeType.build ($buildCount)');

    if (buildCount < 5) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        print('$runtimeType.setState');
        setState(() {});
      });
    }

    return MaterialApp(
      home: Scaffold(
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Text('A$buildCount'),
        Text('B$buildCount'),
        const MyWidget(),
        Text('C$buildCount'),
      ],
    );
  }
}

class MyWidget extends SingleChildRenderObjectWidget {
  const MyWidget({
    super.key,
    super.child,
  });

  @override
  MyRender createRenderObject(BuildContext context) => MyRender();

  @override
  void updateRenderObject(BuildContext context, MyRender renderObject) {}
}

class MyRender extends RenderProxyBox {
  MyRender({
    RenderBox? child,
  }) : super(child);

  @override
  void performLayout() {
    // unconditionally call this, as an experiment
    pseudoPreemptRender();
    super.performLayout();
  }

  void pseudoPreemptRender() {
    print('$runtimeType pseudoPreemptRender start');

    // ref: https://github.com/fzyzcjy/yplusplus/issues/5780#issuecomment-1254562485
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(30, 200, 300, 300);
    canvas.drawCircle(Offset(10, 20), 10, Paint()..color = Colors.red);
    final pictureLayer = PictureLayer(rect);
    pictureLayer.picture = recorder.endRecording();
    final rootLayer = OffsetLayer();
    rootLayer.append(pictureLayer);
    final builder = SceneBuilder();
    final scene = rootLayer.buildScene(builder);
    window.render(scene);

    print('$runtimeType pseudoPreemptRender end');
  }
}
