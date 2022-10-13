import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

// ignore: implementation_imports
import 'package:smooth/src/proxy.dart';

class ProxyTestWindow extends ProxySingletonFlutterWindow
    implements TestWindow {
  @override
  TestWindow get inner => super.inner as TestWindow;

  const ProxyTestWindow(TestWindow super.inner);

  @override
  TestPlatformDispatcher get platformDispatcher => inner.platformDispatcher;

  @override
  set devicePixelRatioTestValue(double devicePixelRatio) =>
      inner.devicePixelRatioTestValue = devicePixelRatio;

  @override
  void clearDevicePixelRatioTestValue() =>
      inner.clearDevicePixelRatioTestValue();

  @override
  set physicalSizeTestValue(ui.Size physicalSizeTestValue) =>
      inner.physicalSizeTestValue = physicalSizeTestValue;

  @override
  void clearPhysicalSizeTestValue() => inner.clearPhysicalSizeTestValue();

  @override
  set viewInsetsTestValue(ui.WindowPadding viewInsetsTestValue) =>
      inner.viewInsetsTestValue = viewInsetsTestValue;

  @override
  void clearViewInsetsTestValue() => inner.clearViewInsetsTestValue();

  @override
  set viewPaddingTestValue(ui.WindowPadding viewPaddingTestValue) =>
      inner.viewPaddingTestValue = viewPaddingTestValue;

  @override
  void clearViewPaddingTestValue() => inner.clearViewPaddingTestValue();

  @override
  set paddingTestValue(ui.WindowPadding paddingTestValue) =>
      inner.paddingTestValue = paddingTestValue;

  @override
  void clearPaddingTestValue() => inner.clearPaddingTestValue();

  @override
  set displayFeaturesTestValue(
          List<ui.DisplayFeature> displayFeaturesTestValue) =>
      inner.displayFeaturesTestValue = displayFeaturesTestValue;

  @override
  void clearDisplayFeaturesTestValue() => inner.clearDisplayFeaturesTestValue();

  @override
  set systemGestureInsetsTestValue(
          ui.WindowPadding systemGestureInsetsTestValue) =>
      inner.systemGestureInsetsTestValue = systemGestureInsetsTestValue;

  @override
  void clearSystemGestureInsetsTestValue() =>
      inner.clearSystemGestureInsetsTestValue();

  @override
  set localeTestValue(ui.Locale localeTestValue) =>
      // ignore: deprecated_member_use
      inner.localeTestValue = localeTestValue;

  @override
  // ignore: deprecated_member_use
  void clearLocaleTestValue() => inner.clearLocaleTestValue();

  @override
  set localesTestValue(List<ui.Locale> localesTestValue) =>
      // ignore: deprecated_member_use
      inner.localesTestValue = localesTestValue;

  @override
  // ignore: deprecated_member_use
  void clearLocalesTestValue() => inner.clearLocalesTestValue();

  @override
  set initialLifecycleStateTestValue(String state) =>
      // ignore: deprecated_member_use
      inner.initialLifecycleStateTestValue = state;

  @override
  set textScaleFactorTestValue(double textScaleFactorTestValue) =>
      // ignore: deprecated_member_use
      inner.textScaleFactorTestValue = textScaleFactorTestValue;

  @override
  void clearTextScaleFactorTestValue() =>
      // ignore: deprecated_member_use
      inner.clearTextScaleFactorTestValue();

  @override
  set platformBrightnessTestValue(ui.Brightness platformBrightnessTestValue) =>
      // ignore: deprecated_member_use
      inner.platformBrightnessTestValue = platformBrightnessTestValue;

  @override
  void clearPlatformBrightnessTestValue() =>
      // ignore: deprecated_member_use
      inner.clearPlatformBrightnessTestValue();

  @override
  set alwaysUse24HourFormatTestValue(bool alwaysUse24HourFormatTestValue) =>
      // ignore: deprecated_member_use
      inner.alwaysUse24HourFormatTestValue = alwaysUse24HourFormatTestValue;

  @override
  void clearAlwaysUse24HourTestValue() =>
      // ignore: deprecated_member_use
      inner.clearAlwaysUse24HourTestValue();

  @override
  set nativeSpellCheckServiceDefinedTestValue(
          bool nativeSpellCheckServiceDefinedTestValue) =>
      inner.nativeSpellCheckServiceDefinedTestValue =
          nativeSpellCheckServiceDefinedTestValue;

  @override
  set brieflyShowPasswordTestValue(bool brieflyShowPasswordTestValue) =>
      // ignore: deprecated_member_use
      inner.brieflyShowPasswordTestValue = brieflyShowPasswordTestValue;

  @override
  set defaultRouteNameTestValue(String defaultRouteNameTestValue) =>
      // ignore: deprecated_member_use
      inner.defaultRouteNameTestValue = defaultRouteNameTestValue;

  @override
  void clearDefaultRouteNameTestValue() =>
      // ignore: deprecated_member_use
      inner.clearDefaultRouteNameTestValue();

  @override
  set semanticsEnabledTestValue(bool semanticsEnabledTestValue) =>
      // ignore: deprecated_member_use
      inner.semanticsEnabledTestValue = semanticsEnabledTestValue;

  @override
  void clearSemanticsEnabledTestValue() =>
      // ignore: deprecated_member_use
      inner.clearSemanticsEnabledTestValue();

  @override
  set onSemanticsAction(ui.SemanticsActionCallback? callback) =>
      inner.onSemanticsAction = onSemanticsAction;

  @override
  set accessibilityFeaturesTestValue(
          ui.AccessibilityFeatures accessibilityFeaturesTestValue) =>
      // ignore: deprecated_member_use
      inner.accessibilityFeaturesTestValue = accessibilityFeaturesTestValue;

  @override
  void clearAccessibilityFeaturesTestValue() =>
      // ignore: deprecated_member_use
      inner.clearAccessibilityFeaturesTestValue();

  @override
  set viewConfigurationTestValue(ui.ViewConfiguration? value) =>
      inner.viewConfigurationTestValue = value;

  @override
  ui.VoidCallback? get onAccessibilityFeaturesChanged =>
      inner.onAccessibilityFeaturesChanged;

  @override
  set onAccessibilityFeaturesChanged(ui.VoidCallback? callback) =>
      inner.onAccessibilityFeaturesChanged = onAccessibilityFeaturesChanged;

  @override
  // ignore: deprecated_member_use
  void clearAllTestValues() => inner.clearAllTestValues();

  @override
  dynamic noSuchMethod(Invocation invocation) => inner.noSuchMethod(invocation);
}
