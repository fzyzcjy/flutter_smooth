import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

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
