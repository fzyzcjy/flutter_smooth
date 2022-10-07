import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ProxyPipelineOwner implements PipelineOwner {
  final PipelineOwner inner;

  ProxyPipelineOwner(this.inner);

  @override
  List<RenderObject> get nodesNeedingPaint => inner.nodesNeedingPaint;

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
