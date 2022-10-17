import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/drop_in/list_view/physics.dart';
import 'package:smooth/src/drop_in/list_view/simulation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothClampingScrollPhysics', () {
    FixedScrollMetrics _createScrollMetrics({required double pixels}) =>
        FixedScrollMetrics(
          pixels: pixels,
          minScrollExtent: 0,
          maxScrollExtent: 10000,
          viewportDimension: 1000,
          axisDirection: AxisDirection.down,
        );

    test('simple', () {
      const physics = SmoothClampingScrollPhysics();

      final first = physics.createBallisticSimulationEnhanced(
        _createScrollMetrics(pixels: 100),
        1200,
        previous: null,
        potentialTimeShiftFromPrevious: 0,
      )!;

      const deltaTime = 0.5;

      final second = physics.createBallisticSimulationEnhanced(
        _createScrollMetrics(pixels: first.x(deltaTime)),
        first.dx(deltaTime),
        previous: first,
        potentialTimeShiftFromPrevious: deltaTime,
      )!;

      expect(
        second,
        isA<ShiftingSimulation>()
            .having((p) => p.inner, 'inner', first)
            .having((p) => p.timeShift, 'timeShift', deltaTime)
            .having((p) => p.positionShift, 'positionShift', 0),
      );

      final third = physics.createBallisticSimulationEnhanced(
        _createScrollMetrics(pixels: second.x(deltaTime)),
        second.dx(deltaTime),
        previous: second,
        potentialTimeShiftFromPrevious: deltaTime,
      )!;

      expect(
        third,
        isA<ShiftingSimulation>()
            .having((p) => p.inner, 'inner', first)
            .having((p) => p.timeShift, 'timeShift', deltaTime * 2)
            .having((p) => p.positionShift, 'positionShift', 0),
      );
    });
  });
}
