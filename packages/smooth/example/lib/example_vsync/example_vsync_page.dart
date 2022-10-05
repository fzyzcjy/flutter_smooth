import 'dart:io';

import 'package:example/utils/debug_plain_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ExampleVsyncPage extends StatelessWidget {
  const ExampleVsyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example: Vsync'),
      ),
      body: const _AlwaysRebuildDummyWidget(),
    );
  }
}

class _AlwaysRebuildDummyWidget extends StatefulWidget {
  const _AlwaysRebuildDummyWidget();

  @override
  State<_AlwaysRebuildDummyWidget> createState() =>
      _AlwaysRebuildDummyWidgetState();
}

class _AlwaysRebuildDummyWidgetState extends State<_AlwaysRebuildDummyWidget> {
  @override
  Widget build(BuildContext context) {
    // deliberately make each frame a bit more than 16.67ms
    sleep(const Duration(milliseconds: 17));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });

    return const CounterWidget();
  }
}
