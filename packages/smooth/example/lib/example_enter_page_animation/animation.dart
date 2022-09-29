// ignore_for_file: avoid_print

import 'package:example/utils/auto_start_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

const _kDuration = Duration(milliseconds: 300);

enum EnterPageAnimationMode {
  smooth,
  plain,
}

class EnterPageAnimation extends StatelessWidget {
  final EnterPageAnimationMode? mode;
  final Widget child;

  const EnterPageAnimation({
    super.key,
    required this.mode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case EnterPageAnimationMode.plain:
        return AutoStartSlideTransition(
          duration: _kDuration,
          child: child,
        );
      case EnterPageAnimationMode.smooth:
        // NOTE just add this [SmoothBuilder], and nothing more
        return SmoothBuilder(
          builder: (_, child) => AutoStartSlideTransition(
            duration: _kDuration,
            child: child,
          ),
          child: child,
        );
      case null:
        return const SizedBox();
    }
  }
}
