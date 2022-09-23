import 'package:flutter/material.dart';

const _kDuration = Duration(milliseconds: 1000);
const _kCurve = Curves.linear;

class EnterPageAnimation extends StatelessWidget {
  final bool visible;
  final Widget child;

  const EnterPageAnimation({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return _EnterPageAnimationSlow(child: child);
  }
}

class _EnterPageAnimationSlow extends StatefulWidget {
  final Widget child;

  const _EnterPageAnimationSlow({required this.child});

  @override
  State<_EnterPageAnimationSlow> createState() =>
      _EnterPageAnimationSlowState();
}

class _EnterPageAnimationSlowState extends State<_EnterPageAnimationSlow>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(duration: _kDuration, vsync: this);
  late final _offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0), end: const Offset(0, 0))
      .animate(CurvedAnimation(parent: _controller, curve: _kCurve));

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
    print('hi ${_offsetAnimation.value}');
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
