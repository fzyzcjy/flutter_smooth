import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

class ExampleListViewSubPage extends StatelessWidget {
  final bool enableSmooth;
  final bool enableDebugHeader;
  final bool leaveWhenPointerUp;
  final bool enableNewItemWorkload;
  final bool enableAlwaysWorkload;

  const ExampleListViewSubPage({
    super.key,
    required this.enableSmooth,
    this.enableDebugHeader = false,
    this.leaveWhenPointerUp = false,
    this.enableNewItemWorkload = true,
    this.enableAlwaysWorkload = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Listener(
          // #6028
          onPointerUp:
              leaveWhenPointerUp ? (_) => Navigator.of(context).pop() : null,
          child: Column(
            children: [
              if (enableDebugHeader)
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      const Expanded(
                        child: _SimpleCounter(name: 'P'),
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
              // #6101
              // for normal case, still mimic it is a bit slow to be real
              if (enableAlwaysWorkload)
                for (var i = 0; i < 5; ++i)
                  SmoothBrakePoint(
                    child: SmoothLayoutPreemptPointWidget(
                      child: _AlwaysLayoutBuilder(
                        onPerformLayout: () {
                          // NOTE `sleep` does not support microseconds! #6109
                          sleep(const Duration(milliseconds: 1));
                        },
                      ),
                    ),
                  ),
              Expanded(child: enableSmooth ? _buildSmooth() : _buildPlain()),
            ],
          ),
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
      // TODO only prototype currently, should make it full featured later
      //      e.g. make it a real item
      placeholder: _buildPlaceholder(),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    Color? rowColor;
    if (index.isEven) {
      switch ((index ~/ 2) % 3) {
        case 0:
          rowColor = Colors.pink;
          break;
        case 1:
          rowColor = Colors.green;
          break;
        case 2:
          rowColor = Colors.indigo;
          break;
      }
    }

    // NOTE to be real, should not be too huge (though we can make
    // it 60FPS). #6204
    final workloadMilliseconds = index.isEven ? 80 : 0;

    return SizedBox(
      // NOTE should *not* use random height that changes *every time* it is
      // built, otherwise the offset in the Matplotlib visualization can be
      // very confusing even if it is correct
      // https://github.com/fzyzcjy/yplusplus/issues/6154#issuecomment-1275497820
      height: 96.0 + (index % 4) * 16,
      child: Stack(
        children: [
          // #6076
          if (enableNewItemWorkload)
            for (var i = 0; i < workloadMilliseconds; ++i)
              SmoothBrakePoint(
                child: SmoothLayoutPreemptPointWidget(
                  child: _NormalLayoutBuilder(
                    onPerformLayout: () {
                      // NOTE `sleep` does not support microseconds! #6109
                      sleep(const Duration(milliseconds: 1));
                    },
                  ),
                ),
              ),
          if (rowColor != null)
            ColoredBox(
              color: rowColor,
              child: const SizedBox(height: 8, width: double.infinity),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('$index'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildPlaceholder() {
    return PreferredSize(
      preferredSize: const Size(300, 128),
      child: SizedBox(
        height: 128,
        child: Container(
            margin: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 32,
                height: 12,
                color: Colors.grey.shade200,
              ),
            )),
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

  late final _painter =
      _SimpleCounterPainter(name: widget.name, repaint: _controller);

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
  final String name;

  _SimpleCounterPainter({required this.name, super.repaint});

  static final _painters = List.generate(
      N,
      (i) => Paint()
        ..strokeWidth = 10
        ..color = [Colors.red, Colors.green, Colors.blue][i]);

  static const N = 3;

  var _paintCount = 0;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCount++;

    Timeline.timeSync('$_paintCount.$name.SimpleCounter', () {
      final xDivide = size.width * 0.6;
      final lcdBoundLeft = Rect.fromLTRB(0, 0, xDivide / 2, size.height);
      final lcdBoundRight = Rect.fromLTRB(xDivide / 2, 0, xDivide, size.height);
      final threeColorBounds =
          Rect.fromLTRB(xDivide, 0, size.width, size.height);

      final painter = _painters[_paintCount % N];

      _paintLcdNumber(canvas, lcdBoundLeft, painter, (_paintCount ~/ 10) % 10);
      _paintLcdNumber(canvas, lcdBoundRight, painter, _paintCount % 10);
      _paintThreeColors(canvas, painter, threeColorBounds);
    });
  }

  void _paintThreeColors(Canvas canvas, Paint painter, Rect bounds) {
    canvas.drawRect(
      Rect.fromLTWH(
        bounds.left + bounds.size.width / N * (_paintCount % N),
        bounds.top,
        bounds.size.width / N,
        bounds.size.height,
      ),
      painter,
    );
  }

  static void _paintLcdNumber(
      Canvas canvas, Rect bounds, Paint painter, int number) {
    assert(number >= 0 && number <= 9);

    if (number == 0) {
      canvas.drawRect(bounds, painter);
    } else {
      const K = 3;
      final x = (number - 1) % K;
      final y = (number - 1) ~/ K;
      canvas.drawRect(
        Rect.fromLTWH(
          bounds.left + bounds.size.width / K * x,
          bounds.top + bounds.size.height / K * y,
          bounds.size.width / K,
          bounds.size.height / K,
        ),
        painter,
      );
    }
  }

  @override
  bool shouldRepaint(_SimpleCounterPainter oldDelegate) => true;
}

class _NormalLayoutBuilder extends SingleChildRenderObjectWidget {
  final VoidCallback? onPerformLayout;

  const _NormalLayoutBuilder({
    this.onPerformLayout,
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

class _AlwaysLayoutBuilder extends SingleChildRenderObjectWidget {
  final VoidCallback? onPerformLayout;

  const _AlwaysLayoutBuilder({
    this.onPerformLayout,
  });

  @override
  _RenderAlwaysLayoutBuilder createRenderObject(BuildContext context) =>
      _RenderAlwaysLayoutBuilder(
        onPerformLayout: onPerformLayout,
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderAlwaysLayoutBuilder renderObject) {
    renderObject.onPerformLayout = onPerformLayout;
  }
}

class _RenderAlwaysLayoutBuilder extends RenderProxyBox {
  _RenderAlwaysLayoutBuilder({
    required this.onPerformLayout,
    RenderBox? child,
  }) : super(child);

  VoidCallback? onPerformLayout;

  @override
  void performLayout() {
    // print('$runtimeType.performLayout');

    super.performLayout();
    onPerformLayout?.call();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!attached) return;
      markNeedsLayout();
    });
  }
}
