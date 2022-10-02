// ignore_for_file: avoid_print

import 'package:example/example_enter_page_animation/page.dart';
import 'package:example/example_gesture/example_gesture_page.dart';
import 'package:example/example_list_view/example_list_view_page.dart';
import 'package:example/utils/debug_plain_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

void main() {
  SmoothWidgetsFlutterBinding.ensureInitialized();
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [ExcludeSemantics], because our demo contains a ton of text, much
    // more than normal app
    return ExcludeSemantics(
      child: SmoothScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Smooth: 60FPS'),
            ),
            body: Builder(
              builder: (context) => ListView(
                children: [
                  ListTile(
                    title: const Text('Example: Enter page animation'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) =>
                                const ExampleEnterPageAnimationPage())),
                  ),
                  ListTile(
                    title: const Text('Example: Gesture'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) => const ExampleGesturePage())),
                  ),
                  ListTile(
                    title: const Text('Example: ListView'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) => const ExampleListViewPage())),
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
        ),
      ),
    );
  }
}
