import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/animation_controller.dart';
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

  Ticker? _secondaryAnimationControllerTicker;

  // NOTE mimic [TransitionRoute.createAnimationController], but change vsync
  @override
  AnimationController createAnimationController() {
    final duration = transitionDuration;
    final reverseDuration = reverseTransitionDuration;
    assert(duration >= Duration.zero);

    late final Ticker secondaryCreatedTicker;

    final result = DualProxyAnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      vsync: navigator!,
      // NOTE
      vsyncForSecondary: LambdaTickerProvider((onTick) {
        secondaryCreatedTicker = navigator!.createTicker(onTick);
        return secondaryCreatedTicker;
      }),
    );

    _secondaryAnimationControllerTicker = secondaryCreatedTicker;

    return result;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SmoothBuilder(
      wantSmoothTickTickers: [_secondaryAnimationControllerTicker!],
      builder: (context, child) {
        return transitionsBuilder(
            context, animation, secondaryAnimation, child);
      },
      child: child,
    );
  }
}
