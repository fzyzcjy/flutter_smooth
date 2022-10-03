import 'package:flutter/material.dart';

class MaybeChildController {
  MaybeChildController({required bool initialEnable})
      : _enable = ValueNotifier(initialEnable);

  bool get enable => _enable.value;
  final ValueNotifier<bool> _enable;

  set enable(bool value) => _enable.value = value;
}

class MaybeChild extends StatefulWidget {
  final MaybeChildController controller;
  final Widget child;

  const MaybeChild({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<MaybeChild> createState() => _MaybeChildState();
}

class _MaybeChildState extends State<MaybeChild> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller._enable,
      builder: (_, enable, __) => enable ? widget.child : const SizedBox(),
    );
  }
}
