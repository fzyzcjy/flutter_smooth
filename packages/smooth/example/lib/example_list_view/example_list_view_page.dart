import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/service_locator.dart';

class ExampleListViewPage extends StatefulWidget {
  final bool enableSmooth;
  final bool leaveWhenPointerUp;

  const ExampleListViewPage({
    super.key,
    required this.enableSmooth,
    this.leaveWhenPointerUp = false,
  });

  @override
  State<ExampleListViewPage> createState() => _ExampleListViewPageState();
}

class _ExampleListViewPageState extends State<ExampleListViewPage> {
  // #6025
  var workload = 3;

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
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _SimpleCounter(name: 'Plain'),
                    ),
                  ),
                  Expanded(
                    child: SmoothBuilder(
                      builder: (_, __) => const Directionality(
                        textDirection: TextDirection.ltr,
                        child: _SimpleCounter(name: 'Smooth'),
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
                for (final value in [0, 1, 3, 10, 20, 50, 100, 200])
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
        color: index % 10 == 0 ? Colors.green : null,
        child: Text(
          '$index',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Stack(
        children: [
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
          // https://github.com/fzyzcjy/yplusplus/issues/6022#issuecomment-1269158088
          _AlwaysLayoutBuilder(
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
  var _count = 0;

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        _count++;
        return Text(
          '${widget.name} ${_count.toString().padRight(5)}',
          style: const TextStyle(color: Colors.black, fontSize: 32),
        );
      },
    );
  }
}

class _AlwaysLayoutBuilder extends SingleChildRenderObjectWidget {
  final VoidCallback? onPerformLayout;

  const _AlwaysLayoutBuilder({
    this.onPerformLayout,
    super.child,
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
    SchedulerBinding.instance.addPostFrameCallback((_) => markNeedsLayout());
  }
}
