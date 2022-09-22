// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

final secondTreePack = SecondTreePack();

void main() {
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  secondTreePack; // touch it
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
    // ref: RenderView.compositeFrame

    final builder = SceneBuilder();

    // final recorder = PictureRecorder();
    // final canvas = Canvas(recorder);
    // final rect = Rect.fromLTWH(0, 0, 500, 500);
    // canvas.drawRect(Rect.fromLTWH(100, 100, 50, 50.0 * parentBuildCount),
    //     Paint()..color = Colors.green);
    // final pictureLayer = PictureLayer(rect);
    // pictureLayer.picture = recorder.endRecording();
    // final rootLayer = OffsetLayer();
    // rootLayer.append(pictureLayer);
    // final scene = rootLayer.buildScene(builder);

    final binding = WidgetsFlutterBinding.ensureInitialized();

    preemptModifyLayerTree(binding);

    // why this layer? from RenderView.compositeFrame
    final scene = binding.renderView.layer!.buildScene(builder);

    print('call window.render');
    window.render(scene);

    scene.dispose();

    print('$runtimeType pseudoPreemptRender end');
  }

  void preemptModifyLayerTree(WidgetsBinding binding) {
    // hack, just want to prove we can change something (preemptModifyLayerTree)
    // inside the preemptRender
    final rootLayer = binding.renderView.layer! as TransformLayer;
    rootLayer.transform =
        rootLayer.transform!.multiplied(Matrix4.translationValues(0, 50, 0));
    print('preemptModifyLayerTree rootLayer=$rootLayer (after)');
  }
}

class SecondTreePack {
  late final PipelineOwner pipelineOwner;
  late final SecondTreeRootView rootView;
  late final BuildOwner buildOwner;
  late final RenderObjectToWidgetElement<RenderBox> element;

  var innerStatefulBuilderBuildCount = 0;
  late StateSetter innerStatefulBuilderSetState;

  SecondTreePack() {
    pipelineOwner = PipelineOwner();
    rootView = pipelineOwner.rootNode = SecondTreeRootView();
    buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () =>
          print('second tree BuildOwner.onBuildScheduled called'),
    );

    final secondTreeWidget = StatefulBuilder(builder: (_, setState) {
      print(
          'secondTreeWidget(StatefulBuilder).builder called ($innerStatefulBuilderBuildCount)');

      innerStatefulBuilderSetState = setState;
      innerStatefulBuilderBuildCount++;

      return SizedBox(
          width: innerStatefulBuilderBuildCount.toDouble(), height: 10);
    });

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: secondTreeWidget,
    ).attachToRenderTree(buildOwner);
  }
}

class SecondTreeRootView extends RenderBox
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
