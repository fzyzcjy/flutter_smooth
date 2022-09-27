import 'package:smooth/src/actor.dart';

class ServiceLocator {
  static var instance = ServiceLocator._();

  ServiceLocator._();

  final actor = Actor();
}
