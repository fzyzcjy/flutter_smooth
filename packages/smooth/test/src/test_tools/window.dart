import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

extension ExtTestWindow on TestWindow {
  void setUpTearDown({
    Size? physicalSizeTestValue,
    double? devicePixelRatioTestValue,
  }) {
    autoSetUpTearDownOrAddTearDownSync(
      () {
        if (physicalSizeTestValue != null) {
          this.physicalSizeTestValue = physicalSizeTestValue;
        }
        if (devicePixelRatioTestValue != null) {
          this.devicePixelRatioTestValue = devicePixelRatioTestValue;
        }
      },
      () {
        if (physicalSizeTestValue != null) clearPhysicalSizeTestValue();
        if (devicePixelRatioTestValue != null) clearDevicePixelRatioTestValue();
      },
    );
  }
}

void autoSetUpTearDownOrAddTearDownSync(
  void Function() setUpBody,
  void Function() tearDownBody,
) {
  // ref: test_api :: test_structure.dart :: addTearDown source code
  if (Invoker.current == null) {
    setUp(setUpBody);
    tearDown(tearDownBody);
  } else {
    setUpBody();
    addTearDown(tearDownBody);
  }
}
