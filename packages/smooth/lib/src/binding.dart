import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/proxy.dart';
import 'package:smooth/src/service_locator.dart';

mixin SmoothSchedulerBindingMixin on SchedulerBinding {
  DateTime get beginFrameDateTime => _beginFrameDateTime!;
  DateTime? _beginFrameDateTime;

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    _beginFrameDateTime = clock.now();
    super.handleBeginFrame(rawTimeStamp);
  }

  @override
  void handleDrawFrame() {
    _invokeStartDrawFrameCallbacks();
    super.handleDrawFrame();
  }

  // ref: [SchedulerBinding._postFrameCallbacks]
  final _startDrawFrameCallbacks = <VoidCallback>[];

  void addStartDrawFrameCallback(VoidCallback callback) =>
      _startDrawFrameCallbacks.add(callback);

  // ref: [SchedulerBinding._invokeFrameCallbackS]
  void _invokeStartDrawFrameCallbacks() {
    final localCallbacks = List.of(_startDrawFrameCallbacks);
    _startDrawFrameCallbacks.clear();
    for (final callback in localCallbacks) {
      try {
        callback();
      } catch (e, s) {
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: s));
      }
    }
  }

  static SmoothSchedulerBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothSchedulerBindingMixin,
        'Please use a WidgetsBinding with SmoothSchedulerBindingMixin');
    return raw as SmoothSchedulerBindingMixin;
  }
}

mixin SmoothRendererBindingMixin on RendererBinding {
  @override
  PipelineOwner get pipelineOwner => _smoothPipelineOwner;
  late final _smoothPipelineOwner = _SmoothPipelineOwner(super.pipelineOwner);

  static SmoothRendererBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothRendererBindingMixin,
        'Please use a WidgetsBinding with SmoothRendererBindingMixin');
    return raw as SmoothRendererBindingMixin;
  }
}

class _SmoothPipelineOwner extends ProxyPipelineOwner {
  _SmoothPipelineOwner(super.inner);

  @override
  void flushLayout() {
    super.flushLayout();
    _handleAfterFlushLayout();
  }

  void _handleAfterFlushLayout() {
    // print('handleAfterFlushLayout');

    final serviceLocator = ServiceLocator.maybeInstance;
    if (serviceLocator == null) return;

    serviceLocator.preemptStrategy.refresh();
    final currentSmoothFrameTimeStamp =
        serviceLocator.preemptStrategy.currentSmoothFrameTimeStamp;

    for (final pack in serviceLocator.auxiliaryTreeRegistry.trees) {
      pack.runPipeline(
        currentSmoothFrameTimeStamp,
        // NOTE originally, this is skip-able
        // https://github.com/fzyzcjy/flutter_smooth/issues/23#issuecomment-1261691891
        // but, since the `addPostMainTreeFlushLayoutCallback` may trigger
        // some setState, we can no longer skip it
        // https://github.com/fzyzcjy/yplusplus/issues/5917#issuecomment-1265361649
        skipIfTimeStampUnchanged: false,
        debugReason: 'SmoothPipelineOwner.handleAfterFlushLayout',
      );
    }
  }
}

// ref [AutomatedTestWidgetsFlutterBinding]
class SmoothWidgetsFlutterBinding extends WidgetsFlutterBinding
    with SmoothSchedulerBindingMixin, SmoothRendererBindingMixin {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SmoothWidgetsFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);
  static SmoothWidgetsFlutterBinding? _instance;

  // ignore: prefer_constructors_over_static_methods
  static SmoothWidgetsFlutterBinding ensureInitialized() {
    if (SmoothWidgetsFlutterBinding._instance == null) {
      SmoothWidgetsFlutterBinding();
    }
    return SmoothWidgetsFlutterBinding.instance;
  }
}
