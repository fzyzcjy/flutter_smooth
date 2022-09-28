import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class ProxyTestWindow implements TestWindow {
  final TestWindow _inner;

  const ProxyTestWindow(this._inner);

  @override
  TestPlatformDispatcher get platformDispatcher => _inner.platformDispatcher;

  @override
  double get devicePixelRatio => _inner.devicePixelRatio;

  @override
  set devicePixelRatioTestValue(double devicePixelRatio) =>
      _inner.devicePixelRatioTestValue = devicePixelRatio;

  @override
  void clearDevicePixelRatioTestValue() =>
      _inner.clearDevicePixelRatioTestValue();

  @override
  ui.Size get physicalSize => _inner.physicalSize;

  @override
  set physicalSizeTestValue(ui.Size physicalSizeTestValue) =>
      _inner.physicalSizeTestValue = physicalSizeTestValue;

  @override
  void clearPhysicalSizeTestValue() => _inner.clearPhysicalSizeTestValue();

  @override
  ui.WindowPadding get viewInsets => _inner.viewInsets;

  @override
  set viewInsetsTestValue(ui.WindowPadding viewInsetsTestValue) =>
      _inner.viewInsetsTestValue = viewInsetsTestValue;

  @override
  void clearViewInsetsTestValue() => _inner.clearViewInsetsTestValue();

  @override
  ui.WindowPadding get viewPadding => _inner.viewPadding;

  @override
  set viewPaddingTestValue(ui.WindowPadding viewPaddingTestValue) =>
      _inner.viewPaddingTestValue = viewPaddingTestValue;

  @override
  void clearViewPaddingTestValue() => _inner.clearViewPaddingTestValue();

  @override
  ui.WindowPadding get padding => _inner.padding;

  @override
  set paddingTestValue(ui.WindowPadding paddingTestValue) =>
      _inner.paddingTestValue = paddingTestValue;

  @override
  void clearPaddingTestValue() => _inner.clearPaddingTestValue();

  @override
  List<ui.DisplayFeature> get displayFeatures => _inner.displayFeatures;

  @override
  set displayFeaturesTestValue(
      List<ui.DisplayFeature> displayFeaturesTestValue) =>
      _inner.displayFeaturesTestValue = displayFeaturesTestValue;

  @override
  void clearDisplayFeaturesTestValue() =>
      _inner.clearDisplayFeaturesTestValue();

  @override
  ui.WindowPadding get systemGestureInsets => _inner.systemGestureInsets;

  @override
  set systemGestureInsetsTestValue(
      ui.WindowPadding systemGestureInsetsTestValue) =>
      _inner.systemGestureInsetsTestValue = systemGestureInsetsTestValue;

  @override
  void clearSystemGestureInsetsTestValue() =>
      _inner.clearSystemGestureInsetsTestValue();

  @override
  ui.VoidCallback? get onMetricsChanged => _inner.onMetricsChanged;

  @override
  set onMetricsChanged(ui.VoidCallback? callback) =>
      _inner.onMetricsChanged = onMetricsChanged;

  @override
  ui.Locale get locale => _inner.locale;

  @override
  set localeTestValue(ui.Locale localeTestValue) =>
      // ignore: deprecated_member_use
  _inner.localeTestValue = localeTestValue;

  @override
  // ignore: deprecated_member_use
  void clearLocaleTestValue() => _inner.clearLocaleTestValue();

  @override
  List<ui.Locale> get locales => _inner.locales;

  @override
  set localesTestValue(List<ui.Locale> localesTestValue) =>
      // ignore: deprecated_member_use
  _inner.localesTestValue = localesTestValue;

  @override
  // ignore: deprecated_member_use
  void clearLocalesTestValue() => _inner.clearLocalesTestValue();

  @override
  ui.VoidCallback? get onLocaleChanged => _inner.onLocaleChanged;

  @override
  set onLocaleChanged(ui.VoidCallback? callback) =>
      _inner.onLocaleChanged = onLocaleChanged;

  @override
  String get initialLifecycleState => _inner.initialLifecycleState;

  @override
  set initialLifecycleStateTestValue(String state) =>
      // ignore: deprecated_member_use
  _inner.initialLifecycleStateTestValue = state;

  @override
  double get textScaleFactor => _inner.textScaleFactor;

  @override
  set textScaleFactorTestValue(double textScaleFactorTestValue) =>
      // ignore: deprecated_member_use
  _inner.textScaleFactorTestValue = textScaleFactorTestValue;

  @override
  void clearTextScaleFactorTestValue() =>
      // ignore: deprecated_member_use
  _inner.clearTextScaleFactorTestValue();

  @override
  ui.Brightness get platformBrightness => _inner.platformBrightness;

  @override
  ui.VoidCallback? get onPlatformBrightnessChanged =>
      _inner.onPlatformBrightnessChanged;

  @override
  set onPlatformBrightnessChanged(ui.VoidCallback? callback) =>
      _inner.onPlatformBrightnessChanged = onPlatformBrightnessChanged;

  @override
  set platformBrightnessTestValue(ui.Brightness platformBrightnessTestValue) =>
      // ignore: deprecated_member_use
  _inner.platformBrightnessTestValue = platformBrightnessTestValue;

  @override
  void clearPlatformBrightnessTestValue() =>
      // ignore: deprecated_member_use
  _inner.clearPlatformBrightnessTestValue();

  @override
  bool get alwaysUse24HourFormat => _inner.alwaysUse24HourFormat;

  @override
  set alwaysUse24HourFormatTestValue(bool alwaysUse24HourFormatTestValue) =>
      // ignore: deprecated_member_use
  _inner.alwaysUse24HourFormatTestValue = alwaysUse24HourFormatTestValue;

  @override
  void clearAlwaysUse24HourTestValue() =>
      // ignore: deprecated_member_use
  _inner.clearAlwaysUse24HourTestValue();

  @override
  ui.VoidCallback? get onTextScaleFactorChanged =>
      _inner.onTextScaleFactorChanged;

  @override
  set onTextScaleFactorChanged(ui.VoidCallback? callback) =>
      _inner.onTextScaleFactorChanged = onTextScaleFactorChanged;

  @override
  bool get nativeSpellCheckServiceDefined =>
      _inner.nativeSpellCheckServiceDefined;

  @override
  set nativeSpellCheckServiceDefinedTestValue(
      bool nativeSpellCheckServiceDefinedTestValue) =>
      _inner.nativeSpellCheckServiceDefinedTestValue =
          nativeSpellCheckServiceDefinedTestValue;

  @override
  bool get brieflyShowPassword => _inner.brieflyShowPassword;

  @override
  set brieflyShowPasswordTestValue(bool brieflyShowPasswordTestValue) =>
      // ignore: deprecated_member_use
  _inner.brieflyShowPasswordTestValue = brieflyShowPasswordTestValue;

  @override
  ui.FrameCallback? get onBeginFrame => _inner.onBeginFrame;

  @override
  set onBeginFrame(ui.FrameCallback? callback) =>
      _inner.onBeginFrame = onBeginFrame;

  @override
  ui.VoidCallback? get onDrawFrame => _inner.onDrawFrame;

  @override
  set onDrawFrame(ui.VoidCallback? callback) =>
      _inner.onDrawFrame = onDrawFrame;

  @override
  ui.TimingsCallback? get onReportTimings => _inner.onReportTimings;

  @override
  set onReportTimings(ui.TimingsCallback? callback) =>
      _inner.onReportTimings = onReportTimings;

  @override
  ui.PointerDataPacketCallback? get onPointerDataPacket =>
      _inner.onPointerDataPacket;

  @override
  set onPointerDataPacket(ui.PointerDataPacketCallback? callback) =>
      _inner.onPointerDataPacket = onPointerDataPacket;

  @override
  String get defaultRouteName => _inner.defaultRouteName;

  @override
  set defaultRouteNameTestValue(String defaultRouteNameTestValue) =>
      // ignore: deprecated_member_use
  _inner.defaultRouteNameTestValue = defaultRouteNameTestValue;

  @override
  void clearDefaultRouteNameTestValue() =>
      // ignore: deprecated_member_use
  _inner.clearDefaultRouteNameTestValue();

  @override
  void scheduleFrame() => _inner.scheduleFrame();

  @override
  void render(ui.Scene scene) => _inner.render(scene);

  @override
  bool get semanticsEnabled => _inner.semanticsEnabled;

  @override
  set semanticsEnabledTestValue(bool semanticsEnabledTestValue) =>
      // ignore: deprecated_member_use
  _inner.semanticsEnabledTestValue = semanticsEnabledTestValue;

  @override
  void clearSemanticsEnabledTestValue() =>
      // ignore: deprecated_member_use
  _inner.clearSemanticsEnabledTestValue();

  @override
  ui.VoidCallback? get onSemanticsEnabledChanged =>
      _inner.onSemanticsEnabledChanged;

  @override
  set onSemanticsEnabledChanged(ui.VoidCallback? callback) =>
      _inner.onSemanticsEnabledChanged = onSemanticsEnabledChanged;

  @override
  ui.SemanticsActionCallback? get onSemanticsAction => _inner.onSemanticsAction;

  @override
  set onSemanticsAction(ui.SemanticsActionCallback? callback) =>
      _inner.onSemanticsAction = onSemanticsAction;

  @override
  ui.AccessibilityFeatures get accessibilityFeatures =>
      _inner.accessibilityFeatures;

  @override
  set accessibilityFeaturesTestValue(
      ui.AccessibilityFeatures accessibilityFeaturesTestValue) =>
      // ignore: deprecated_member_use
  _inner.accessibilityFeaturesTestValue = accessibilityFeaturesTestValue;

  @override
  void clearAccessibilityFeaturesTestValue() =>
      // ignore: deprecated_member_use
  _inner.clearAccessibilityFeaturesTestValue();

  @override
  ui.ViewConfiguration get viewConfiguration => _inner.viewConfiguration;

  @override
  set viewConfigurationTestValue(ui.ViewConfiguration? value) =>
      _inner.viewConfigurationTestValue = value;

  @override
  ui.VoidCallback? get onAccessibilityFeaturesChanged =>
      _inner.onAccessibilityFeaturesChanged;

  @override
  set onAccessibilityFeaturesChanged(ui.VoidCallback? callback) =>
      _inner.onAccessibilityFeaturesChanged = onAccessibilityFeaturesChanged;

  @override
  void updateSemantics(ui.SemanticsUpdate update) =>
      _inner.updateSemantics(update);

  @override
  void setIsolateDebugName(String name) => _inner.setIsolateDebugName(name);

  @override
  void sendPlatformMessage(String name, ByteData? data,
      ui.PlatformMessageResponseCallback? callback) =>
      _inner.sendPlatformMessage(name, data, callback);

  @override
  // ignore: deprecated_member_use
  ui.PlatformMessageCallback? get onPlatformMessage => _inner.onPlatformMessage;

  @override
  set onPlatformMessage(ui.PlatformMessageCallback? callback) =>
      // ignore: deprecated_member_use
  _inner.onPlatformMessage = onPlatformMessage;

  @override
  // ignore: deprecated_member_use
  void clearAllTestValues() => _inner.clearAllTestValues();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      _inner.noSuchMethod(invocation);
}
