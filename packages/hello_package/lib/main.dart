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
        SecondTreeAdapterWidget(
          parentBuildCount: buildCount,
          child: Container(
            color: Colors.pink.shade100,
            child: Text('child-inside-SecondTreeAdapter$buildCount'),
          ),
        ),
        Text('B$buildCount', style: TextStyle(fontSize: 30)),
        WindowRenderWhenLayoutWidget(parentBuildCount: buildCount),
        Text('C$buildCount', style: TextStyle(fontSize: 30)),
      ],
    );
  }
}

class WindowRenderWhenLayoutWidget extends SingleChildRenderObjectWidget {
  final int parentBuildCount;

  const WindowRenderWhenLayoutWidget({
    super.key,
    required this.parentBuildCount,
    super.child,
  });

  @override
  WindowRenderWhenLayoutRender createRenderObject(BuildContext context) =>
      WindowRenderWhenLayoutRender(
        parentBuildCount: parentBuildCount,
      );

  @override
  void updateRenderObject(
      BuildContext context, WindowRenderWhenLayoutRender renderObject) {
    renderObject.parentBuildCount = parentBuildCount;
  }
}

class WindowRenderWhenLayoutRender extends RenderProxyBox {
  WindowRenderWhenLayoutRender({
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

    refreshSecondTree();
  }

  void refreshSecondTree() {
    print('$runtimeType refreshSecondTree start');
    secondTreePack.innerStatefulBuilderSetState(() {});

    // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
    // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
    secondTreePack.buildOwner.buildScope(secondTreePack.element);
    secondTreePack.pipelineOwner.flushLayout();
    secondTreePack.pipelineOwner.flushCompositingBits();
    secondTreePack.pipelineOwner.flushPaint();
    // renderView.compositeFrame(); // this sends the bits to the GPU
    // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
    secondTreePack.buildOwner.finalizeTree();

    print('$runtimeType refreshSecondTree end');
  }
}

class SecondTreeAdapterWidget extends SingleChildRenderObjectWidget {
  final int parentBuildCount;

  const SecondTreeAdapterWidget({
    super.key,
    required this.parentBuildCount,
    super.child,
  });

  @override
  RenderSecondTreeAdapter createRenderObject(BuildContext context) =>
      RenderSecondTreeAdapter(parentBuildCount: parentBuildCount);

  @override
  void updateRenderObject(
      BuildContext context, RenderSecondTreeAdapter renderObject) {
    renderObject.parentBuildCount = parentBuildCount;
  }
}

class RenderSecondTreeAdapter extends RenderProxyBox {
  RenderSecondTreeAdapter({
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

  // should not be singleton, but we are prototyping so only one such guy
  static RenderSecondTreeAdapter? instance;

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    assert(instance == null);
    instance = this;
  }

  @override
  void detach() {
    assert(instance == this);
    instance == null;
    super.detach();
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    print('$runtimeType.layout called');
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    print('$runtimeType.paint called (child=$child)');

    // super.paint(context, offset);
    // return;
    //
    // {
    //   final recorder = PictureRecorder();
    //   final canvas = Canvas(recorder);
    //   final rect = Rect.fromLTWH(0, 0, 500, 500);
    //   canvas.drawRect(Rect.fromLTWH(0, 0, 50, 50.0 * parentBuildCount),
    //       Paint()..color = Colors.green);
    //   final pictureLayer = PictureLayer(rect);
    //   pictureLayer.picture = recorder.endRecording();
    //   final wrapperLayer = OffsetLayer();
    //   wrapperLayer.append(pictureLayer);
    //   context.pushLayer(wrapperLayer, (context, offset) { }, offset);
    //   return;
    // }

    // ref: RenderOpacity

    // TODO this makes "second tree root layer" be *removed* from its original
    //      parent. shall we move it back later? o/w can be slow!
    final secondTreeRootLayer = secondTreePack.rootView.layer!;

    // HACK!!!
    // if (secondTreeRootLayer.attached) {
    //   print('$runtimeType.paint detach the secondTreeRootLayer');
    //   // TODO attach again later?
    //   secondTreeRootLayer.detach();
    // }

    print('$runtimeType.paint pushLayer');
    context.pushLayer(secondTreeRootLayer, (context, offset) {}, offset);

    assert(secondTreeRootLayer.attached);

    // TODO paint child
  }

// TODO handle layout!
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

    rootView.prepareInitialFrame();

    final secondTreeWidget = StatefulBuilder(builder: (_, setState) {
      print(
          'secondTreeWidget(StatefulBuilder).builder called ($innerStatefulBuilderBuildCount)');

      innerStatefulBuilderSetState = setState;
      innerStatefulBuilderBuildCount++;

      return Container(
        width: 100 * innerStatefulBuilderBuildCount.toDouble(),
        height: 100,
        color: Colors.primaries[
            innerStatefulBuilderBuildCount % Colors.primaries.length],
      );
    });

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: secondTreeWidget,
    ).attachToRenderTree(buildOwner);
  }
}

class SecondTreeRootView extends RenderObject
    with RenderObjectWithChildMixin<RenderBox> {
  @override
  void performLayout() {
    print('$runtimeType performLayout');
    assert(child != null);
    child!.layout(const BoxConstraints(), parentUsesSize: true);
    // size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;

  void prepareInitialFrame() {
    // ref: RenderView
    scheduleInitialLayout();
    scheduleInitialPaint(_updateMatricesAndCreateNewRootLayer());
  }

  // ref: RenderView
  TransformLayer _updateMatricesAndCreateNewRootLayer() {
    final rootLayer = TransformLayer(transform: Matrix4.identity());
    rootLayer.attach(this);
    return rootLayer;
  }

  // ref: RenderView
  @override
  bool get isRepaintBoundary => true;

  // TODO is this paint bounds correct?
  // hack: just give non-sense value
  @override
  Rect get paintBounds => Offset.zero & Size(500, 500);

  // ref: RenderView
  @override
  void performResize() {
    assert(false);
  }

  // hack: just give non-sense value
  @override
  Rect get semanticBounds => paintBounds;
}
