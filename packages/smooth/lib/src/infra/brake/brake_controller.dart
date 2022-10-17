import 'dart:developer';

import 'package:flutter/scheduler.dart';

class BrakeController {
  bool get brakeModeActive => _brakeModeActive;
  bool _brakeModeActive = false;

  // TODO correct?
  final _task = TimelineTask();

  void activateBrakeMode() {
    if (_brakeModeActive) return;

    _task.start('BrakeMode');
    _brakeModeActive = true;
    // print('BrakeController.activateBrakeMode');

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _deactivateBrakeMode();
    });
  }

  void _deactivateBrakeMode() {
    if (!_brakeModeActive) return;

    _task.finish();
    _brakeModeActive = false;
    // print('BrakeController.deactivateBrakeMode');
  }
}
