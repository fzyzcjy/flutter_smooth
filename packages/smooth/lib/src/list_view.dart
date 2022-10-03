import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth/src/builder.dart';
import 'package:smooth/src/enhanced_padding.dart';
import 'package:smooth/src/shift.dart';

class SmoothListView extends StatelessWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final double? cacheExtent;

  const SmoothListView.builder({
    super.key,
    this.cacheExtent,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final cacheExtent =
        this.cacheExtent ?? RenderAbstractViewport.defaultCacheExtent;
    final effectiveItemCount = itemCount + 2;

    return SmoothBuilder(
      builder: (context, child) => ClipRect(
        child: SmoothShift(
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
          // NOTE set [cacheExtent] here to zero, because we will use overflow box
          cacheExtent: 0,
          itemCount: effectiveItemCount,
          itemBuilder: (context, index) {
            if (index == 0 || index == effectiveItemCount - 1) {
              return SizedBox(height: cacheExtent);
            }
            return itemBuilder(context, index - 1);
          },
        ),
      ),
    );
  }
}
