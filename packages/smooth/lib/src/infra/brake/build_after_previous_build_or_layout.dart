import 'package:flutter/material.dart';

/// [child]'s `build` will only be called after previous subtrees has
/// finished both build *and layout* phase
// Be a function, not a widget, because it is one-line and widget will introduce
// overhead
// ignore: non_constant_identifier_names
Widget BuildAfterPreviousBuildOrLayout({required WidgetBuilder builder}) =>
    LayoutBuilder(builder: (context, __) => builder(context));
