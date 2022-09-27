import 'package:smooth/src/actor.dart';
import 'package:smooth/src/service_locator.dart';

abstract class SmoothDebug {
  static void debugPrintStat() =>
      ServiceLocator.instance.actor.debugPrintStat();
}
