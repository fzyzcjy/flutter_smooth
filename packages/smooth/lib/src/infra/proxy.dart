import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ProxyPipelineOwner implements PipelineOwner {
  final PipelineOwner inner;

  ProxyPipelineOwner(this.inner);

  @override
  VoidCallback? get onNeedVisualUpdate => inner.onNeedVisualUpdate;

  @override
  VoidCallback? get onSemanticsOwnerCreated => inner.onSemanticsOwnerCreated;

  @override
  VoidCallback? get onSemanticsOwnerDisposed => inner.onSemanticsOwnerDisposed;

  @override
  void requestVisualUpdate() => inner.requestVisualUpdate();

  @override
  AbstractNode? get rootNode => inner.rootNode;

  @override
  set rootNode(AbstractNode? value) => inner.rootNode = value;

  @override
  bool get debugDoingLayout => inner.debugDoingLayout;

  @override
  void flushLayout() => inner.flushLayout();

  @override
  void flushCompositingBits() => inner.flushCompositingBits();

  @override
  bool get debugDoingPaint => inner.debugDoingPaint;

  @override
  void flushPaint() => inner.flushPaint();

  @override
  SemanticsOwner? get semanticsOwner => inner.semanticsOwner;

  @override
  int get debugOutstandingSemanticsHandles =>
      inner.debugOutstandingSemanticsHandles;

  @override
  SemanticsHandle ensureSemantics({VoidCallback? listener}) =>
      inner.ensureSemantics(listener: listener);

  @override
  void flushSemantics() => inner.flushSemantics();
}

class ProxyBuildOwner implements BuildOwner {
  final BuildOwner inner;

  ProxyBuildOwner(this.inner);

  @override
  VoidCallback? get onBuildScheduled => inner.onBuildScheduled;

  @override
  set onBuildScheduled(VoidCallback? value) => inner.onBuildScheduled = value;

  @override
  FocusManager get focusManager => inner.focusManager;

  @override
  set focusManager(FocusManager value) => inner.focusManager = value;

  @override
  void scheduleBuildFor(Element element) => inner.scheduleBuildFor(element);

  @override
  bool get debugBuilding => inner.debugBuilding;

  @override
  void lockState(VoidCallback callback) => inner.lockState(callback);

  @override
  void buildScope(Element context, [VoidCallback? callback]) =>
      inner.buildScope(context, callback);

  @override
  int get globalKeyCount => inner.globalKeyCount;

  @override
  void finalizeTree() => inner.finalizeTree();

  @override
  void reassemble(Element root, DebugReassembleConfig? reassembleConfig) =>
      inner.reassemble(root, reassembleConfig);
}

class ProxyFlutterView implements ui.FlutterView {
  final ui.FlutterView inner;

  const ProxyFlutterView(this.inner);

  @override
  PlatformDispatcher get platformDispatcher => inner.platformDispatcher;

  @override
  ui.ViewConfiguration get viewConfiguration => inner.viewConfiguration;

  @override
  double get devicePixelRatio => inner.devicePixelRatio;

  @override
  Rect get physicalGeometry => inner.physicalGeometry;

  @override
  Size get physicalSize => inner.physicalSize;

  @override
  ui.WindowPadding get viewInsets => inner.viewInsets;

  @override
  ui.WindowPadding get viewPadding => inner.viewPadding;

  @override
  ui.WindowPadding get systemGestureInsets => inner.systemGestureInsets;

  @override
  ui.WindowPadding get padding => inner.padding;

  @override
  List<ui.DisplayFeature> get displayFeatures => inner.displayFeatures;

  @override
  void updateSemantics(ui.SemanticsUpdate update) =>
      inner.updateSemantics(update);

  @override
  void render(ui.Scene scene, {Duration? fallbackVsyncTargetTime}) =>
      inner.render(scene, fallbackVsyncTargetTime: fallbackVsyncTargetTime);
}

