import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    count++;
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${count.toString().padRight(10)} ${DateTime.now()}',
          style: const TextStyle(fontSize: 30, color: Colors.black),
        ),
      ],
    );
  }
}
