import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/builder.dart';
import 'package:smooth/src/list_view/controller.dart';

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

  Ticker? _animationControllerTicker;

  // NOTE mimic [TransitionRoute.createAnimationController], but change vsync
  @override
  AnimationController createAnimationController() {
    final duration = transitionDuration;
    final reverseDuration = reverseTransitionDuration;
    assert(duration >= Duration.zero);

    late final Ticker createdTicker;

    final result = AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      // NOTE MODIFIED changed this vsync
      // vsync: navigator!,
      vsync: LambdaTickerProvider((onTick) {
        createdTicker = navigator!.createTicker(onTick);
        return createdTicker;
      }),
    );

    _animationControllerTicker = createdTicker;

    return result;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SmoothBuilder(
      wantSmoothTickTickers: [_animationControllerTicker!],
      builder: (context, child) {
        return transitionsBuilder(
            context, animation, secondaryAnimation, child);
      },
      child: child,
    );
  }
}
