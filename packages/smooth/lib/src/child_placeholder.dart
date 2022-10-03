import 'package:flutter/material.dart';
import 'package:smooth/src/graft/adapter_in_auxiliary_tree.dart';

class SmoothChildPlaceholder extends StatelessWidget {
  final Object slot;

  const SmoothChildPlaceholder({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    return AdapterInAuxiliaryTree(slot: slot);
  }
}
