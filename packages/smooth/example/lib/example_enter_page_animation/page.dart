// ignore_for_file: avoid_print

import 'package:clock/clock.dart';
import 'package:example/example_enter_page_animation/animation.dart';
import 'package:example/utils/complex_widget.dart';
import 'package:example/utils/duration_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

class ExampleEnterPageAnimationPage extends StatefulWidget {
  const ExampleEnterPageAnimationPage({super.key});

  @override
  State<ExampleEnterPageAnimationPage> createState() =>
      _ExampleEnterPageAnimationPageState();
}

class _ExampleEnterPageAnimationPageState
    extends State<ExampleEnterPageAnimationPage> {
  final pageLoadRecorders = DurationRecorders<EnterPageAnimationMode?>();
  EnterPageAnimationMode? mode;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          _buildFirstPage(),
          EnterPageAnimation(
            mode: mode,
            child: SecondPage(
              pageLoadRecorder: pageLoadRecorders.get(mode),
              onTapBack: () {
                setState(() => mode = null);
                SmoothDebug.debugPrintStat();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Preempt for 60FPS')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final targetMode in EnterPageAnimationMode.values)
                ListTile(
                  title: Text(targetMode.name),
                  onTap: () => setState(() => mode = targetMode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final DurationRecorder pageLoadRecorder;
  final VoidCallback onTapBack;

  const SecondPage({
    super.key,
    required this.pageLoadRecorder,
    required this.onTapBack,
  });

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  var firstFrame = true;
  late final DateTime initStateTime;

  @override
  void initState() {
    super.initState();
    initStateTime = clock.now();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() => firstFrame = false);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.pageLoadRecorder.record(clock.now().difference(initStateTime));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SecondPage'),
          leading: IconButton(
            onPressed: widget.onTapBack,
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        // NOTE: this one extra frame lag is *avoidable*.
        // Since this is a prototype, I do not bother to initialize the aux tree pack
        // in a fancier way.
        body: firstFrame ? Container() : const ComplexLongColumn(),
      ),
    );
  }
}
