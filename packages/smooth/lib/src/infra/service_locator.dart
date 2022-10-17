import 'package:smooth/src/infra/actor.dart';
import 'package:smooth/src/infra/auxiliary_tree_pack.dart';
import 'package:smooth/src/infra/binding.dart';
import 'package:smooth/src/infra/brake/brake_controller.dart';
import 'package:smooth/src/infra/extra_event_dispatcher.dart';
import 'package:smooth/src/infra/time/time_converter.dart';
import 'package:smooth/src/infra/time_manager.dart';

class ServiceLocator {
  static ServiceLocator get instance =>
      SmoothSchedulerBindingMixin.instance.serviceLocator;

  factory ServiceLocator({
    Actor? actor,
    TimeManager? timeManager,
    AuxiliaryTreeRegistry? auxiliaryTreeRegistry,
    ExtraEventDispatcher? extraEventDispatcher,
    TimeConverter? timeConverter,
    BrakeController? brakeController,
  }) =>
      ServiceLocator.raw(
        actor: actor ?? Actor(),
        timeManager: timeManager ?? TimeManager(),
        auxiliaryTreeRegistry: auxiliaryTreeRegistry ?? AuxiliaryTreeRegistry(),
        extraEventDispatcher: extraEventDispatcher ?? ExtraEventDispatcher(),
        timeConverter: timeConverter ?? TimeConverter(),
        brakeController: brakeController ?? BrakeController(),
      );

  ServiceLocator.raw({
    required this.actor,
    required this.timeManager,
    required this.auxiliaryTreeRegistry,
    required this.extraEventDispatcher,
    required this.timeConverter,
    required this.brakeController,
  });

  final Actor actor;
  final TimeManager timeManager;
  final AuxiliaryTreeRegistry auxiliaryTreeRegistry;
  final ExtraEventDispatcher extraEventDispatcher;
  final TimeConverter timeConverter;
  final BrakeController brakeController;
}
