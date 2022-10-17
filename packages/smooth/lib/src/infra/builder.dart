import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/infra/adapter_in_auxiliary_tree.dart';
import 'package:smooth/src/infra/adapter_in_main_tree.dart';
import 'package:smooth/src/infra/auxiliary_tree_pack.dart';

class SmoothBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Widget child) builder;
  final Widget child;

  // TODO improve this api
  final List<Ticker> wantSmoothTickTickers;

  const SmoothBuilder({
    super.key,
    required this.builder,
    required this.child,
    this.wantSmoothTickTickers = const [],
  });

  @override
  State<SmoothBuilder> createState() => _SmoothBuilderState();
}

class _SmoothBuilderState extends State<SmoothBuilder> {
  late final AuxiliaryTreePack pack;

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
              pack: pack,
            ),
          ),
        ),
      ),
      wantSmoothTickTickers: () => widget.wantSmoothTickTickers,
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
        child: widget.child,
      ),
    );
  }
}
