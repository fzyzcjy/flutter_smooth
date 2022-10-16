import 'package:flutter/material.dart';

class SmoothPageRouteBuilder<T> extends PageRouteBuilder<T> {
  SmoothPageRouteBuilder({
    // just copy from [PageRouteBuilder] constructor
    super.settings,
    required super.pageBuilder,
    required super.transitionsBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 300),
    super.opaque = true,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });
}
