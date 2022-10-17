import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/drop_in/list_view/controller.dart';
import 'package:smooth/src/infra/animation_controller.dart';
import 'package:smooth/src/infra/builder.dart';

mixin SmoothPageRouteMixin<T> on PageRoute<T> {
  DualProxyAnimationController? _dualProxyAnimationController;
  Ticker? _secondaryAnimationControllerTicker;

  AnimationController? get _partialWriteOnlySecondaryAnimationController =>
      _dualProxyAnimationController!.partialWriteOnlySecondary;

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

    _dualProxyAnimationController = result;
    _secondaryAnimationControllerTicker = secondaryCreatedTicker;

    return result;
  }

  @override
  Widget buildTransitions(
      BuildContext mainTreeContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return SmoothBuilder(
      wantSmoothTickTickers: [_secondaryAnimationControllerTicker!],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(mainTreeContext),
        child: AnimatedBuilder(
          // NOTE use this secondary, not primary
          animation: _partialWriteOnlySecondaryAnimationController!,
          builder: (context, _) {
            // print('hi SmoothBuilder.AnimatedBuilder.builder '
            //     'value=${_partialWriteOnlySecondaryAnimationController?.value} '
            //     '_partialWriteOnlySecondaryAnimationController=${describeIdentity(_partialWriteOnlySecondaryAnimationController)} $_partialWriteOnlySecondaryAnimationController');
            return super.buildTransitions(
              context,
              // TODO improve this (e.g. handle offstage)
              _partialWriteOnlySecondaryAnimationController!,
              // TODO handle secondaryAnimation, not done yet
              secondaryAnimation,
              child,
            );
          },
        ),
      ),
      child: child,
    );
  }
}

class SmoothPageRouteBuilder<T> extends PageRouteBuilder<T>
    with SmoothPageRouteMixin<T> {
  // just copy from [PageRouteBuilder] constructor
  SmoothPageRouteBuilder({
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
}

// ref [MaterialPageRoute], only add a mixin
class SmoothMaterialPageRoute<T> extends MaterialPageRoute<T>
    with SmoothPageRouteMixin<T> {
  SmoothMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    // super.allowSnapshotting = true,
  }) : super(
          // https://github.com/fzyzcjy/flutter_smooth/issues/127#issuecomment-1279978263
          allowSnapshotting: false,
        );
}
