import 'package:smooth/src/actor.dart';

class ServiceLocator {
  static final _realInstance = ServiceLocator.raw(
    actor: Actor(),
  );

  static ServiceLocator? debugOverrideInstance;

  static ServiceLocator get instance {
    ServiceLocator? override;
    assert(() {
      override = debugOverrideInstance;
      return true;
    }());
    return override ?? _realInstance;
  }

  ServiceLocator.raw({
    required this.actor,
  });

  final Actor actor;
}
