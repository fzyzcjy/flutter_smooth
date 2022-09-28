import 'package:smooth/src/actor.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';
import 'package:smooth/src/preempt_strategy.dart';
import 'package:smooth/src/time_source.dart';

class ServiceLocator {
  static final _realInstance = ServiceLocator.normal();

  static ServiceLocator? debugOverrideInstance;

  static ServiceLocator get instance {
    ServiceLocator? override;
    assert(() {
      override = debugOverrideInstance;
      return true;
    }());
    return override ?? _realInstance;
  }

  factory ServiceLocator.normal() => ServiceLocator.raw(
        actor: Actor(),
        preemptStrategy: PreemptStrategy.normal(
          timeSource: const TimeSource.real(),
        ),
        auxiliaryTreeRegistry: AuxiliaryTreeRegistry(),
      );

  ServiceLocator.raw({
    required this.actor,
    required this.preemptStrategy,
    required this.auxiliaryTreeRegistry,
  });

  ServiceLocator copyWith({
    Actor? actor,
    PreemptStrategy? preemptStrategy,
    AuxiliaryTreeRegistry? auxiliaryTreeRegistry,
  }) =>
      ServiceLocator.raw(
        actor: actor ?? this.actor,
        preemptStrategy: preemptStrategy ?? this.preemptStrategy,
        auxiliaryTreeRegistry:
            auxiliaryTreeRegistry ?? this.auxiliaryTreeRegistry,
      );

  final Actor actor;
  final PreemptStrategy preemptStrategy;
  final AuxiliaryTreeRegistry auxiliaryTreeRegistry;
}
