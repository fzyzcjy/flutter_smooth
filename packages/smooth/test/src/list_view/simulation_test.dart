import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/drop_in/list_view/simulation.dart';

void main() {
  group('ShiftingSimulation', () {
    test('simple', () {
      final inner = ClampingScrollSimulation(position: 100, velocity: 1200);
      final outer =
          ShiftingSimulation(inner, timeShift: 0.5, positionShift: 10000);

      expect(outer.x(-0.5), inner.x(0) + 10000);
      expect(outer.x(0), inner.x(0.5) + 10000);
      expect(outer.x(0.1), inner.x(0.6) + 10000);
      expect(outer.x(10), inner.x(10.5) + 10000);

      expect(outer.dx(-0.5), inner.dx(0));
      expect(outer.dx(0), inner.dx(0.5));
      expect(outer.dx(0.1), inner.dx(0.6));
      expect(outer.dx(10), inner.dx(10.5));

      expect(outer.isDone(-0.5), inner.isDone(0));
      expect(outer.isDone(0), inner.isDone(0.5));
      expect(outer.isDone(0.1), inner.isDone(0.6));
      expect(outer.isDone(10), inner.isDone(10.5));
    });
  });
}
