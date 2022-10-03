import 'package:flutter/material.dart';
import 'package:smooth/src/graft/builder.dart';

// TODO merge with classical [SmoothBuilder]
class SmoothMultiChildBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) smoothBuilder;
  final Widget Function(BuildContext context, Object slot) childBuilder;

  const SmoothMultiChildBuilder({
    super.key,
    required this.smoothBuilder,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GraftBuilder(
      auxiliaryTreeBuilder: smoothBuilder,
      mainTreeChildBuilder: childBuilder,
    );
  }
}
