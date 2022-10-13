import 'package:smooth/src/actor.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth/src/extra_event_dispatcher.dart';
import 'package:smooth/src/time/time_converter.dart';
import 'package:smooth/src/time_manager.dart';

class ServiceLocator {
  static ServiceLocator get instance =>
      SmoothSchedulerBindingMixin.instance.serviceLocator;

  factory ServiceLocator({bool testing = false}) => ServiceLocator.raw(
        actor: Actor(),
        timeManager: TimeManager(),
        auxiliaryTreeRegistry: AuxiliaryTreeRegistry(),
        extraEventDispatcher: ExtraEventDispatcher(),
        timeConverter: testing ? TimeConverter.normal() : TimeConverter.test(),
      );

  ServiceLocator.raw({
    required this.actor,
    required this.timeManager,
    required this.auxiliaryTreeRegistry,
    required this.extraEventDispatcher,
    required this.timeConverter,
  });

  ServiceLocator copyWith({
    Actor? actor,
    TimeManager? timeManager,
    AuxiliaryTreeRegistry? auxiliaryTreeRegistry,
    ExtraEventDispatcher? extraEventDispatcher,
    TimeConverter? timeConverter,
  }) =>
      ServiceLocator.raw(
        actor: actor ?? this.actor,
        timeManager: timeManager ?? this.timeManager,
        auxiliaryTreeRegistry:
            auxiliaryTreeRegistry ?? this.auxiliaryTreeRegistry,
        extraEventDispatcher: extraEventDispatcher ?? this.extraEventDispatcher,
        timeConverter: timeConverter ?? this.timeConverter,
      );

  final Actor actor;
  final TimeManager timeManager;
  final AuxiliaryTreeRegistry auxiliaryTreeRegistry;
  final ExtraEventDispatcher extraEventDispatcher;
  final TimeConverter timeConverter;
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
