import 'package:flutter/material.dart';
import 'package:smooth/src/graft/adapter_in_auxiliary_tree.dart';

class SmoothChildPlaceholder<S extends Object> extends StatelessWidget {
  final S slot;

  const SmoothChildPlaceholder({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    return GraftAdapterInAuxiliaryTree(slot: slot);
  }
}
