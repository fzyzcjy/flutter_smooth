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

// should not use it - too late to register ServiceLocator
// https://github.com/fzyzcjy/yplusplus/issues/6166#issuecomment-1276924348
//
// class SmoothScope extends StatefulWidget {
//   final ServiceLocator? serviceLocator;
//   final Widget child;
//
//   const SmoothScope({super.key, this.serviceLocator, required this.child});
//
//   @override
//   State<SmoothScope> createState() => _SmoothScopeState();
// }
//
// class _SmoothScopeState extends State<SmoothScope> {
//   late final serviceLocator = widget.serviceLocator ?? ServiceLocator.normal();
//
//   @override
//   void initState() {
//     super.initState();
//     assert(ServiceLocator._instance == null);
//     ServiceLocator._instance = serviceLocator;
//   }
//
//   @override
//   void didUpdateWidget(covariant SmoothScope oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     assert(widget.serviceLocator == oldWidget.serviceLocator);
//   }
//
//   @override
//   void dispose() {
//     assert(ServiceLocator._instance == serviceLocator);
//     ServiceLocator._instance = null;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SmoothParent(
//       child: widget.child,
//     );
//   }
// }
