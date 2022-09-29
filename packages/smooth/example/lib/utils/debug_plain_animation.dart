import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DebugPlainAnimationPage extends StatelessWidget {
  const DebugPlainAnimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Plain Animation'),
        ),
        body: const Center(
          child: RepaintBoundary(
            child: _DebugPlainAnimationInner(),
          ),
        ),
      ),
    );
  }
}

class _DebugPlainAnimationInner extends StatefulWidget {
  const _DebugPlainAnimationInner();

  @override
  State<_DebugPlainAnimationInner> createState() =>
      __DebugPlainAnimationInnerState();
}

class __DebugPlainAnimationInnerState extends State<_DebugPlainAnimationInner> {
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
        const SizedBox(height: 16),
        const Text(
          'This simple animation only serves to test your monitor. '
          'If this one is not 60FPS, then your monitor/recorder/player/etc may have problem',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}
