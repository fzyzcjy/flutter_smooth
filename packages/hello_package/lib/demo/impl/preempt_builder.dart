// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'adapter.dart';
import 'auxiliary_tree.dart';

class PreemptBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Widget child) builder;
  final Widget child;

  const PreemptBuilder({
    super.key,
    required this.builder,
    required this.child,
  });

  @override
  State<PreemptBuilder> createState() => _PreemptBuilderState();
}

class _PreemptBuilderState extends State<PreemptBuilder> {
  // hacky, just for prototype
  late StateSetter auxiliaryTreeWidgetSetState;
  var dummy = 0;

  late final AuxiliaryTreePack pack;

  @override
  void initState() {
    super.initState();
    print('${describeIdentity(this)} initState');

    pack = AuxiliaryTreePack(
      StatefulBuilder(builder: (context, setState) {
        auxiliaryTreeWidgetSetState = setState;
        return widget.builder(
          context,
          AdapterInAuxiliaryTreeWidget(
            pack: pack,
            dummy: dummy++,
          ),
        );
      }),
    );
  }

  @override
  void didUpdateWidget(covariant PreemptBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    auxiliaryTreeWidgetSetState(() {});
  }

  @override
  void dispose() {
    print('${describeIdentity(this)} dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdapterInMainTreeWidget(
      pack: pack,
      dummy: dummy,
      child: widget.child,
    );
  }
}
