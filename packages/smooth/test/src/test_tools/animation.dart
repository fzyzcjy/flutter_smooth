import 'package:flutter/material.dart';

class SimpleAnimatedBuilder extends StatefulWidget {
  final Duration duration;
  final Widget Function(BuildContext, double animationValue) builder;

  const SimpleAnimatedBuilder({
    super.key,
    required this.duration,
    required this.builder,
  });

  @override
  State<SimpleAnimatedBuilder> createState() => _SimpleAnimatedBuilderState();
}

class _SimpleAnimatedBuilderState extends State<SimpleAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late final controller =
      AnimationController(duration: widget.duration, vsync: this);

  @override
  void initState() {
    super.initState();
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant SimpleAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.duration == widget.duration,
        '$runtimeType does not allow change `duration` since it is a very simple test tool');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => widget.builder(context, controller.value),
    );
  }
}
