import 'package:smooth/src/actor.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';
import 'package:smooth/src/preempt_strategy.dart';

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
    PreemptStrategy? preemptStrategy,
    AuxiliaryTreeRegistry? auxiliaryTreeRegistry,
  })  : actor = actor ?? Actor(),
        preemptStrategy = preemptStrategy ?? PreemptStrategy.normal(),
        auxiliaryTreeRegistry =
            auxiliaryTreeRegistry ?? AuxiliaryTreeRegistry();

  final Actor actor;
  final PreemptStrategy preemptStrategy;
  final AuxiliaryTreeRegistry auxiliaryTreeRegistry;
}
