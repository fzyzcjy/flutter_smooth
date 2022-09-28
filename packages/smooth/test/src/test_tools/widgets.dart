import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AlwaysBuildBuilder extends StatefulWidget {
  final VoidCallback onBuild;

  const AlwaysBuildBuilder({super.key, required this.onBuild});

  @override
  State<AlwaysBuildBuilder> createState() => _AlwaysBuildBuilderState();
}

class _AlwaysBuildBuilderState extends State<AlwaysBuildBuilder> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
    widget.onBuild();
    return Container();
  }
}

class OnceCallback {
  VoidCallback? _value;

  set value(VoidCallback v) => _value = v;

  bool get isEmpty => _value == null;

  void call() {
    final f = _value;
    _value = null;

    if (f == null) throw Exception;
    f();
  }
}
