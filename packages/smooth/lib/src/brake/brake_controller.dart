import 'dart:developer';

import 'package:flutter/scheduler.dart';

class BrakeController {
  bool get brakeModeActive => _brakeModeActive;
  bool _brakeModeActive = false;

  void activateBrakeMode() {
    if (_brakeModeActive) return;

    Timeline.timeSync('activateBrakeMode', () {});

    _brakeModeActive = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _deactivateBrakeMode();
    });
  }

  void _deactivateBrakeMode() {
    if (!_brakeModeActive) return;

    Timeline.timeSync('deactivateBrakeMode', () {});

    _brakeModeActive = false;
  }
}
