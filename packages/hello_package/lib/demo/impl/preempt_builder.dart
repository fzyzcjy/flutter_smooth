// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  var dummy = 0;

  late final AuxiliaryTreePack pack;

  @override
  void initState() {
    super.initState();
    print('${describeIdentity(this)} initState');

    pack = AuxiliaryTreePack(
      (pack) => Builder(
        builder: (context) => widget.builder(
          context,
          AdapterInAuxiliaryTreeWidget(
            pack: pack,
            dummy: dummy++,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('${describeIdentity(this)} dispose');
    pack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // hack, just for prototype
    print('$runtimeType call pack.runPipeline');
    pack.runPipeline();

    // hack, have not deal with "only refresh main tree when aux tree is dirty",
    // so let's blindly refresh everything
    SchedulerBinding.instance.addPostFrameCallback((_) {
      print('$runtimeType addPostFrameCallback call setState');
      setState(() {});
    });

    // hack: [AdapterInMainTreeWidget] does not respect "offset" in paint
    // now, so we add a RepaintBoundary to let offset==0
    return RepaintBoundary(
      child: AdapterInMainTreeWidget(
        pack: pack,
        dummy: dummy,
        child: widget.child,
      ),
    );
  }
}
