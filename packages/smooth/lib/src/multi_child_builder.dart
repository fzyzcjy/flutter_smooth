import 'package:flutter/material.dart';

// TODO merge with classical [SmoothBuilder]
class SmoothMultiChildBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) smoothBuilder;
  final Widget Function(BuildContext context, Object slot) childBuilder;

  const SmoothMultiChildBuilder({
    super.key,
    required this.smoothBuilder,
    required this.childBuilder,
  });

  @override
  State<SmoothMultiChildBuilder> createState() =>
      _SmoothMultiChildBuilderState();
}

class _SmoothMultiChildBuilderState extends State<SmoothMultiChildBuilder> {
  @override
  Widget build(BuildContext context) {
    return TODO;
  }
}

class SmoothChildPlaceholder extends StatelessWidget {
  final Object slot;

  const SmoothChildPlaceholder({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    return TODO;
  }
}
