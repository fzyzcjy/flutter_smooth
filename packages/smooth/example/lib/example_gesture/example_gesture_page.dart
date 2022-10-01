import 'package:example/example_gesture/gesture_visualizer.dart';
import 'package:example/utils/complex_widget.dart';
import 'package:example/utils/debug_plain_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

class ExampleGesturePage extends StatefulWidget {
  const ExampleGesturePage({super.key});

  @override
  State<ExampleGesturePage> createState() => _ExampleGesturePageState();
}

class _ExampleGesturePageState extends State<ExampleGesturePage> {
  var listTileCount = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // const LeaveAfterSomeFrames(),
            SizedBox(
              height: 150,
              child: RepaintBoundary(
                child: GestureVisualizerByListener(
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: ColoredBox(color: Colors.green.shade50)),
                      const CounterWidget(prefix: 'Plain: '),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: SmoothBuilder(
                // // only to reproduce #5879
                // builder: (_, child) => const _Dummy(),
                builder: (_, child) => Directionality(
                  textDirection: TextDirection.ltr,
                  child: GestureVisualizerByListener(
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: ColoredBox(color: Colors.blue.shade50)),
                        const CounterWidget(prefix: 'Smooth: '),
                      ],
                    ),
                  ),
                ),
                // child: Container(color: Colors.green),
                child: const SizedBox(),
              ),
            ),
            SizedBox(
              height: 100,
              // https://github.com/fzyzcjy/yplusplus/issues/5876#issuecomment-1263264848
              child: RepaintBoundary(
                // https://github.com/fzyzcjy/yplusplus/issues/5876#issuecomment-1263276032
                child: ClipRect(
                  child: OverflowBox(
                    child: _buildAlwaysRebuildComplexWidget(),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final value in [1, 10, 20, 100, 200])
                  TextButton(
                    onPressed: () => setState(() => listTileCount = value),
                    child: Text('$value'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static var _dummy = 1;

  Widget _buildAlwaysRebuildComplexWidget() {
    return StatefulBuilder(builder: (_, setState) {
      SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));

      return Opacity(
        opacity: 0,
        child: ComplexWidget(
          // thus it will recreate the whole subtree, in each frame
          key: ValueKey('${_dummy++}'),
          listTileCount: listTileCount,
          wrapListTile: null,
        ),
      );
    });
  }
}

// class _Dummy extends StatefulWidget {
//   const _Dummy();
//
//   @override
//   State<_Dummy> createState() => _DummyState();
// }
//
// class _DummyState extends State<_Dummy> {
//   var count = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     count++;
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       setState(() {});
//     });
//
//     print('hi ${describeIdentity(this)}.build');
//     return _DummyInner(
//       dummy: count,
//       child: ColoredBox(color: Colors.cyan[(count % 8 + 1) * 100]!),
//     );
//   }
// }
//
// class _DummyInner extends SingleChildRenderObjectWidget {
//   final int dummy;
//
//   const _DummyInner({
//     super.key,
//     required this.dummy,
//     super.child,
//   });
//
//   @override
//   _RenderDummy createRenderObject(BuildContext context) =>
//       _RenderDummy(dummy: dummy);
//
//   @override
//   void updateRenderObject(BuildContext context, _RenderDummy renderObject) {
//     renderObject.dummy = dummy;
//   }
// }
//
// class _RenderDummy extends RenderProxyBox {
//   _RenderDummy({
//     required int dummy,
//     RenderBox? child,
//   })  : _dummy = dummy,
//         super(child);
//
//   // not mark repaint yet
//   int get dummy => _dummy;
//   int _dummy;
//
//   set dummy(int value) {
//     if (_dummy == value) return;
//     _dummy = value;
//     print('hi ${describeIdentity(this)} set dummy thus markNeedsPaint START');
//     markNeedsPaint();
//     print('hi ${describeIdentity(this)} set dummy thus markNeedsPaint END');
//   }
//
//   @override
//   void paint(PaintingContext context, Offset offset) {
//     print('hi ${describeIdentity(this)}.paint');
//     super.paint(context, offset);
//   }
// }
//
// class LeaveAfterSomeFrames extends StatefulWidget {
//   final VoidCallback? onBuild;
//   final Widget? child;
//
//   const LeaveAfterSomeFrames({super.key, this.onBuild, this.child});
//
//   @override
//   State<LeaveAfterSomeFrames> createState() => _LeaveAfterSomeFramesState();
// }
//
// class _LeaveAfterSomeFramesState extends State<LeaveAfterSomeFrames> {
//   var count = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     count++;
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       if (mounted) setState(() {});
//       if (count >= 10) {
//         print('action: Leave after some frames!');
//         Navigator.pop(context);
//         count = -99999;
//       }
//     });
//     widget.onBuild?.call();
//     return widget.child ?? Container();
//   }
// }
