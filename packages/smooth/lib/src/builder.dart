import 'package:flutter/material.dart';
import 'package:smooth/src/adapter_in_auxiliary_tree.dart';
import 'package:smooth/src/adapter_in_main_tree.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';

class SmoothBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Widget child) builder;
  final Widget child;

  const SmoothBuilder({
    super.key,
    required this.builder,
    required this.child,
  });

  @override
  State<SmoothBuilder> createState() => _SmoothBuilderState();
}

class _SmoothBuilderState extends State<SmoothBuilder> {
  late final AuxiliaryTreePack pack;
  static const _slot = 'dummy-slot'; // TODO

  @override
  void initState() {
    super.initState();
    // print('${describeIdentity(this)} initState');

    pack = AuxiliaryTreePack(
      (pack) => Builder(
        builder: (context) => widget.builder(
          context,
          // hack, since AdapterInAuxiliaryTreeWidget not deal with offset yet
          RepaintBoundary(
            child: AdapterInAuxiliaryTreeWidget(
              slot: _slot,
              pack: pack,
            ),
          ),
        ),
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
    // should not run pipeline here, see the link below
    // https://github.com/fzyzcjy/yplusplus/issues/5815#issuecomment-1256952866
    // pack.runPipeline(debugReason: '$runtimeType.build');

    // hack: [AdapterInMainTreeWidget] does not respect "offset" in paint
    // now, so we add a RepaintBoundary to let offset==0
    return RepaintBoundary(
      child: AdapterInMainTreeWidget(
        pack: pack,
        children: [
          AdapterInMainTreeChildWidget(
            slot: _slot,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
