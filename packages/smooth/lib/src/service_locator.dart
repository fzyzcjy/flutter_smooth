import 'package:smooth/src/actor.dart';
import 'package:smooth/src/auxiliary_tree.dart';

class ServiceLocator {
  static final _realInstance = ServiceLocator.raw();

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
    Actor? actor,
    AuxiliaryTreeRegistry? auxiliaryTreeRegistry,
  })  : actor = actor ?? Actor(),
        auxiliaryTreeRegistry =
            auxiliaryTreeRegistry ?? AuxiliaryTreeRegistry();

  final Actor actor;
  final AuxiliaryTreeRegistry auxiliaryTreeRegistry;
}
