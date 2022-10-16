import 'package:flutter/material.dart';

class ProxyAnimationController implements AnimationController {
  final AnimationController inner;

  ProxyAnimationController({
    double? value,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    required TickerProvider vsync,
  }) : inner = AnimationController(
          value: value,
          duration: duration,
          reverseDuration: reverseDuration,
          debugLabel: debugLabel,
          lowerBound: lowerBound,
          upperBound: upperBound,
          animationBehavior: animationBehavior,
          vsync: vsync,
        );

  @override
  double get lowerBound => inner.lowerBound;

  @override
  double get upperBound => inner.upperBound;

  @override
  String? get debugLabel => inner.debugLabel;

  @override
  AnimationBehavior get animationBehavior => inner.animationBehavior;

  @override
  Animation<double> get view => inner.view;

  @override
  Duration? get duration => inner.duration;

  @override
  set duration(Duration? value) => inner.duration = value;

  @override
  Duration? get reverseDuration => inner.reverseDuration;

  @override
  set reverseDuration(Duration? value) => inner.reverseDuration = value;

  @override
  void resync(TickerProvider vsync) => inner.resync(vsync);

  @override
  double get value => inner.value;

  @override
  set value(double newValue) => inner.value = newValue;

  @override
  void reset() => inner.reset();

  @override
  double get velocity => inner.velocity;

  @override
  Duration? get lastElapsedDuration => inner.lastElapsedDuration;

  @override
  bool get isAnimating => inner.isAnimating;

  @override
  AnimationStatus get status => inner.status;

  @override
  TickerFuture forward({double? from}) => inner.forward(from: from);

  @override
  TickerFuture reverse({double? from}) => inner.reverse(from: from);

  @override
  TickerFuture animateTo(double target,
          {Duration? duration, Curve curve = Curves.linear}) =>
      inner.animateTo(target, duration: duration, curve: curve);

  @override
  TickerFuture animateBack(double target,
          {Duration? duration, Curve curve = Curves.linear}) =>
      inner.animateBack(target, duration: duration, curve: curve);

  @override
  TickerFuture repeat(
          {double? min, double? max, bool reverse = false, Duration? period}) =>
      inner.repeat(min: min, max: max, reverse: reverse, period: period);

  @override
  TickerFuture fling(
          {double velocity = 1.0,
          SpringDescription? springDescription,
          AnimationBehavior? animationBehavior}) =>
      inner.fling(
          velocity: velocity,
          springDescription: springDescription,
          animationBehavior: animationBehavior);

  @override
  TickerFuture animateWith(Simulation simulation) =>
      inner.animateWith(simulation);

  @override
  void stop({bool canceled = true}) => inner.stop(canceled: canceled);

  @override
  void dispose() => inner.dispose();

  @override
  void addListener(VoidCallback listener) => inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => inner.removeListener(listener);

  @override
  void addStatusListener(AnimationStatusListener listener) =>
      inner.addStatusListener(listener);

  @override
  void removeStatusListener(AnimationStatusListener listener) =>
      inner.removeStatusListener(listener);

  @override
  Animation<U> drive<U>(Animatable<U> child) => inner.drive(child);

  @override
  bool get isCompleted => inner.isCompleted;

  @override
  bool get isDismissed => inner.isDismissed;

  @override
  String toStringDetails() => inner.toStringDetails();

  @override
  String toString() => 'ProxyAnimationController($inner)';

  @override
  void clearListeners() => _protectedMethod();

  @override
  void clearStatusListeners() => _protectedMethod();

  @override
  void didRegisterListener() => _protectedMethod();

  @override
  void didUnregisterListener() => _protectedMethod();

  @override
  void notifyListeners() => _protectedMethod();

  @override
  void notifyStatusListeners(AnimationStatus status) => _protectedMethod();

  Never _protectedMethod() => throw UnimplementedError(
      'This should be protected and not called externally');
}

class DualProxyAnimationController extends ProxyAnimationController {}
