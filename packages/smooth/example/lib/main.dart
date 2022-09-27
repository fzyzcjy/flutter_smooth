// ignore_for_file: avoid_print

import 'package:example/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

void main() {
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Mode? mode;
  var debug = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _dummyWaiter();
  // }

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
              mode: mode,
              onTapBack: () {
                setState(() => mode = null);
                SmoothDebug.debugPrintStat();
              },
            ),
          ),
          if (debug)
            const Center(
              child: RepaintBoundary(
                child: DebugSmallAnimation(),
              ),
            )
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
              for (final targetMode in Mode.values)
                TextButton(
                  onPressed: () => setState(() => mode = targetMode),
                  child: Text('mode=${targetMode.name}'),
                ),
              TextButton(
                onPressed: () => setState(() => debug = !debug),
                child: const Text('debug'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

var pageLoadTimesOfMode = <Mode, List<Duration>>{};

class SecondPage extends StatefulWidget {
  final Mode? mode;
  final VoidCallback onTapBack;

  const SecondPage({super.key, required this.mode, required this.onTapBack});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  var firstFrame = true;
  late final DateTime initStateTime;

  @override
  void initState() {
    super.initState();
    initStateTime = DateTime.now();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() => firstFrame = false);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        final loadTime = now.difference(initStateTime);
        (pageLoadTimesOfMode[widget.mode!] ??= []).add(loadTime);
        print('SecondPage render this-time-loadTime=$loadTime '
            'slow_all=${pageLoadTimesOfMode[Mode.slowByAnimation]?.map((e) => e.inMicroseconds / 1000).toList()}; '
            'fast_all=${pageLoadTimesOfMode[Mode.fastByAnimation]?.map((e) => e.inMicroseconds / 1000).toList()}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // do not let semantics confuse the metrics. b/c we are having a huge
    // amount of text in this demo, while in realworld never has that
    return ExcludeSemantics(
      child: MaterialApp(
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
          body: firstFrame ? Container() : const ComplexWidget(),
        ),
      ),
    );
  }
}

class ComplexWidget extends StatelessWidget {
  const ComplexWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // const N = 30;
    // const N = 60; // make it big to see jank clearly
    const N = 150; // make it big to see jank clearly
    // const N = 1000; // for debug

    // const textRepeat = 5;
    const textRepeat = 1;

    // @dnfield's suggestion - a lot of text
    // https://github.com/flutter/flutter/issues/101227#issuecomment-1247641562
    return Material(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: Column(
          children: List<Widget>.generate(N, (int index) {
            return SizedBox(
              height: 12,
              // NOTE hack, in real world should auto have preempt point
              // but in prototype we do it by hand
              child: SmoothPreemptPoint(
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircleAvatar(
                      child: Text('G$index'),
                    ),
                  ),
                  title: Text(
                    'Foo contact from $index-th local contact' * textRepeat,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 5),
                  ),
                  subtitle: Text('+91 88888 8800$index'),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class DebugSmallAnimation extends StatefulWidget {
  const DebugSmallAnimation({super.key});

  @override
  State<DebugSmallAnimation> createState() => _DebugSmallAnimationState();
}

class _DebugSmallAnimationState extends State<DebugSmallAnimation> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    count++;
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
    return Text(
      '${count.toString().padRight(10)} ${DateTime.now()}',
      style: const TextStyle(fontSize: 30, color: Colors.black),
    );
  }
}

// void _dummyWaiter() {
//   SchedulerBinding.instance.addPostFrameCallback((_) {
//     print('dummyWaiter start');
//     sleep(const Duration(seconds: 3));
//     print('dummyWaiter end');
//
//     _dummyWaiter();
//   });
// }
//
