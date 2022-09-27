// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

const _kDuration = Duration(milliseconds: 300);
// const _kDuration = Duration(milliseconds: 1000);
// const _kDuration = Duration(milliseconds: 5000);

enum Mode {
  slowByAnimation,
  fastByAnimation,
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
      case Mode.fastByAnimation:
        return _EnterPageAnimationFastByAnimation(child: child);
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
      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
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
    // print('$runtimeType.build called');
    return PreemptBuilder(
      builder: (_, child) =>
          _EnterPageAnimationFastByAnimationInner(child: child),
      child: widget.child,
    );
  }
}

class _EnterPageAnimationFastByAnimationInner extends StatefulWidget {
  final Widget child;

  const _EnterPageAnimationFastByAnimationInner({required this.child});

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
      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
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

class Counter {
  var count = 0;

  void inc() => count++;

  Widget build() => Text(
        '${count.toString().padRight(10)} ${DateTime.now()}',
        style: const TextStyle(fontSize: 30, color: Colors.black),
      );
}

void printWrapped(String text) =>
    RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);
