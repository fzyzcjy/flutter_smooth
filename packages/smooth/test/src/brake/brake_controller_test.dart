import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/infra/brake/brake_controller.dart';

void main() {
  group('BrakeController', () {
    testWidgets('simple', (tester) async {
      final controller = BrakeController();

      await tester.pumpWidget(const CircularProgressIndicator());

      expect(controller.brakeModeActive, false);

      controller.activateBrakeMode();
      expect(controller.brakeModeActive, true);

      controller.activateBrakeMode();
      expect(controller.brakeModeActive, true);

      await tester.pump();

      expect(controller.brakeModeActive, false,
          reason: 'auto become false after a frame');

      controller.activateBrakeMode();
      expect(controller.brakeModeActive, true);
    });
  });
}
