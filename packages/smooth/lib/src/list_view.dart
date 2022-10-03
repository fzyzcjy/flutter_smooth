import 'package:flutter/material.dart';
import 'package:smooth/src/builder.dart';
import 'package:smooth/src/shift.dart';

class SmoothListView extends StatelessWidget {
  final NullableIndexedWidgetBuilder itemBuilder;

  const SmoothListView.builder({
    super.key,
    // forward arguments to ListView
    // ... can add more here ...
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothBuilder(
      builder: (context, child) => SmoothShift(
        child: child,
      ),
      child: ListView.builder(
        itemBuilder: itemBuilder,
      ),
    );
  }
}
