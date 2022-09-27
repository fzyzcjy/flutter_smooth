import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class SmoothAutomatedTestWidgetsFlutterBinding
    extends AutomatedTestWidgetsFlutterBinding
    with SmoothSchedulerBindingMixin {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SmoothAutomatedTestWidgetsFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);
  static SmoothAutomatedTestWidgetsFlutterBinding? _instance;

  // ignore: prefer_constructors_over_static_methods
  static SmoothAutomatedTestWidgetsFlutterBinding ensureInitialized() {
    if (SmoothAutomatedTestWidgetsFlutterBinding._instance == null) {
      SmoothAutomatedTestWidgetsFlutterBinding();
    }
    return SmoothAutomatedTestWidgetsFlutterBinding.instance;
  }
}

mixin SmoothSchedulerBindingMixin on SchedulerBinding {
  // TODO
}
