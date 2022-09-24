// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:hello_package/demo/impl/preempt_builder.dart';

const _kDuration = Duration(milliseconds: 300);
// const _kDuration = Duration(milliseconds: 1000);
// const _kDuration = Duration(milliseconds: 5000);

enum Mode {
  slowByAnimation,
  slowByBuilder,
  fastByAnimation,
  fastByBuilder,
}

class EnterPageAnimation extends StatelessWidget {
  final Mode? mode;
  final Widget child;

  const EnterPageAnimation({
    super.key,
    required this.mode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case null:
        return const SizedBox();
      case Mode.slowByAnimation:
        return _EnterPageAnimationSlowByAnimation(child: child);
      case Mode.slowByBuilder:
        return _EnterPageAnimationSlowByBuilder(child: child);
      case Mode.fastByAnimation:
        return _EnterPageAnimationFastByAnimation(child: child);
      case Mode.fastByBuilder:
        return _EnterPageAnimationFastByBuilder(child: child);
    }
  }
}

class _EnterPageAnimationSlowByAnimation extends StatefulWidget {
  final Widget child;

  const _EnterPageAnimationSlowByAnimation({required this.child});

  @override
  State<_EnterPageAnimationSlowByAnimation> createState() =>
      _EnterPageAnimationSlowByAnimationState();
}

class _EnterPageAnimationSlowByAnimationState
    extends State<_EnterPageAnimationSlowByAnimation>
    with SingleTickerProviderStateMixin {
  final counter = Counter();
  late final _controller =
      AnimationController(duration: _kDuration, vsync: this);
  late final _offsetAnimation =
      Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
          .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    counter.inc();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          SlideTransition(
            position: _offsetAnimation,
            child: widget.child,
          ),
          Center(child: counter.build()),
        ],
      ),
    );
  }
}

class _EnterPageAnimationSlowByBuilder extends StatefulWidget {
  final Widget child;

  const _EnterPageAnimationSlowByBuilder({required this.child});

  @override
  State<_EnterPageAnimationSlowByBuilder> createState() =>
      _EnterPageAnimationSlowByBuilderState();
}

class _EnterPageAnimationSlowByBuilderState
    extends State<_EnterPageAnimationSlowByBuilder> {
  final counter = Counter();
  final animation = _SimpleAnimation();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      counter.inc();
      animation.init();
      final ratio = animation.computeRatio();

      if (ratio < 1) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          // print(
          //     '$runtimeType.build addPostFrameCallback callback call setState');
          setState(() {});
        });
      }

      return Stack(
        children: [
          Positioned(
            left: constraints.maxWidth * max(0, 1 - ratio),
            top: 0,
            bottom: 0,
            width: constraints.maxWidth,
            child: widget.child,
          ),
          Center(child: counter.build()),
        ],
      );
    });
  }
}

class _EnterPageAnimationFastByAnimation extends StatefulWidget {
  final Widget child;

  const _EnterPageAnimationFastByAnimation({required this.child});

  @override
  State<_EnterPageAnimationFastByAnimation> createState() =>
      _EnterPageAnimationFastByAnimationState();
}

class _EnterPageAnimationFastByAnimationState
    extends State<_EnterPageAnimationFastByAnimation> {
  @override
  Widget build(BuildContext context) {
    print('$runtimeType.build called');
    return PreemptBuilder(
      builder: (_, child) =>
          _EnterPageAnimationFastByAnimationInner(child: child),
      // builder: (_, child) {
      //   print('$runtimeType.PreemptBuilder.builder callback called');
      //   // return ColorFiltered(
      //   //   colorFilter: invertColorFilter,
      //   //   child: child,
      //   // );
      //   return Directionality(
      //     textDirection: TextDirection.ltr,
      //     child: Stack(
      //       children: [
      //         child,
      //         const Positioned.fill(
      //           child: Hello(
      //             child: RepaintBoundary(
      //               child: ColoredBox(color: Colors.green),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   );
      // },
      child: widget.child,
    );
  }
}

class Hello extends SingleChildRenderObjectWidget {
  const Hello({super.key, super.child});

  @override
  RenderHello createRenderObject(BuildContext context) => RenderHello();

  @override
  void updateRenderObject(BuildContext context, RenderHello renderObject) {}
}

class RenderHello extends RenderProxyBox {}

class _EnterPageAnimationFastByAnimationInner extends StatefulWidget {
  final Widget child;

  const _EnterPageAnimationFastByAnimationInner({Key? key, required this.child})
      : super(key: key);

  @override
  State<_EnterPageAnimationFastByAnimationInner> createState() =>
      _EnterPageAnimationFastByAnimationInnerState();
}

class _EnterPageAnimationFastByAnimationInnerState
    extends State<_EnterPageAnimationFastByAnimationInner>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(duration: _kDuration, vsync: this);
  late final _offsetAnimation =
      Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
          .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

  @override
  void initState() {
    super.initState();
    // print('${describeIdentity(this)} initState');
    _controller.forward();
  }

  @override
  void dispose() {
    // print('${describeIdentity(this)} dispose');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('${describeIdentity(this)} build');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}

class _EnterPageAnimationFastByBuilder extends StatefulWidget {
  final Widget child;

  const _EnterPageAnimationFastByBuilder({required this.child});

  @override
  State<_EnterPageAnimationFastByBuilder> createState() =>
      _EnterPageAnimationFastByBuilderState();
}

class _EnterPageAnimationFastByBuilderState
    extends State<_EnterPageAnimationFastByBuilder> {
  final counter = Counter();
  final animation = _SimpleAnimation();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => PreemptBuilder(
        builder: (_, child) {
          counter.inc();
          animation.init();
          final ratio = animation.computeRatio();
          print('$runtimeType PreemptBuilder.builder called ratio=$ratio');

          if (ratio < 1) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              // print(
              //     '$runtimeType.build addPostFrameCallback callback call setState');
              setState(() {});
            });
          }

          return Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                Positioned(
                  left: constraints.maxWidth * max(0, 1 - ratio),
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth,
                  child: child,
                ),
                Center(child: counter.build()),
                // Center(
                //   child: Container(
                //     width: 100,
                //     height: 100,
                //     color: Colors
                //         .primaries[ratio.hashCode % Colors.primaries.length],
                //   ),
                // ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

// hacky, just b/c it is prototype
// TODO use vsync, duration, etc
class _SimpleAnimation {
  DateTime? initialTime;

  void init() {
    initialTime ??= DateTime.now();
  }

  double computeRatio() {
    return DateTime.now().difference(initialTime!).inMicroseconds /
        _kDuration.inMicroseconds;
  }
}

class Counter {
  var count = 0;

  void inc() => count++;

  Widget build() => Text(
        '${count.toString().padRight(10)} ${DateTime.now()}',
        style: const TextStyle(fontSize: 30, color: Colors.black),
      );
}

// const invertColorFilter = ColorFilter.matrix(<double>[
//   -1,
//   0,
//   0,
//   0,
//   255,
//   0,
//   -1,
//   0,
//   0,
//   255,
//   0,
//   0,
//   -1,
//   0,
//   255,
//   0,
//   0,
//   0,
//   1,
//   0
// ]);

void printWrapped(String text) => RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);
