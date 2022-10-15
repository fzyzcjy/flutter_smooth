import 'package:flutter/scheduler.dart';

class BrakeController {
  bool get brakeModeActive => _brakeModeActive;
  bool _brakeModeActive = false;

  void activateBrakeMode() {
    if (_brakeModeActive) return;

    _brakeModeActive = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _brakeModeActive = false;
    });
  }
}
