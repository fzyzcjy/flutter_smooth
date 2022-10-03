import 'package:flutter/material.dart';
import 'package:smooth/src/graft/adapter_in_main_tree.dart';
import 'package:smooth/src/graft/auxiliary_tree_pack.dart';

class GraftBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) auxiliaryTreeBuilder;
  final Widget Function(BuildContext context, Object slot) mainTreeChildBuilder;

  const GraftBuilder({
    super.key,
    required this.auxiliaryTreeBuilder,
    required this.mainTreeChildBuilder,
  });

  @override
  State<GraftBuilder> createState() => _GraftBuilderState();
}

class _GraftBuilderState extends State<GraftBuilder> {
  late final AuxiliaryTreePack pack;

  @override
  void initState() {
    super.initState();
    pack = AuxiliaryTreePack(
      (pack) => Builder(
        builder: (context) => widget.auxiliaryTreeBuilder(context),
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
    return AdapterInMainTree(
      pack: pack,
      mainTreeChildBuilder: widget.mainTreeChildBuilder,
    );
  }
}
