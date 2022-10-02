import 'package:flutter/material.dart';

// TODO merge with classical [SmoothBuilder]
class SmoothMultiChildBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const SmoothMultiChildBuilder({super.key, required this.builder});

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

class SmoothChild extends StatelessWidget {
  final Widget child;

  const SmoothChild({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TODO;
  }
}
