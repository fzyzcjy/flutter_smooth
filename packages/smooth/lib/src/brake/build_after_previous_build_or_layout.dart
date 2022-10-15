import 'package:flutter/material.dart';

/// [child]'s `build` will only be called after previous subtrees has
/// finished both build *and layout* phase
class BuildAfterPreviousBuildOrLayout extends StatelessWidget {
  final WidgetBuilder builder;

  const BuildAfterPreviousBuildOrLayout({super.key, required this.builder});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, __) => builder(context));
}
