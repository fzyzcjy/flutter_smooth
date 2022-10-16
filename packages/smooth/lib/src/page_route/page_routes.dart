import 'package:flutter/material.dart';
import 'package:smooth/src/builder.dart';

class SmoothPageRouteBuilder<T> extends PageRouteBuilder<T> {
  SmoothPageRouteBuilder({
    // just copy from [PageRouteBuilder] constructor
    super.settings,
    required super.pageBuilder,
    required super.transitionsBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 300),
    super.opaque = true,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });

  // NOTE mimic [TransitionRoute.createAnimationController], but change vsync
  @override
  AnimationController createAnimationController() {
    final duration = transitionDuration;
    final reverseDuration = reverseTransitionDuration;
    assert(duration >= Duration.zero);
    return AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      // NOTE MODIFIED changed this vsync
      vsync: TODO,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SmoothBuilder(
      builder: (context, child) {
        return transitionsBuilder(
            context, animation, secondaryAnimation, child);
      },
      child: child,
    );
  }
}
