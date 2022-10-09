import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/service_locator.dart';

class ExampleListViewPage extends StatefulWidget {
  final bool enableSmooth;
  final bool enableDebugHeader;
  final bool leaveWhenPointerUp;
  final int? initialWorkload;

  const ExampleListViewPage({
    super.key,
    required this.enableSmooth,
    this.enableDebugHeader = false,
    this.leaveWhenPointerUp = false,
    this.initialWorkload,
  });

  @override
  State<ExampleListViewPage> createState() => _ExampleListViewPageState();
}

class _ExampleListViewPageState extends State<ExampleListViewPage> {
  // #6025
  late var workload = widget.initialWorkload ?? 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example (${widget.enableSmooth ? 'smooth' : 'plain'})'),
      ),
      body: Listener(
        // #6028
        onPointerUp: widget.leaveWhenPointerUp
            ? (_) => Navigator.of(context).pop()
            : null,
        child: Column(
          children: [
            if (widget.enableDebugHeader)
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _SimpleCounter(name: 'P'),
                      ),
                    ),
                    Expanded(
                      child: SmoothBuilder(
                        builder: (_, __) => const Directionality(
                          textDirection: TextDirection.ltr,
                          child: _SimpleCounter(name: 'S'),
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
                child: widget.enableSmooth ? _buildSmooth() : _buildPlain()),
            Row(
              children: [
                for (final value in [0, 1, 10, 50, 100, 200, 500])
                  SizedBox(
                    width: 48,
                    child: TextButton(
                      onPressed: () => setState(() => workload = value),
                      child: Text('$value'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlain() {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: _buildRow,
    );
  }

  Widget _buildSmooth() {
    return SmoothListView.builder(
      itemCount: 1000,
      itemBuilder: _buildRow,
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: SizedBox(
        width: 32,
        height: 32,
        child: CircleAvatar(
          backgroundColor: Colors.primaries[index % Colors.primaries.length],
          child: Text(
            'G$index',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      title: Container(
        // just for easy video checking
        color: index % 10 == 0
            ? Colors.green
            : index % 5 == 0
                ? Colors.pink
                : null,
        child: Text(
          '$index',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Stack(
        children: [
          // v1
          // https://github.com/fzyzcjy/yplusplus/issues/6022#issuecomment-1269158088
          // SizedBox(
          //   height: 36,
          //   // simulate slow build/layout; do not paint it, since much more
          //   // than realistic number of text
          //   child: Opacity(
          //     opacity: 0,
          //     child: OverflowBox(
          //       child: Stack(
          //         children: [
          //           for (var i = 0; i < workload * 10; ++i)
          //             LayoutPreemptPointWidget(
          //               child: Text(
          //                 // https://github.com/fzyzcjy/yplusplus/issues/6020#issuecomment-1268464366
          //                 '+91 88888 8800$index ' * 10,
          //                 style: const TextStyle(fontSize: 3),
          //               ),
          //             ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // v2 - #6076 find it wrong
          // // https://github.com/fzyzcjy/yplusplus/issues/6022#issuecomment-1269158088
          // _AlwaysLayoutBuilder(
          //   onPerformLayout: () {
          //     for (var i = 0; i < workload * 10; ++i) {
          //       sleep(const Duration(microseconds: 400));
          //       ServiceLocator.instance.actor.maybePreemptRender();
          //     }
          //   },
          //   child: Container(),
          // ),

          // v3
          // #6076
          _NormalLayoutBuilder(
            onPerformLayout: () {
              for (var i = 0; i < workload * 10; ++i) {
                sleep(const Duration(microseconds: 400));
                ServiceLocator.instance.actor.maybePreemptRender();
              }
            },
            child: Container(),
          ),
          Text('a\n' * (3 + Random().nextInt(3))),
        ],
      ),
    );
  }
}

class _SimpleCounter extends StatefulWidget {
  final String name;

  const _SimpleCounter({required this.name});

  @override
  State<_SimpleCounter> createState() => _SimpleCounterState();
}

class _SimpleCounterState extends State<_SimpleCounter>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(duration: const Duration(seconds: 1), vsync: this);

  late final _painter = _SimpleCounterPainter(repaint: _controller);

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: const SizedBox(
        height: 48,
        width: 24.0 * _SimpleCounterPainter.N,
      ),
    );
  }
}

class _SimpleCounterPainter extends CustomPainter {
  _SimpleCounterPainter({super.repaint});

  static final _painters = List.generate(
      N, (i) => Paint()..color = [Colors.red, Colors.green, Colors.blue][i]);

  static const N = 3;

  var _paintCount = 0;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCount++;

    final xDivide = size.width * 0.6;
    final lcdBounds = Rect.fromLTRB(0, 0, xDivide, size.height);
    final threeColorBounds = Rect.fromLTRB(xDivide, 0, size.width, size.height);

    LcdPainter.paintNumber(canvas, lcdBounds, _painters[_paintCount % N],
        number: _paintCount, numDigits: 3);

    _paintThreeColors(canvas, threeColorBounds);
  }

  void _paintThreeColors(Canvas canvas, Rect bounds) {
    canvas.drawRect(
      Rect.fromLTWH(
        bounds.left + bounds.size.width / N * (_paintCount % N),
        bounds.top,
        bounds.size.width / N,
        bounds.size.height,
      ),
      _painters[_paintCount % N],
    );
  }

  @override
  bool shouldRepaint(_SimpleCounterPainter oldDelegate) => true;
}

class LcdPainter {
  static void paintNumber(Canvas canvas, Rect bounds, Paint paint,
      {required int number, required int numDigits}) {
    final digitWidth = bounds.width / numDigits;
    for (var i = 0, value = number; i < numDigits; ++i, value ~/= 10) {
      final digitBoundsRaw = Rect.fromLTWH(
          bounds.left + digitWidth * i, bounds.top, digitWidth, bounds.height);
      final digitBounds = const EdgeInsets.all(4).deflateRect(digitBoundsRaw);
      _paintDigit(canvas, digitBounds, paint, digit: value % 10);
    }
  }

  static void _paintDigit(Canvas canvas, Rect bounds, Paint paint,
      {required int digit}) {
    final row1 = const [0, 2, 3, 5, 6, 7, 8, 9].contains(digit);
    final row2 = const [2, 3, 4, 5, 6, 8, 9].contains(digit);
    final row3 = const [0, 2, 3, 5, 6, 8, 9].contains(digit);
    final leftCol1 = const [0, 4, 5, 6, 7, 8, 9].contains(digit);
    final leftCol2 = const [0, 2, 6, 8].contains(digit);
    final rightCol1 = const [0, 1, 2, 3, 4, 7, 8, 9].contains(digit);
    final rightCol2 = const [0, 1, 3, 4, 5, 6, 7, 8, 9].contains(digit);

    final b = bounds;

    if (row1) canvas.drawLine(b.topLeft, b.topRight, paint);
    if (row2) canvas.drawLine(b.centerLeft, b.centerRight, paint);
    if (row3) canvas.drawLine(b.bottomLeft, b.bottomRight, paint);

    if (leftCol1) canvas.drawLine(b.topLeft, b.centerLeft, paint);
    if (leftCol2) canvas.drawLine(b.centerLeft, b.bottomLeft, paint);

    if (rightCol1) canvas.drawLine(b.topRight, b.centerRight, paint);
    if (rightCol2) canvas.drawLine(b.centerRight, b.bottomRight, paint);
  }
}

class _NormalLayoutBuilder extends SingleChildRenderObjectWidget {
  final VoidCallback? onPerformLayout;

  const _NormalLayoutBuilder({
    this.onPerformLayout,
    super.child,
  });

  @override
  _RenderNormalLayoutBuilder createRenderObject(BuildContext context) =>
      _RenderNormalLayoutBuilder(
        onPerformLayout: onPerformLayout,
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderNormalLayoutBuilder renderObject) {
    renderObject.onPerformLayout = onPerformLayout;
  }
}

class _RenderNormalLayoutBuilder extends RenderProxyBox {
  _RenderNormalLayoutBuilder({
    required this.onPerformLayout,
    RenderBox? child,
  }) : super(child);

  VoidCallback? onPerformLayout;

  @override
  void performLayout() {
    super.performLayout();
    onPerformLayout?.call();
    // this is NOT "always layout builder", so do not mark needs layout
  }
}

// class _AlwaysLayoutBuilder extends SingleChildRenderObjectWidget {
//   final VoidCallback? onPerformLayout;
//
//   const _AlwaysLayoutBuilder({
//     this.onPerformLayout,
//     super.child,
//   });
//
//   @override
//   _RenderAlwaysLayoutBuilder createRenderObject(BuildContext context) =>
//       _RenderAlwaysLayoutBuilder(
//         onPerformLayout: onPerformLayout,
//       );
//
//   @override
//   void updateRenderObject(
//       BuildContext context, _RenderAlwaysLayoutBuilder renderObject) {
//     renderObject.onPerformLayout = onPerformLayout;
//   }
// }
//
// class _RenderAlwaysLayoutBuilder extends RenderProxyBox {
//   _RenderAlwaysLayoutBuilder({
//     required this.onPerformLayout,
//     RenderBox? child,
//   }) : super(child);
//
//   VoidCallback? onPerformLayout;
//
//   @override
//   void performLayout() {
//     // print('$runtimeType.performLayout');
//
//     super.performLayout();
//     onPerformLayout?.call();
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       if (!attached) return;
//       markNeedsLayout();
//     });
//   }
// }
