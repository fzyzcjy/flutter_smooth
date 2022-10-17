import 'package:flutter/material.dart';

class MemorizedSimulation extends ProxySimulation {
  MemorizedSimulation(super.inner);

  static MemorizedSimulation? wrap(Simulation? inner) =>
      inner == null ? null : MemorizedSimulation(inner);

  double? get lastX => _lastX;
  double? _lastX;

  double? get lastTime => _lastTime;
  double? _lastTime;

  @override
  double x(double time) {
    assert(_lastTime == null || time >= _lastTime!);

    final ans = super.x(time);

    _lastX = ans;
    _lastTime = time;

    return ans;
  }

  @override
  String toString() =>
      'MemorizedSimulation(lastX: $_lastX, lastTime: $_lastTime, inner: $inner)';
}

class ProxySimulation extends Simulation {
  final Simulation inner;

  ProxySimulation(this.inner);

  @override
  double x(double time) => inner.x(time);

  @override
  double dx(double time) => inner.dx(time);

  @override
  bool isDone(double time) => inner.isDone(time);

  @override
  String toString() => 'ProxySimulation($inner)';
}

class ShiftingSimulation extends Simulation {
  final Simulation inner;
  final double timeShift;
  final double positionShift;

  ShiftingSimulation(
    this.inner, {
    required this.timeShift,
    required this.positionShift,
  });

  @override
  double x(double time) => positionShift + inner.x(time + timeShift);

  @override
  double dx(double time) => inner.dx(time + timeShift);

  @override
  bool isDone(double time) => inner.isDone(time + timeShift);

  @override
  String toString() =>
      'ShiftingSimulation($inner, timeShift: $timeShift, positionShift: $positionShift)';
}
