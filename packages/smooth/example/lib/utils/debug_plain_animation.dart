import 'package:flutter/material.dart';

class DebugPlainAnimationPage extends StatelessWidget {
  const DebugPlainAnimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Plain Animation'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RepaintBoundary(
                child: CounterWidget(),
              ),
              SizedBox(height: 16),
              Text(
                'This simple animation only serves to test your monitor. '
                'If this one is not 60FPS, then your monitor/recorder/player/etc may have problem',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CounterWidget extends StatefulWidget {
  final String prefix;

  const CounterWidget({super.key, this.prefix = ''});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget>
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            _count++;
            return Text(
              '${widget.prefix} ${_count.toString().padRight(10)} ${DateTime.now()}',
              style: const TextStyle(color: Colors.black, fontSize: 22),
            );
          },
        ),
        RotationTransition(
          turns: _controller,
          child: Container(
            width: 50,
            height: 50,
            color: Colors.green,
            child: const Center(
              child: Text(
                'a',
                style: TextStyle(fontSize: 50, color: Colors.white, height: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
