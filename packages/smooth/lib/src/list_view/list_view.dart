import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/enhanced_padding.dart';
import 'package:smooth/src/list_view/controller.dart';
import 'package:smooth/src/list_view/physics.dart';

class SmoothListView extends StatefulWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  const SmoothListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  static Widget maybeBuilder({
    required bool smooth,
    required int itemCount,
    required NullableIndexedWidgetBuilder itemBuilder,
  }) =>
      smooth
          ? SmoothListView.builder(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            )
          : ListView.builder(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            );

  @override
  State<SmoothListView> createState() => _SmoothListViewState();
}

class _SmoothListViewState extends State<SmoothListView> {
  final controller = SmoothScrollController();

  @override
  void initState() {
    super.initState();

    // for debug, e.g. #6150
    controller.addListener(() {
      Timeline.timeSync(
        'ScrollController.listener',
        arguments: <String, Object?>{'offset': controller.offset},
        () {},
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveItemCount = widget.itemCount + 2;

    return LayoutBuilder(builder: (_, constraints) {
      // #6177
      final cacheExtent = constraints.maxHeight;

      return SmoothBuilder(
        builder: (context, child) => ClipRect(
          child: SmoothShift(
            scrollController: controller,
            child: child,
          ),
        ),
        child: EnhancedPadding(
          enableAllowNegativePadding: true,
          padding: EdgeInsets.only(
            top: -cacheExtent,
            bottom: -cacheExtent,
          ),
          child: ListView.builder(
            controller: controller,
            // NOTE set [cacheExtent] here to zero, because we will use overflow box
            cacheExtent: 0,
            physics: const SmoothClampingScrollPhysics(),
            itemCount: effectiveItemCount,
            itemBuilder: (context, index) {
              if (index == 0 || index == effectiveItemCount - 1) {
                return SizedBox(height: cacheExtent);
              }
              return widget.itemBuilder(context, index - 1);
            },
          ),
        ),
      );
    });
  }
}