class ProxySingletonFlutterWindow extends ProxyFlutterView
    implements SingletonFlutterWindow {
  @override
  SingletonFlutterWindow get inner => super.inner as SingletonFlutterWindow;

  const ProxySingletonFlutterWindow(SingletonFlutterWindow super.inner);

  @override
  VoidCallback? get onMetricsChanged => inner.onMetricsChanged;

  @override
  set onMetricsChanged(VoidCallback? callback) =>
      inner.onMetricsChanged = callback;

  @override
  Locale get locale => inner.locale;

  @override
  List<Locale> get locales => inner.locales;

  @override
  Locale? computePlatformResolvedLocale(List<Locale> supportedLocales) =>
      inner.computePlatformResolvedLocale(supportedLocales);

  @override
  VoidCallback? get onLocaleChanged => inner.onLocaleChanged;

  @override
  set onLocaleChanged(VoidCallback? callback) =>
      inner.onLocaleChanged = callback;

  @override
  String get initialLifecycleState => inner.initialLifecycleState;

  @override
  double get textScaleFactor => inner.textScaleFactor;

  @override
  bool get nativeSpellCheckServiceDefined =>
      inner.nativeSpellCheckServiceDefined;

  @override
  bool get brieflyShowPassword => inner.brieflyShowPassword;

  @override
  bool get alwaysUse24HourFormat => inner.alwaysUse24HourFormat;

  @override
  VoidCallback? get onTextScaleFactorChanged => inner.onTextScaleFactorChanged;

  @override
  set onTextScaleFactorChanged(VoidCallback? callback) =>
      inner.onTextScaleFactorChanged = callback;

  @override
  Brightness get platformBrightness => inner.platformBrightness;

  @override
  VoidCallback? get onPlatformBrightnessChanged =>
      inner.onPlatformBrightnessChanged;

  @override
  set onPlatformBrightnessChanged(VoidCallback? callback) =>
      inner.onPlatformBrightnessChanged = callback;

  @override
  String? get systemFontFamily => inner.systemFontFamily;

  @override
  VoidCallback? get onSystemFontFamilyChanged =>
      inner.onSystemFontFamilyChanged;

  @override
  set onSystemFontFamilyChanged(VoidCallback? callback) =>
      inner.onSystemFontFamilyChanged = callback;

  @override
  ui.FrameCallback? get onBeginFrame => inner.onBeginFrame;

  @override
  set onBeginFrame(ui.FrameCallback? callback) => inner.onBeginFrame = callback;

  @override
  VoidCallback? get onDrawFrame => inner.onDrawFrame;

  @override
  set onDrawFrame(VoidCallback? callback) => inner.onDrawFrame = callback;

  @override
  ui.TimingsCallback? get onReportTimings => inner.onReportTimings;

  @override
  set onReportTimings(ui.TimingsCallback? callback) =>
      inner.onReportTimings = callback;

  @override
  ui.PointerDataPacketCallback? get onPointerDataPacket =>
      inner.onPointerDataPacket;

  @override
  set onPointerDataPacket(ui.PointerDataPacketCallback? callback) =>
      inner.onPointerDataPacket = callback;

  @override
  ui.KeyDataCallback? get onKeyData => inner.onKeyData;

  @override
  set onKeyData(ui.KeyDataCallback? callback) => inner.onKeyData = callback;

  @override
  String get defaultRouteName => inner.defaultRouteName;

  @override
  void scheduleFrame({Duration? forceDirectlyCallNextVsyncTargetTime}) =>
      inner.scheduleFrame(
          forceDirectlyCallNextVsyncTargetTime:
              forceDirectlyCallNextVsyncTargetTime);

  @override
  bool get semanticsEnabled => inner.semanticsEnabled;

  @override
  VoidCallback? get onSemanticsEnabledChanged =>
      inner.onSemanticsEnabledChanged;

  @override
  set onSemanticsEnabledChanged(VoidCallback? callback) =>
      inner.onSemanticsEnabledChanged = callback;

  @override
  ui.FrameData get frameData => inner.frameData;

  @override
  VoidCallback? get onFrameDataChanged => inner.onFrameDataChanged;

  @override
  set onFrameDataChanged(VoidCallback? callback) =>
      inner.onFrameDataChanged = callback;

  @override
  ui.SemanticsActionCallback? get onSemanticsAction => inner.onSemanticsAction;

  @override
  set onSemanticsAction(ui.SemanticsActionCallback? callback) =>
      inner.onSemanticsAction = callback;

  @override
  AccessibilityFeatures get accessibilityFeatures =>
      inner.accessibilityFeatures;

  @override
  VoidCallback? get onAccessibilityFeaturesChanged =>
      inner.onAccessibilityFeaturesChanged;

  @override
  set onAccessibilityFeaturesChanged(VoidCallback? callback) =>
      inner.onAccessibilityFeaturesChanged = callback;

  @override
  void sendPlatformMessage(String name, ByteData? data,
          ui.PlatformMessageResponseCallback? callback) =>
      inner.sendPlatformMessage(name, data, callback);

  @override
  ui.PlatformMessageCallback? get onPlatformMessage => inner.onPlatformMessage;

  @override
  set onPlatformMessage(ui.PlatformMessageCallback? callback) =>
      inner.onPlatformMessage = callback;

  @override
  void setIsolateDebugName(String name) => inner.setIsolateDebugName(name);
}
