// ignore_for_file: avoid_print

import 'package:clock/clock.dart';
import 'package:example/example_enter_page_animation/animation.dart';
import 'package:example/utils/complex_widget.dart';
import 'package:example/utils/duration_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

class ExampleEnterPageAnimationPage extends StatefulWidget {
  final int listTileCount;
  final WidgetWrapper? wrapListTile;

  const ExampleEnterPageAnimationPage({
    super.key,
    this.listTileCount = 150,
    this.wrapListTile,
  });

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
              listTileCount: widget.listTileCount,
              wrapListTile: widget.wrapListTile,
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Preempt for 60FPS')),
        body: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
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
  final int listTileCount;
  final WidgetWrapper? wrapListTile;

  const SecondPage({
    super.key,
    required this.pageLoadRecorder,
    required this.onTapBack,
    required this.listTileCount,
    required this.wrapListTile,
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
      debugShowCheckedModeBanner: false,
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
        body: firstFrame
            ? Container()
            : ComplexWidget(
                listTileCount: widget.listTileCount,
                wrapListTile: widget.wrapListTile,
              ),
      ),
    );
  }
}
