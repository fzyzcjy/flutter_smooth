import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

class SmoothPoint extends StatelessWidget {
  final Widget child;

  const SmoothPoint({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SmoothBrakePoint(
      child: SmoothBuildPreemptPointWidget(
        child: SmoothLayoutPreemptPointWidget(
          child: child,
        ),
      ),
    );
  }
}
