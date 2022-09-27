import 'package:smooth/src/actor.dart';

abstract class SmoothDebug {
  static void debugPrintStat() => Actor.instance.debugPrintStat();
}