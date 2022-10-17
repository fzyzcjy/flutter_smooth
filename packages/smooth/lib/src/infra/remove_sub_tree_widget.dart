import 'package:flutter/material.dart';

class RemoveSubTreeController {
  final _removeSubTree = ValueNotifier<bool>(false);

  void markRemoveSubTree() => _removeSubTree.value = true;
}

class RemoveSubTreeWidget extends StatefulWidget {
  final RemoveSubTreeController controller;
  final Widget child;

  const RemoveSubTreeWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<RemoveSubTreeWidget> createState() => _RemoveSubTreeWidgetState();
}

class _RemoveSubTreeWidgetState extends State<RemoveSubTreeWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller._removeSubTree,
      builder: (_, removeSubTree, __) =>
          removeSubTree ? const SizedBox() : widget.child,
    );
  }
}
