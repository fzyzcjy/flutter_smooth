// ignore_for_file: avoid_print

import 'package:example/example_enter_page_animation/page.dart';
import 'package:example/utils/debug_plain_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ListView(
            children: [
              ListTile(
                title: const Text('Example: Enter page animation'),
                onTap: () => Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (_) => const ExampleEnterPageAnimationPage())),
              ),
              ListTile(
                title: const Text('Show debug widget'),
                onTap: () => Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (_) => const DebugPlainAnimationPage())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
