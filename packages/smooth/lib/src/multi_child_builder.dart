import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth/src/adapter_in_main_tree.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';

// TODO merge with classical [SmoothBuilder]
class SmoothMultiChildBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) smoothBuilder;
  final Widget Function(BuildContext context, Object slot) childBuilder;

  const SmoothMultiChildBuilder({
    super.key,
    required this.smoothBuilder,
    required this.childBuilder,
  });

  @override
  State<SmoothMultiChildBuilder> createState() =>
      _SmoothMultiChildBuilderState();
}

class _SmoothMultiChildBuilderState extends State<SmoothMultiChildBuilder> {
  late final AuxiliaryTreePack pack;

  @override
  void initState() {
    super.initState();
    // print('${describeIdentity(this)} initState');

    pack = AuxiliaryTreePack(
      (pack) => Builder(
        builder: (context) => widget.smoothBuilder(context),
      ),
    );
  }

  @override
  void dispose() {
    // print('${describeIdentity(this)} dispose');
    pack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO ok?
    print('${describeIdentity(this)}.build call buildScope');
    pack.buildOwner.buildScope(pack.element);

    // hack: [AdapterInMainTreeWidget] does not respect "offset" in paint
    // now, so we add a RepaintBoundary to let offset==0
    return RepaintBoundary(
      child: AdapterInMainTreeWidget(
        pack: pack,
        // NOTE the [slots] are updated after we call [buildOwner.buildScope]
        // just above.
        children: pack.childPlaceholderRegistry.slots
            .map((slot) => AdapterInMainTreeChildWidget(
                  slot: slot,
                  child: widget.childBuilder(context, slot),
                ))
            .toList(),
      ),
    );
  }
}
