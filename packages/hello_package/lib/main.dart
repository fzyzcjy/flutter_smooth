// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

void main() {
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
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
      Future.delayed(Duration(seconds: 1), () {
        print('$runtimeType.setState after a second');
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
        Text('A$buildCount', style: TextStyle(fontSize: 30)),
        Text('B$buildCount', style: TextStyle(fontSize: 30)),
        MyWidget(parentBuildCount: buildCount),
        Text('C$buildCount', style: TextStyle(fontSize: 30)),
      ],
    );
  }
}

class MyWidget extends SingleChildRenderObjectWidget {
  final int parentBuildCount;

  const MyWidget({
    super.key,
    required this.parentBuildCount,
    super.child,
  });

  @override
  MyRender createRenderObject(BuildContext context) => MyRender(
        parentBuildCount: parentBuildCount,
      );

  @override
  void updateRenderObject(BuildContext context, MyRender renderObject) {
    renderObject.parentBuildCount = parentBuildCount;
  }
}

class MyRender extends RenderProxyBox {
  MyRender({
    required int parentBuildCount,
    RenderBox? child,
  })  : _parentBuildCount = parentBuildCount,
        super(child);

  int get parentBuildCount => _parentBuildCount;
  int _parentBuildCount;

  set parentBuildCount(int value) {
    if (_parentBuildCount == value) return;
    _parentBuildCount = value;
    print('$runtimeType markNeedsLayout because parentBuildCount changes');
    markNeedsLayout();
  }

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
    final rect = Rect.fromLTWH(0, 0, 300, 300);
    final paint = Paint()
      ..color = Colors.primaries[parentBuildCount % Colors.primaries.length];
    canvas.drawCircle(Offset(150, 150), 100, paint);
    final pictureLayer = PictureLayer(rect);
    pictureLayer.picture = recorder.endRecording();
    final rootLayer = OffsetLayer();
    rootLayer.append(pictureLayer);
    final builder = SceneBuilder();
    final scene = rootLayer.buildScene(builder);

    print('call window.render');
    window.render(scene);

    print('$runtimeType pseudoPreemptRender end');
  }
}
