import 'dart:io';

import 'package:example/utils/debug_plain_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

class ExampleSimpleAnimationPage extends StatelessWidget {
  final bool smooth;

  const ExampleSimpleAnimationPage({super.key, required this.smooth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example: Simple animation'),
      ),
      body: Stack(
        children: [
          for (var i = 0; i < 20; ++i)
            _SleepAndAlwaysRebuildWidget(
              sleepDuration: const Duration(milliseconds: 1),
              child: smooth //
                  ? SmoothPreemptPoint(child: Container())
                  : Container(),
            ),
          const CounterWidget(),
        ],
      ),
    );
  }
}

class _SleepAndAlwaysRebuildWidget extends StatefulWidget {
  final Duration sleepDuration;
  final Widget child;

  const _SleepAndAlwaysRebuildWidget(
      {required this.sleepDuration, required this.child});

  @override
  State<_SleepAndAlwaysRebuildWidget> createState() =>
      _SleepAndAlwaysRebuildWidgetState();
}

class _SleepAndAlwaysRebuildWidgetState
    extends State<_SleepAndAlwaysRebuildWidget> {
  @override
  Widget build(BuildContext context) {
    sleep(widget.sleepDuration);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });

    return widget.child;
  }
}
