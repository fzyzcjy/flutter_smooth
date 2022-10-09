import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';

class ExperimentListView extends StatelessWidget {
  const ExperimentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example (Control Group)'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: const [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _SimpleCounter(name: 'P'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildPlain()),
        ],
      ),
    );
  }

  Widget _buildPlain() {
    return ListView.builder(
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
  double? _prevAnimationValue;
  var _buildCount = 0, _animationValueChangeCount = 0;

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
        _buildCount++;

        final currAnimationValue = _controller.value;
        if (_prevAnimationValue != currAnimationValue) {
          _animationValueChangeCount++;
        }
        _prevAnimationValue = currAnimationValue;

        // #6029

        return Timeline.timeSync(
            '$_buildCount.$_animationValueChangeCount.${widget.name}.SimpleCounter',
            () {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.name,
                style: const TextStyle(color: Colors.black, fontSize: 8),
              ),
              Text(
                // ignore: prefer_interpolation_to_compose_strings
                (_buildCount % 1000).toString().padRight(3) +
                    '|' +
                    (_animationValueChangeCount % 1000).toString().padRight(3),
                style: const TextStyle(color: Colors.black, fontSize: 26),
              ),
              CustomPaint(
                painter: _SimpleCounterPainter(
                  index: _buildCount,
                ),
                child: const SizedBox(
                  height: 48,
                  width: 24.0 * _SimpleCounterPainter.N,
                ),
              ),
            ],
          );
        });
      },
    );
  }
}

class _SimpleCounterPainter extends CustomPainter {
  final int index;

  _SimpleCounterPainter({required this.index});

  static final _painters = List.generate(
      N, (i) => Paint()..color = [Colors.red, Colors.green, Colors.blue][i]);

  static const N = 3;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / N * (index % N),
        0,
        size.width / N,
        size.height,
      ),
      _painters[index % N],
    );
  }

  @override
  bool shouldRepaint(_SimpleCounterPainter oldDelegate) =>
      oldDelegate.index != index;
}
