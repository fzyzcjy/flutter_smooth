// ignore_for_file: avoid_print

import 'package:example/example_enter_page_animation/page.dart';
import 'package:example/example_gesture/example_gesture_page.dart';
import 'package:example/example_list_view/example_list_view_page.dart';
import 'package:example/example_simple_animation/example_simple_animation_page.dart';
import 'package:example/utils/debug_plain_animation.dart';
import 'package:example/utils/simple_pointer_event_page.dart';
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
                  for (final enableSmooth in [false, true])
                    ListTile(
                      title: Text(
                          'Example: ListView (${enableSmooth ? 'smooth' : 'plain'}, debugHeader)'),
                      onTap: () => Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                              builder: (_) => ExampleListViewPage(
                                  enableSmooth: enableSmooth,
                                  enableDebugHeader: true))),
                    ),
                  ListTile(
                    title: const Text(
                        'Example: ListView smooth + leaveWhenPointerUp'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) => const ExampleListViewPage(
                                enableSmooth: true,
                                enableDebugHeader: true,
                                leaveWhenPointerUp: true))),
                  ),
                  ListTile(
                    title: const Text('Example: ListView plain + 0 workload'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) => const ExampleListViewPage(
                                enableSmooth: false, workloadMillis: 0))),
                  ),
                  ListTile(
                    title: const Text('Example: ListView plain'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) => const ExampleListViewPage(
                                enableSmooth: false))),
                  ),
                  ListTile(
                    title: const Text('Example: ListView smooth'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) =>
                                const ExampleListViewPage(enableSmooth: true))),
                  ),
                  for (final enableSmooth in [false, true])
                    ListTile(
                      title: Text(
                          'Example: Simple animation (${enableSmooth ? 'smooth' : 'plain'})'),
                      onTap: () => Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                              builder: (_) => ExampleSimpleAnimationPage(
                                  smooth: enableSmooth))),
                    ),
                  ListTile(
                    title: const Text('Show debug widget'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) => const DebugPlainAnimationPage())),
                  ),
                  ListTile(
                    title: const Text('SimplePointerEventPage'),
                    onTap: () => Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (_) => const SimplePointerEventPage())),
                  ),
                  // ListTile(
                  //   title: const Text('Dump logs'),
                  //   onTap: SimpleLog.instance.dumpAndReset,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
