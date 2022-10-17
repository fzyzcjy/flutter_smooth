import 'package:smooth/src/infra/service_locator.dart';

abstract class SmoothDebug {
  static void debugPrintStat() =>
      ServiceLocator.instance.actor.debugPrintStat();
}
