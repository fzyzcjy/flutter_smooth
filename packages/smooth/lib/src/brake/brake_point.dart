import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/src/brake/build_after_previous_build_or_layout.dart';

class SmoothBrakePoint extends StatefulWidget {
  final String? debugName;
  final Widget emptyPlaceholder;
  final Widget child;

  const SmoothBrakePoint({
    super.key,
    this.debugName,
    this.emptyPlaceholder = const SizedBox(height: 48),
    required this.child,
  });

  @override
  State<SmoothBrakePoint> createState() => _SmoothBrakePointState();
}

class _SmoothBrakePointState extends State<SmoothBrakePoint> {
  Widget? previousChild;

  @override
  Widget build(BuildContext context) {
    // print(
    //     '$runtimeType.build.outside[${widget.debugName}] now=${DateTime.now()} sufficient=${BaseTimeBudget.instance.timeSufficient}');

    return BuildAfterPreviousBuildOrLayout(builder: (context) {
      // print(
      //     '$runtimeType.build.inside[${widget.debugName}] now=${DateTime.now()} sufficient=${BaseTimeBudget.instance.timeSufficient}');

      // In *normal* cases, we should not put non-pure logic inside `build`.
      // But we are hacking here, and it is safe - see readme for more details.
      if (TODO) {
        previousChild = widget.child;
        return widget.child;
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {});
        });

        return previousChild ?? widget.emptyPlaceholder;
      }
    });
  }
}
