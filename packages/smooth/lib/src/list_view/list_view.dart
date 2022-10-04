import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/enhanced_padding.dart';
import 'package:smooth/src/list_view/controller.dart';

class SmoothListView extends StatefulWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final double? cacheExtent;

  const SmoothListView.builder({
    super.key,
    this.cacheExtent,
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cacheExtent =
        widget.cacheExtent ?? RenderAbstractViewport.defaultCacheExtent;
    final effectiveItemCount = widget.itemCount + 2;

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
  }
}
