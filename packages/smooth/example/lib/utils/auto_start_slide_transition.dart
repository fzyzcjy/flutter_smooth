import 'package:flutter/material.dart';

/// [SlideTransition], but auto start animation when init state
class AutoStartSlideTransition extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const AutoStartSlideTransition({
    super.key,
    required this.child,
    required this.duration,
  });

  @override
  State<AutoStartSlideTransition> createState() =>
      _AutoStartSlideTransitionState();
}

class _AutoStartSlideTransitionState extends State<AutoStartSlideTransition>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(duration: widget.duration, vsync: this);
  late final _offsetAnimation =
      Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(_controller);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AutoStartSlideTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.duration == oldWidget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}
